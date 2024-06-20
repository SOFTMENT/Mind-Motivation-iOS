//
//  AdminEditCategoryViewController.swift
//  Mind Motivations
//
//  Created by Vijay Rathore on 01/12/22.
//

import UIKit
import CropViewController
import FirebaseStorage
import Firebase
import FirebaseAuth
import SDWebImage


class AdminEditCategoryViewController : UIViewController {
    var catModel : CategoryModel?
    @IBOutlet weak var backBtn: UIImageView!
  
    @IBOutlet weak var catView: UIView!
    @IBOutlet weak var catImage: UIImageView!
    
    @IBOutlet weak var catName: UITextField!
    
    @IBOutlet weak var addBtn: UIButton!
    var isImageSelected = false
    
    @IBOutlet weak var deleteView: UIImageView!
    
    
    override func viewDidLoad() {
        
        guard let catModel = catModel else {
            DispatchQueue.main.async {
                self.dismiss(animated: true)
            }
            return
        }
        
        backBtn.isUserInteractionEnabled = true
        backBtn.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(backBtnClicked)))
        
        addBtn.layer.cornerRadius = 12
        
        catName.delegate = self
        catName.text = catModel.title ?? ""
        
        catName.setLeftPaddingPoints(16)
        catName.setRightPaddingPoints(10)
    
        catName.changePlaceholderColour()
    
        catName.layer.cornerRadius = 8
        
        catImage.isUserInteractionEnabled = true
        catImage.layer.cornerRadius = 12
        catImage.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(imageViewClicked)))
        
        if let imagePath = catModel.thumbnail , !imagePath.isEmpty {
            catImage.sd_setImage(with: URL(string: imagePath), placeholderImage: UIImage(named: "placeholder"))
            catView.isHidden = true
            catImage.isHidden = false
        }
        
        catView.isUserInteractionEnabled = true
        catView.layer.cornerRadius = 12
        catView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(imageViewClicked)))
        
        deleteView.isUserInteractionEnabled = true
        deleteView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(deleteViewClicked)))

    }
    
    @objc func deleteViewClicked() {
        let alert = UIAlertController(title: "Delete", message: "Are you sure you want to delete this category?", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Delete", style: .destructive,handler: { action in
            self.ProgressHUDShow(text: "Deleting...")
            Firestore.firestore().collection("Categories").document(self.catModel!.id ?? "123").delete { error in
                self.ProgressHUDHide()
                if let error = error {
                    self.showError(error.localizedDescription)
                }
                else {
                    self.showSnack(messages: "Deleted")
                    
                    //DELETE Thumbnail
                    Storage.storage().reference().child("CategoryImages").child(self.catModel!.id ?? "123").child("\(self.catModel!.id ?? "123").png").delete { error in
                        //
                    }
                    
                    //DELET SUBCOLLECTION HERE
                    DispatchQueue.main.asyncAfter(deadline: .now() + 1.2, execute: {
                        self.dismiss(animated: true)
                    })
                  
                    
                }
            }
        }))
        
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        present(alert, animated: true)
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
        
        else {
            
            self.catModel!.title = sCategoryName
          
            if isImageSelected {
                ProgressHUDShow(text: "")
                self.uploadImageOnFirebase(catId: self.catModel!.id ?? "123") { downloadURL in
                   
                    if !downloadURL.isEmpty {

                     
                        self.catModel!.thumbnail = downloadURL
                        self.updateCategory()
                       
                    }
                    else {
                     
                        self.ProgressHUDHide()
                        self.showSnack(messages: "Failed to upload image")
                    }
                    
                }
            }
            else {
                ProgressHUDShow(text: "")
                self.updateCategory()
            }
           
        }
    }
    
    func updateCategory(){
      
        try? Firestore.firestore().collection("Categories").document(self.catModel!.id ?? "123").setData(from: self.catModel,merge : true,completion: { error in
            self.ProgressHUDHide()
            if let error = error {
                self.showError(error.localizedDescription)
            }
            else {
                self.showSnack(messages: "Category Updated")
                DispatchQueue.main.asyncAfter(deadline: .now() + 1.2) {
                    self.dismiss(animated: true)
                }
            }
        })
    }
}

extension AdminEditCategoryViewController : UITextFieldDelegate {
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        view.endEditing(true)
    }
}


extension AdminEditCategoryViewController : UIImagePickerControllerDelegate,UINavigationControllerDelegate,CropViewControllerDelegate {
        
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
