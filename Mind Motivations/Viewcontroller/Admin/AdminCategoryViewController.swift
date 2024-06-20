//
//  AdminCategoryViewController.swift
//  Mind Motivations
//
//  Created by Vijay Rathore on 19/11/22.
//

import UIKit
import Firebase
import FirebaseFirestore
import FirebaseFirestoreSwift
import SDWebImage

class AdminCategoryViewController : UIViewController {
    
    
    
    @IBOutlet weak var addCategoryView: UIView!
    
    @IBOutlet weak var no_categories_available: UILabel!
    
    @IBOutlet weak var collectionView: UICollectionView!
    var categoryModels = Array<CategoryModel>()
    override func viewDidLoad() {
        
        addCategoryView.isUserInteractionEnabled = true
        addCategoryView.dropShadow()
        addCategoryView.layer.cornerRadius = 8
        addCategoryView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(addCategoryClicked)))
        
        collectionView.delegate = self
        collectionView.dataSource = self
        let flowLayout = UICollectionViewFlowLayout()
        let width = self.collectionView.bounds.width
        flowLayout.itemSize = CGSize(width: (width / 2) - 10 , height: CGFloat(218))
        flowLayout.scrollDirection = UICollectionView.ScrollDirection.vertical
        flowLayout.minimumInteritemSpacing = 0
        self.collectionView.collectionViewLayout = flowLayout
        
        getAllCategories()
        
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
    
    @objc func addCategoryClicked(){
        performSegue(withIdentifier: "addCatSeg", sender: nil)
    }
    
    @objc func categoryClicked(value : MyGesture){
        
        let alert = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        alert.addAction(UIAlertAction(title: "Manage Musics", style: .default,handler: { action in
            self.performSegue(withIdentifier: "adminMusicSeg", sender: self.categoryModels[value.index])
        }))
        alert.addAction(UIAlertAction(title: "Edit Category", style: .default,handler: { action in
            self.performSegue(withIdentifier: "updateCatSeg", sender: self.categoryModels[value.index])
        }))
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        present(alert, animated: true)
        
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "adminMusicSeg" {
            if let VC = segue.destination as? AdminMusicViewController {
                if let categoryModel = sender as? CategoryModel {
                    VC.categoryModel = categoryModel
                }
            }
        }
            
        else if segue.identifier == "updateCatSeg" {
            if let VC = segue.destination as? AdminEditCategoryViewController {
                if let categoryModel = sender as? CategoryModel {
                    VC.catModel = categoryModel
                }
            }
        }
            
    }
}
    
    extension AdminCategoryViewController : UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
        
        func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
            
            let width = self.collectionView.bounds.width
            return CGSize(width: (width / 2) - 10, height: 218)
            
            
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



    
   
