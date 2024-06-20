//
//  AdminMusicViewController.swift
//  Mind Motivations
//
//  Created by Vijay Rathore on 19/11/22.
//

import UIKit
import SDWebImage
import Firebase
import FirebaseFirestore
import FirebaseFirestoreSwift

class AdminMusicViewController : UIViewController {
    
    @IBOutlet weak var addMusicView: UIView!
    
    @IBOutlet weak var backView: UIImageView!
    
    @IBOutlet weak var tableView: UITableView!

    @IBOutlet weak var no_musics_available: UILabel!
    
    
    @IBOutlet weak var categoryName: UILabel!
    
    var musicModels = Array<MusicModel>()
    var categoryModel : CategoryModel?
    

    override func viewDidLoad() {
        
        guard let categoryModel = categoryModel else {
            DispatchQueue.main.async {
                self.dismiss(animated: true)
            }
            return
        }
        
        backView.isUserInteractionEnabled = true
        backView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(backViewClicked)))
        
        addMusicView.layer.cornerRadius = 8
        addMusicView.dropShadow()
        addMusicView.isUserInteractionEnabled = true
        addMusicView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(addMusicViewController)))
        
        tableView.dataSource = self
        tableView.delegate = self
        
        categoryName.text = categoryModel.title ?? "ERROR"
        
        //GETMUSIC
        getAllMusics()
        
    }
    
    func getAllMusics() {
        ProgressHUDShow(text: "")
        Firestore.firestore().collection("Categories").document(categoryModel!.id ?? "123").collection("Musics").order(by: "createdDate", descending: true).addSnapshotListener { snapshot, error in
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
    @objc func addMusicViewController(value : MyGesture){
        performSegue(withIdentifier: "addMusicSeg", sender: nil)
    }
    
    @objc func musicCellClicked(value : MyGesture){
        performSegue(withIdentifier: "updateMusicSeg", sender: self.musicModels[value.index])
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "updateMusicSeg" {
            if let vc = segue.destination as? AdminEditMusicViewController {
                if let musicModel = sender as? MusicModel {
                    vc.musicModel = musicModel
                }
            }
        }
        else if segue.identifier == "addMusicSeg" {
            if let vc = segue.destination as? AddMusicViewController {
                vc.catModel = categoryModel
            }
        }
    }
    
    @objc func backViewClicked(){
        
        self.dismiss(animated: true)
    }
    
    
    
}


extension AdminMusicViewController : UITableViewDelegate , UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        self.no_musics_available.isHidden = musicModels.count > 0 ? true : false
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
    
            
            if let thumbnail = musicModel.thumbnail, !thumbnail.isEmpty {
                cell.mImage.sd_setImage(with: URL(string: thumbnail), placeholderImage: UIImage(named: "placeholder"))
            }
            
            return cell
        }
        return PlaylistTableViewCell()
    }
    
    
    
    
}
