//
//  AddCategoryViewController.swift
//  Mind Motivations
//
//  Created by Vijay Rathore on 19/11/22.
//

import UIKit
import CropViewController
import FirebaseStorage
import Firebase
import FirebaseAuth


class AddCategoryViewController : UIViewController {
    
    @IBOutlet weak var backBtn: UIImageView!
  
    @IBOutlet weak var catView: UIView!
    @IBOutlet weak var catImage: UIImageView!
    
    @IBOutlet weak var catName: UITextField!
    
    @IBOutlet weak var addBtn: UIButton!
    var isImageSelected = false
    
    override func viewDidLoad() {
        
        backBtn.isUserInteractionEnabled = true
        backBtn.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(backBtnClicked)))
        
        addBtn.layer.cornerRadius = 12
        
        catName.delegate = self
        
        catName.setLeftPaddingPoints(16)
        catName.setRightPaddingPoints(10)
    
        catName.changePlaceholderColour()
    
        catName.layer.cornerRadius = 8
        
        catImage.isUserInteractionEnabled = true
        catImage.layer.cornerRadius = 12
        catImage.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(imageViewClicked)))
        
        catView.isUserInteractionEnabled = true
        catView.layer.cornerRadius = 12
        catView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(imageViewClicked)))
       
    }
   
        @objc func imageViewClicked(){
            chooseImageFromPhotoLibrary()
        }
        
        func chooseImageFromPhotoLibrary(){
            
            let image = UIImagePickerController()
            image.delegate = self
            image.title = title
            image.sourceType = .photoLibrary
            self.present(image,animated: true)
        }
    
    @objc func backBtnClicked(){
        dismiss(animated: true)
    }
    
    @IBAction func addBtnClicked(_ sender: Any) {
        let sCategoryName = catName.text?.trimmingCharacters(in: .whitespacesAndNewlines)
        if sCategoryName == "" {
            
            self.showSnack(messages: "Enter Category Name")
        }
        else if !isImageSelected {
            self.showSnack(messages: "Upload Category Image")
        }
        else {
            ProgressHUDShow(text: "")
            let docId = Firestore.firestore().collection("Categories").document().documentID
            self.uploadImageOnFirebase(catId: docId) { downloadURL in
                
                if !downloadURL.isEmpty {
                    let categoryModel = CategoryModel()
                    categoryModel.id = docId
                    categoryModel.tracks = 0
                    categoryModel.createDate = Date()
                    categoryModel.title = sCategoryName
                    categoryModel.thumbnail = downloadURL
                    
                    try? Firestore.firestore().collection("Categories").document(docId).setData(from: categoryModel,completion: { error in
                        self.ProgressHUDHide()
                        if let error = error {
                            self.showError(error.localizedDescription)
                        }
                        else {
                            self.showSnack(messages: "Category Added")
                            DispatchQueue.main.asyncAfter(deadline: .now() + 1.2) {
                                self.dismiss(animated: true)
                            }
                        }
                    })
                }
                else {
                    self.ProgressHUDHide()
                    self.showSnack(messages: "Failed to upload image")
                }
                
            }
        }
    }
}

extension AddCategoryViewController : UITextFieldDelegate {
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        view.endEditing(true)
    }
}


extension AddCategoryViewController : UIImagePickerControllerDelegate,UINavigationControllerDelegate,CropViewControllerDelegate {
        
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if let editedImage = info[.originalImage] as? UIImage {
            
            self.dismiss(animated: true) {
                
                let cropViewController = CropViewController(image: editedImage)
                cropViewController.title = picker.title
                cropViewController.delegate = self
                cropViewController.customAspectRatio = CGSize(width: 1  , height: 1)
                cropViewController.aspectRatioLockEnabled = true
                cropViewController.aspectRatioPickerButtonHidden = true
                self.present(cropViewController, animated: true, completion: nil)
            }

        }
        
    }
    
    func cropViewController(_ cropViewController: CropViewController, didCropToImage image: UIImage, withRect cropRect: CGRect, angle: Int) {
        
    
        isImageSelected = true
        catImage.image = image
        catImage.isHidden = false
        catView.isHidden = true
        self.dismiss(animated: true, completion: nil)
    }
    
    
    func uploadImageOnFirebase(catId : String,completion : @escaping (String) -> Void ) {
        var downloadUrl = ""

        
        let storage = Storage.storage().reference().child("CategoryImages").child(catId).child("\(catId).png")
       
        
        var uploadData : Data!
        
        uploadData = (self.catImage.image?.jpegData(compressionQuality: 0.4))!
        
        
        
        storage.putData(uploadData, metadata: nil) { (metadata, error) in
            
            if error == nil {
                storage.downloadURL { (url, error) in
                    if error == nil {
                        downloadUrl = url!.absoluteString
                    }
                    completion(downloadUrl)
                    
                }
            }
            else {
                completion(downloadUrl)
            }
            
        }
    }
}
