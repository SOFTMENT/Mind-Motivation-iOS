//
//  MusicViewController.swift
//  Mind Motivations
//
//  Created by Vijay Rathore on 14/10/22.
//

import UIKit
import Firebase
import FirebaseFirestore
import FirebaseFirestoreSwift

class MusicViewController : UIViewController {
    
    @IBOutlet weak var notificationView: UIView!
    @IBOutlet weak var searchBar: UITextField!
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var no_categories_available: UILabel!
    var categoryModels = Array<CategoryModel>()
    
    override func viewDidLoad() {
       
        
        notificationView.dropShadow()
        notificationView.layer.cornerRadius = 8
        notificationView.isUserInteractionEnabled = true
        notificationView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(notificationBtnClicked)))
        
        searchBar.changePlaceholderColour()
        searchBar.setLeftPaddingPoints(16)
        searchBar.setRightPaddingPoints(10)
        searchBar.layer.cornerRadius = 8
        searchBar.delegate = self
        searchBar.setLeftView(image: UIImage.init(named: "search")!)
        
        collectionView.delegate = self
        collectionView.dataSource = self
        let flowLayout = UICollectionViewFlowLayout()
        let width = self.collectionView.bounds.width
        flowLayout.itemSize = CGSize(width: (width / 2) - 10 , height: CGFloat(234))
        flowLayout.scrollDirection = UICollectionView.ScrollDirection.vertical
        flowLayout.minimumInteritemSpacing = 0
        self.collectionView.collectionViewLayout = flowLayout
        
        //GETCATEGORY
        getAllCategories()
    }
    
    @objc func notificationBtnClicked(){
        performSegue(withIdentifier: "notificationSeg", sender: nil)
    }
    
    @objc func categoryClicked(value : MyGesture){
        
        performSegue(withIdentifier: "playlistseg", sender: categoryModels[value.index])
        
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "playlistseg" {
            if let vc = segue.destination as? PlayListViewController {
                if let categoryModel = sender as? CategoryModel {
                    vc.categoryModel = categoryModel
                }
            }
        }
    }
    
    func getAllCategories(){
        
        ProgressHUDShow(text: "")
        Firestore.firestore().collection("Categories").order(by: "createDate", descending: true).addSnapshotListener { snapshot, error in
            self.ProgressHUDHide()
            if let error = error {
                self.showError(error.localizedDescription)
            }
            else {
                
                self.categoryModels.removeAll()
                if let snapshot = snapshot, !snapshot.isEmpty {
                    for qdr in snapshot.documents {
                        if let categoryModel = try? qdr.data(as: CategoryModel.self) {
                            self.categoryModels.append(categoryModel)
                        }
                    }
                }
                
                self.collectionView.reloadData()
                
            }
        }
    }
}

extension MusicViewController : UITextFieldDelegate {
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.view.endEditing(true)
        return true
    }
}


extension MusicViewController : UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        let width = self.collectionView.bounds.width
        return CGSize(width: (width / 2) - 10, height: 234)
        
        
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
 
        self.no_categories_available.isHidden = categoryModels.count > 0 ? true : false
        
        
        return categoryModels.count

    }
    
    
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        if let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "musiccell", for: indexPath) as? MusicCollectionViewCell {
            
            cell.mView.layer.cornerRadius = 12
         
            cell.categoryImage.layer.masksToBounds = true
            DispatchQueue.main.async {
                cell.categoryImage.roundCorners(corners: [.topLeft,.topRight], radius: 12)
            }
           
            let myGest = MyGesture(target: self, action: #selector(categoryClicked(value:)))
            myGest.index = indexPath.row
            cell.mView.isUserInteractionEnabled = true
            cell.mView.addGestureRecognizer(myGest)
            
            let categoryModel = categoryModels[indexPath.row]
            cell.title.text = categoryModel.title ?? "ERROR"
            cell.totalTracks.text = "\(categoryModel.tracks ?? 0) Tracks"
            
            if let sImage = categoryModel.thumbnail, !sImage.isEmpty {
                cell.categoryImage.sd_setImage(with: URL(string: sImage), placeholderImage: UIImage(named: "placeholder"))
            }
            
            cell.layoutIfNeeded()
        
            return cell
            
            
        }
        
        
        
        return MusicCollectionViewCell()
        
        
        
    }
    
}






