//
//  AddMusicViewController.swift
//  Mind Motivations
//
//  Created by Vijay Rathore on 19/11/22.
//

import UIKit
import CropViewController
import Firebase
import FirebaseFirestore
import FirebaseFirestoreSwift
import MobileCoreServices
import UniformTypeIdentifiers
import AVFoundation

class AddMusicViewController : UIViewController {
    
    @IBOutlet weak var backView: UIImageView!
    @IBOutlet weak var imageView: UIView!
    @IBOutlet weak var musicImage: UIImageView!
    
    @IBOutlet weak var addMusicView: UIView!
    
    @IBOutlet weak var musicNameTF: UITextField!
    @IBOutlet weak var artistNameTF: UITextField!
    
    @IBOutlet weak var aboutTV: UITextView!
    
    @IBOutlet weak var addBtn: UIButton!
    
    @IBOutlet weak var genreTF: UITextField!
    
    var catModel : CategoryModel?
    var isImageSelected = false
    var musicPath : URL?
    @IBOutlet weak var addMusicLabel: UILabel!
    
    
    override func viewDidLoad() {
        
        guard catModel != nil else {
            
            DispatchQueue.main.async {
                self.dismiss(animated: true)
            }
            return
        }
        
        
        backView.isUserInteractionEnabled = true
        backView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(backViewClicked)))
        
        addBtn.layer.cornerRadius = 12
        
        addMusicView.isUserInteractionEnabled = true
        addMusicView.layer.borderWidth = 1
        addMusicView.layer.borderColor = UIColor.white.cgColor
        addMusicView.layer.cornerRadius = 8
        addMusicView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(addMusicClicked)))
        
        musicNameTF.setLeftPaddingPoints(10)
        musicNameTF.setRightPaddingPoints(10)
        musicNameTF.changePlaceholderColour()
        musicNameTF.layer.cornerRadius = 8
        
        artistNameTF.setLeftPaddingPoints(10)
        artistNameTF.setRightPaddingPoints(10)
        artistNameTF.changePlaceholderColour()
        artistNameTF.layer.cornerRadius = 8
        
        genreTF.setLeftPaddingPoints(10)
        genreTF.setRightPaddingPoints(10)
        genreTF.changePlaceholderColour()
        genreTF.layer.cornerRadius = 8
        
        imageView.isUserInteractionEnabled = true
        imageView.layer.cornerRadius = 12
        imageView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(imageViewClicked)))
        
        musicImage.isUserInteractionEnabled = true
        musicImage.layer.cornerRadius = 12
        musicImage.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(imageViewClicked)))
        
        aboutTV.layer.cornerRadius = 8
        aboutTV.contentInset = UIEdgeInsets(top: 6, left: 5, bottom: 6, right: 6)
        aboutTV.delegate = self
        
        view.isUserInteractionEnabled = true
        view.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(hideKeyboard)))
        
    }
    
    @objc func hideKeyboard(){
        view.endEditing(true)
    }
    
    @objc func addMusicClicked(){
        
        let pickerController =  UIDocumentPickerViewController(forOpeningContentTypes: [UTType.audio],asCopy: true)
        pickerController.delegate = self
        pickerController.modalPresentationStyle = .fullScreen
        self.present(pickerController, animated: true, completion: nil)
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
    
    @objc func backViewClicked(){
        self.dismiss(animated: true)
    }
    
    @IBAction func addBtnClicked(_ sender: Any) {
        Task { @MainActor in
            
            let sTitle = self.musicNameTF.text?.trimmingCharacters(in: .whitespacesAndNewlines)
            let sArtist = self.artistNameTF.text?.trimmingCharacters(in: .whitespacesAndNewlines)
            let sGenre = self.genreTF.text?.trimmingCharacters(in: .whitespacesAndNewlines)
            let sAbout = self.aboutTV.text.trimmingCharacters(in: .whitespacesAndNewlines)
            
            if !isImageSelected {
                self.showSnack(messages: "Upload Image")
            }
            else if self.musicPath == nil {
                self.showSnack(messages: "Add Music")
            }
            else if sTitle!.isEmpty {
                self.showSnack(messages: "Enter Title")
            }
            else if sArtist!.isEmpty {
                self.showSnack(messages: "Enter Artist Name")
            }
            else if sGenre!.isEmpty {
                self.showSnack(messages: "Enter Genre")
            }
            else if sAbout.isEmpty {
                self.showSnack(messages: "Enter About")
            }
            else {
              
                let musicId = Firestore.firestore().collection("Categories").document(catModel!.id ?? "123").collection("Musics").document().documentID
                let musicModel = MusicModel()
                musicModel.id = musicId
                musicModel.duration = await Int(self.getVideoDuration())
                musicModel.title = sTitle ?? ""
                musicModel.artistName = sArtist ?? ""
                musicModel.genre = sGenre ?? ""
                musicModel.about = sAbout
                musicModel.catId = catModel!.id ?? "123"
                musicModel.catName = catModel!.title ?? ""
                musicModel.createdDate = Date()
                self.ProgressHUDShow(text: "Uploading Music")
                self.uploadMusicOnFirebase(musicId: musicId) { downloadURL in
                    self.ProgressHUDHide()
                    if !downloadURL.isEmpty {
                        musicModel.musicUrl = downloadURL
                        self.ProgressHUDShow(text: "")
                        self.uploadImageOnFirebase(musicId: musicId) { downloadURL in
                            self.ProgressHUDHide()
                            if !downloadURL.isEmpty {
                                musicModel.thumbnail = downloadURL
                                self.uploadMusicModelOnFirebase(musicModel: musicModel)
                                
                            }
                            
                            
                        }
                    }
                }
                
                
                
                
            }
        }
    }
    
}

extension AddMusicViewController : UIImagePickerControllerDelegate,UINavigationControllerDelegate,CropViewControllerDelegate {
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if let editedImage = info[.originalImage] as? UIImage {
            
            self.dismiss(animated: true) {
                
                let cropViewController = CropViewController(image: editedImage)
                cropViewController.title = picker.title
                cropViewController.delegate = self
      
                cropViewController.aspectRatioLockEnabled = false
                cropViewController.aspectRatioPickerButtonHidden = false
                self.present(cropViewController, animated: true, completion: nil)
            }
            
        }
        
    }
    
    func cropViewController(_ cropViewController: CropViewController, didCropToImage image: UIImage, withRect cropRect: CGRect, angle: Int) {
        
        
        isImageSelected = true
        musicImage.image = image
        musicImage.isHidden = false
        imageView.isHidden = true
        self.dismiss(animated: true, completion: nil)
    }
    
    
    func uploadImageOnFirebase(musicId : String,completion : @escaping (String) -> Void ) {
        var downloadUrl = ""
        
        
        let storage = Storage.storage().reference().child("MusicImages").child(musicId).child("\(musicId).png")
        
        
        var uploadData : Data!
        
        uploadData = (self.musicImage.image?.jpegData(compressionQuality: 0.4))!
        
        
        
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
    
    func getVideoDuration() async -> Double{
        let avplayeritem = AVPlayerItem(url: musicPath! as URL)
        
        let totalSeconds = try? await avplayeritem.asset.load(.duration).seconds
        return totalSeconds ?? 0
    }
    
    func uploadMusicModelOnFirebase(musicModel : MusicModel){
        ProgressHUDShow(text: "")
        try? Firestore.firestore().collection("Categories").document(catModel!.id ?? "123").collection("Musics").document(musicModel.id ?? "123").setData(from: musicModel) { error in
            self.ProgressHUDHide()
            if let error = error {
                self.showError(error.localizedDescription)
            }
            else {
                self.showSnack(messages: "Music Added")
                
                let sfReference = Firestore.firestore().collection("Categories").document(self.catModel!.id ?? "123")

                Firestore.firestore().runTransaction({ (transaction, errorPointer) -> Any? in
                    let sfDocument: DocumentSnapshot
                    do {
                        try sfDocument = transaction.getDocument(sfReference)
                    } catch let fetchError as NSError {
                        errorPointer?.pointee = fetchError
                        return nil
                    }

                    guard let oldTracks = sfDocument.data()?["tracks"] as? Int else {
                        let error = NSError(
                            domain: "AppErrorDomain",
                            code: -1,
                            userInfo: [
                                NSLocalizedDescriptionKey: "Unable to retrieve tracks from snapshot \(sfDocument)"
                            ]
                        )
                        errorPointer?.pointee = error
                        return nil
                    }

                    // Note: this could be done without a transaction
                    //       by updating the population using FieldValue.increment()
                    transaction.updateData(["tracks": oldTracks + 1], forDocument: sfReference)
                    return nil
                }) { (object, error) in
                    
                    self.dismiss(animated: true)
                   
                }
                
            }
        }
    }
}

extension AddMusicViewController : UITextFieldDelegate, UITextViewDelegate {
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.view.endEditing(true)
        return true
    }
    
}

extension AddMusicViewController : UIDocumentPickerDelegate{
    func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentsAt urls: [URL]) {
        musicPath = urls[0]
        self.addMusicLabel.text  = "Music Added"
        self.addMusicView.layer.backgroundColor = UIColor(red: 152/255, green: 198/255, blue: 106/255, alpha: 1).cgColor
        
        
        
        
    }
    
    func uploadMusicOnFirebase(musicId : String,completion : @escaping (String) -> Void ) {
        var downloadUrl = ""
        
        
        let storage = Storage.storage().reference().child("Musics").child(musicId).child("\(musicId).mp3")
        
        
        let metadata = StorageMetadata()
        //specify MIME type
        
        metadata.contentType = "audio/mp3"
        
        if let musicData = try? NSData(contentsOf: musicPath!, options: .mappedIfSafe) as Data {
            
            storage.putData(musicData, metadata: metadata) { metadata, error in
                
                if error == nil {
                    storage.downloadURL { (url, error) in
                        if error == nil {
                            downloadUrl = url!.absoluteString
                        }
                        completion(downloadUrl)
                        
                    }
                }
                else {
                    print(error!.localizedDescription)
                    completion(downloadUrl)
                }
            }
        }
        else {
            completion(downloadUrl)
            self.showSnack(messages: "ERROR")
        }
    }
}
