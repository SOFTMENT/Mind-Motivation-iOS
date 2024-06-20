//
//  PlayListViewController.swift
//  Mind Motivations
//
//  Created by Vijay Rathore on 10/11/22.
//

import UIKit
import Firebase
import FirebaseFirestore
import FirebaseFirestoreSwift

class PlayListViewController : UIViewController {
    
    @IBOutlet weak var backView: UIImageView!
    @IBOutlet weak var categoryName: UILabel!
    
    @IBOutlet weak var totalTracks: UILabel!
    
    @IBOutlet weak var no_musics_available: UILabel!
    @IBOutlet weak var tableView: UITableView!
    var categoryModel : CategoryModel?
    var musicModels = Array<MusicModel>()
    var albumModels = Array<AlbumModel>()
    override func viewDidLoad() {
        
        guard let categoryModel = categoryModel else {
            DispatchQueue.main.async {
                self.dismiss(animated: true)
            }
            return
        }
        
        tableView.dataSource = self
        tableView.delegate = self
        
        backView.isUserInteractionEnabled = true
        backView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(backViewPressed)))
        
        categoryName.text = categoryModel.title ?? ""
        totalTracks.text = "\(categoryModel.tracks ?? 0) Tracks"
        
        //GETALLMUSICS
        getAllMusics()
    }
    func getAllMusics() {
        ProgressHUDShow(text: "")
        Firestore.firestore().collection("Categories").document(categoryModel!.id ?? "123").collection("Musics").order(by: "title").addSnapshotListener { snapshot, error in
            self.ProgressHUDHide()
            if let error = error {
                self.showError(error.localizedDescription)
            }
            else {
                self.musicModels.removeAll()
                if let snapshot = snapshot, !snapshot.isEmpty {
                    for qdr in snapshot.documents {
                        if let musicModel = try? qdr.data(as: MusicModel.self) {
                            self.musicModels.append(musicModel)
                        }
                    }
                }
                
                self.no_musics_available.isHidden = self.musicModels.count > 0 ? true : false
                
                self.tableView.reloadData()
            }
        }
    }
    @objc func backViewPressed(){
        self.dismiss(animated: true)
    }
    @objc func musicCellClicked(value : MyGesture){
        performSegue(withIdentifier: "playMusicSeg", sender: value.index)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "playMusicSeg" {
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
                else {
                    
                    self.ProgressHUDShow(text: "")
                    Firestore.firestore().collection("Users").document(Auth.auth().currentUser!.uid).collection("Albums").order(by: "name").getDocuments { snapshot, error in
                        self.ProgressHUDHide()
                        if error == nil {
                            self.albumModels.removeAll()
                            if let snapshot = snapshot, !snapshot.isEmpty {
                                for qdr in snapshot.documents {
                                    if let albumModel = try? qdr.data(as: AlbumModel.self) {
                                        self.albumModels.append(albumModel)
                                    }
                                }
                                
                                let alert = UIAlertController(title: "Select Album", message: nil, preferredStyle: .actionSheet)
                                alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
                                for albumModel in self.albumModels {
                                    alert.addAction(UIAlertAction(title: albumModel.name ?? "", style: .default,handler: { action in
                                         let index = self.albumModels.firstIndex { albumModel in
                                            if albumModel.name == action.title {
                                                return true
                                            }
                                            return false
                                        }
                                        if let index = index {
                                            value.musicCell!.favImage.image = UIImage(named :  "love-2")
                                            self.addFav(by: value.id, catId: self.categoryModel!.id ?? "123", albumId: self.albumModels[index].id ?? "123", uid: user.uid) { response in
                                                if !response {
                                                    value.musicCell!.favImage.image = UIImage(named: "love")
                                                }
                                                else {
                                                    self.updateAlbumTracks(albumId: albumModel.id ?? "123", count: 1)
                                                }

                                            }
                                        }
                                        
                                       
                                    }))
                                }
                                
                                self.present(alert, animated: true)
                                
                            }
                            else {
                                self.showSnack(messages: "No album found")
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

extension PlayListViewController : UITableViewDelegate , UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        self.no_musics_available.isHidden = musicModels.count > 0 ? true : false
        return musicModels.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if let cell = tableView.dequeueReusableCell(withIdentifier: "playlistcell", for: indexPath) as? PlaylistTableViewCell {
            
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
    
            self.checkFavoritesStatus(uid: Auth.auth().currentUser!.uid, musicId: musicModel.id ?? "123") { isFav in
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
