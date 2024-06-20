//
//  FavouritesViewController.swift
//  Mind Motivations
//
//  Created by Vijay Rathore on 19/10/22.
//

import UIKit
import Firebase
import FirebaseFirestoreSwift

class FavouritesViewController : UIViewController {
    
    @IBOutlet weak var no_album_available: UIStackView!
    @IBOutlet weak var addAlbumView: UIView!
    
    @IBOutlet weak var tableView: UITableView!
    var albumModels = Array<AlbumModel>()
    override func viewDidLoad() {
        
   
        tableView.dataSource = self
        tableView.delegate = self
        
        addAlbumView.layer.cornerRadius = 8
        addAlbumView.dropShadow()
        addAlbumView.isUserInteractionEnabled = true
        addAlbumView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(createAlbumClicked)))
        getAllAlbum()
        
    }
    
    func getAllAlbum(){
        
        Firestore.firestore().collection("Users").document(Auth.auth().currentUser!.uid).collection("Albums").order(by: "name").addSnapshotListener { snapshot, error in
            if error == nil {
                self.albumModels.removeAll()
                if let snapshot = snapshot, !snapshot.isEmpty {
                    for qdr in snapshot.documents {
                        if let albumModel = try? qdr.data(as: AlbumModel.self) {
                            self.albumModels.append(albumModel)
                        }
                    }
                }
                self.tableView.reloadData()
            }
            
        }
    }
    
    @objc func createAlbumClicked() {
        //1. Create the alert controller.
        let alert = UIAlertController(title: "Create Album", message: "Enter album name", preferredStyle: .alert)

        //2. Add the text field. You can configure it however you need.
        alert.addTextField { (textField) in
            textField.text = ""
        }

        // 3. Grab the value from the text field, and print it when the user clicks OK.
        alert.addAction(UIAlertAction(title: "Create", style: .default, handler: { [weak alert] (_) in
            let textField = alert!.textFields![0] // Force unwrapping because we know it exists.
            if let sAlbumName = textField.text?.trimmingCharacters(in: .whitespacesAndNewlines), !sAlbumName.isEmpty {
                self.createNewAlbum(name: sAlbumName)
            }
            
        }))

        // 3. Grab the value from the text field, and print it when the user clicks OK.
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))

        
        // 4. Present the alert.
        self.present(alert, animated: true, completion: nil)
    }
    
    func createNewAlbum(name : String){
        ProgressHUDShow(text: "")
        let docId = Firestore.firestore().collection("Users").document(Auth.auth().currentUser!.uid).collection("Albums").document().documentID
        let albumModel = AlbumModel()
        albumModel.id = docId
        albumModel.name = name
        albumModel.tracks = 0
        try? Firestore.firestore().collection("Users").document(Auth.auth().currentUser!.uid).collection("Albums").document(docId).setData(from: albumModel) { error in
            self.ProgressHUDHide()
            if let error = error {
                self.ProgressHUDShow(text: error.localizedDescription)
            }
            else {
                self.showSnack(messages: "Created")
            }
        }
        
    }
    
    @objc func albumCellClicked(value : MyGesture){
        performSegue(withIdentifier: "albumsongsseg", sender: albumModels[value.index])
    }
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "albumsongsseg" {
            if let vc = segue.destination as? ShowAlbumMusicsController {
                if let albumModel = sender as? AlbumModel {
                    vc.albumModel = albumModel
                }
            }
        }
    }
}
extension FavouritesViewController : UITableViewDelegate , UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if albumModels.count > 0 {
            no_album_available.isHidden = true
        }
        else {
            no_album_available.isHidden = false
        }
        return albumModels.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if let cell = tableView.dequeueReusableCell(withIdentifier: "albumcell", for: indexPath) as? AlbumTableViewCell{
            
            cell.mView.layer.cornerRadius = 12
            cell.arrowView.layer.cornerRadius = cell.arrowView.bounds.width / 2
            
            let albumModel = albumModels[indexPath.row]
            cell.mTitle.text = albumModel.name ?? "ERROR"
            cell.mTracks.text = "\(albumModel.tracks ?? 0) Tracks"
            
            cell.mView.isUserInteractionEnabled = true
            let myGest = MyGesture(target: self, action: #selector(albumCellClicked(value: )))
            myGest.index = indexPath.row
            cell.mView.addGestureRecognizer(myGest)
            
            return cell
        }
        return AlbumTableViewCell()
    }
    
    
    
    
}
