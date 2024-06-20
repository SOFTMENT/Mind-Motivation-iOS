//
//  ShowAlbumMusicsController.swift
//  Mind Motivations
//
//  Created by Vijay Rathore on 18/11/22.
//

import UIKit
import Firebase
import FirebaseFirestore
import FirebaseFirestoreSwift

class ShowAlbumMusicsController : UIViewController {
    
    @IBOutlet weak var backView: UIImageView!
    
    @IBOutlet weak var albumName: UILabel!
    
    @IBOutlet weak var trashBtn: UIView!
    
    @IBOutlet weak var tableView: UITableView!
    
    @IBOutlet weak var no_musics_available: UILabel!
    
    var albumModel : AlbumModel?
    var musicModels = Array<MusicModel>()
   
    override func viewDidLoad() {
        
        guard let albumModel = albumModel else {
            DispatchQueue.main.async {
                self.dismiss(animated: true)
                
            }
            return
        }
        
        albumName.text = albumModel.name ?? "ERROR"
        
        tableView.dataSource = self
        tableView.delegate = self
        
        backView.isUserInteractionEnabled = true
        backView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(backViewPressed)))
        
        trashBtn.isUserInteractionEnabled = true
        trashBtn.layer.cornerRadius = 8
        trashBtn.dropShadow()
        trashBtn.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(deleteAlbum)))
        
        //ALBUMID
        getAllMusics(albumId: albumModel.id ?? "123")
        
    }
    
    
    func getAllMusics(albumId : String) {
        ProgressHUDShow(text: "")
        Firestore.firestore().collection("Users").document(Auth.auth().currentUser!.uid).collection("Favorites").order(by: "createDate",descending: true).whereField("albumId", isEqualTo: albumId).addSnapshotListener { snapshot, error in
         
            if let error = error {
                self.ProgressHUDHide()
                self.showError(error.localizedDescription)
            }
            else {
                self.musicModels.removeAll()
                if let snapshot = snapshot, !snapshot.isEmpty {
                    for qdr in snapshot.documents {
                        if let favModel = try? qdr.data(as: FavouriteModel.self) {
                            Firestore.firestore().collection("Categories").document(favModel.catId ?? "123").collection("Musics").whereField("id", isEqualTo: favModel.musicId ?? "123").getDocuments { snapshot, error in
                                self.ProgressHUDHide()
                                if error == nil {
                                    if let snapshot = snapshot , !snapshot.isEmpty {
                                        if let musicModel = try? snapshot.documents.first!.data(as: MusicModel.self) {
                                            self.musicModels.append(musicModel)
                                        }
                                    }
                                    self.no_musics_available.isHidden = self.musicModels.count > 0 ? true : false
                                    self.tableView.reloadData()
                                }
                                
                            }
                        }
                        else {
                            self.ProgressHUDHide()
                        }
                    }
                    
                }
                else {
                    self.ProgressHUDHide()
                }
                
            }
        }
    }
    
    @objc func deleteAlbum(){
        
        let alert = UIAlertController(title: "DELETE ALBUM", message: "Are you sure you want to delete this album?", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Delete", style: .destructive,handler: { action in
            self.ProgressHUDShow(text: "Deleting...")
            Firestore.firestore().collection("Users").document(Auth.auth().currentUser!.uid).collection("Albums").document(self.albumModel!.id ?? "123").delete { error in
                self.ProgressHUDHide()
                if let error = error {
                    self.showError(error.localizedDescription)
                }
                else {
                    self.showSnack(messages: "Deleted")
                    DispatchQueue.main.asyncAfter(deadline: .now() + 1.4) {
                        self.dismiss(animated: true)
                    }
                }
            }
        }))
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        present(alert, animated: true)
    }
    
    @objc func backViewPressed(){
        self.dismiss(animated: true)
    }
    @objc func musicCellClicked(value : MyGesture){
        performSegue(withIdentifier: "favMusicSeg", sender: value.index)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "favMusicSeg" {
            if let vc = segue.destination as? PlayMusicViewController {
                if let index = sender as? Int {
                    vc.position = index
                    vc.musicModels = musicModels
                }
            }
        }
    }
    @objc func setFav(value : MyGesture){

        if let user = Auth.auth().currentUser {

            ProgressHUDShow(text: "")
            checkFavoritesStatus(uid: user.uid, musicId: value.id) { isFav in
                self.ProgressHUDHide()
                if isFav {
                     value.musicCell!.favImage.image = UIImage(named: "love")
                    
                    
                            Firestore.firestore().collection("Users").document(Auth.auth().currentUser!.uid).collection("Favorites").whereField("musicId", isEqualTo: value.id).getDocuments { snapshot, error in
                               
                                if error == nil {
                                    
                                    if let snapshot = snapshot , !snapshot.isEmpty {
                                        
                                        if let favModel = try? snapshot.documents.first!.data(as: FavouriteModel.self) {
                                          
                                            self.updateAlbumTracks(albumId: favModel.albumId ?? "123", count: -1)
                                        }
                                    }
                                }
                                
                                self.deleteFav(by: value.id, uid: user.uid) { response in
                                    if !response {
                                        value.musicCell!.favImage.image = UIImage(named : "love-2")
                                        
                                    }
                                }
                                                
                    }
                }
             
            }
        }
        
        
    }
    
    func updateAlbumTracks(albumId : String,count : Int){
        let sfReference = Firestore.firestore().collection("Users").document(Auth.auth().currentUser!.uid).collection("Albums").document(albumId)

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
            transaction.updateData(["tracks": oldTracks + count], forDocument: sfReference)
            return nil
        }) { (object, error) in
            
           
        }
        
    }
    
}

extension ShowAlbumMusicsController : UITableViewDelegate , UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return musicModels.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if let cell = tableView.dequeueReusableCell(withIdentifier: "playlistcell", for: indexPath) as? PlaylistTableViewCell{
            
            cell.mImage.layer.cornerRadius = 12
            cell.favView.layer.cornerRadius = cell.favView.bounds.width / 2
            
            let musicModel = musicModels[indexPath.row]
            
            cell.musicName.text = musicModel.title ?? "ERROR"
            cell.musicTrack.text = "\(self.convertSecondstoMinAndSec(totalSeconds: musicModel.duration ?? 0)) min"
            
            cell.mView.isUserInteractionEnabled = true
            let myTap = MyGesture(target: self, action: #selector(musicCellClicked(value: )))
            myTap.index = indexPath.row
            cell.mView.addGestureRecognizer(myTap)
            
            cell.favView.isUserInteractionEnabled  = true
            let favTap = MyGesture(target: self, action: #selector(setFav(value: )))
            favTap.musicCell = cell
            favTap.id = musicModel.id ?? "123"
            cell.favView.addGestureRecognizer(favTap)
    
            self.checkFavoritesStatus(uid: UserData.data!.uid ?? "123", musicId: musicModel.id ?? "123") { isFav in
                if isFav {
                    cell.favImage.image = UIImage(named: "love-2")
                }
                else {
                    cell.favImage.image = UIImage(named: "love")
                }
            }
            
            if let thumbnail = musicModel.thumbnail, !thumbnail.isEmpty {
                cell.mImage.sd_setImage(with: URL(string: thumbnail), placeholderImage: UIImage(named: "placeholder"))
            }
            
            return cell
        }
        return PlaylistTableViewCell()
    }
    
    
    
    
}
