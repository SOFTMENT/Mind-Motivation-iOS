//
//  PlayMusicViewController.swift
//  Mind Motivations
//
//  Created by Vijay Rathore on 03/12/22.
//

import UIKit
import Firebase
import FirebaseFirestoreSwift
import AVFoundation

class PlayMusicViewController : UIViewController {
    
    @IBOutlet weak var categoryName: UILabel!
    @IBOutlet weak var backView: UIImageView!
    
    @IBOutlet weak var musicImage: UIImageView!
    
    @IBOutlet weak var musicName: UILabel!
    
    @IBOutlet weak var endTime: UILabel!
    @IBOutlet weak var startTime: UILabel!
   
    @IBOutlet weak var progressbar: UISlider!
    @IBOutlet weak var genre: UILabel!
    @IBOutlet weak var artist: UILabel!
    
    @IBOutlet weak var previous: UIImageView!
    @IBOutlet weak var playPause: UIImageView!
    
    @IBOutlet weak var nextBtn: UIImageView!
    @IBOutlet weak var aboutView: UIView!
    
    @IBOutlet weak var shareBtn: UIImageView!
    
    @IBOutlet weak var favImage: UIImageView!
    var musicModels : Array<MusicModel>?
    var position : Int = 0
    var player : AVPlayer?
    var timer = Timer()

    var albumModels = Array<AlbumModel>()
    override func viewDidLoad() {
        
        guard let musicModels = musicModels else {
            DispatchQueue.main.async {
                self.dismiss(animated: true)
            }
            return
        }
        try? AVAudioSession.sharedInstance().setCategory(.playback)
        let musicModel = musicModels[position]
        musicImage.layer.cornerRadius = 8
        
        aboutView.layer.cornerRadius = 8
        
        backView.isUserInteractionEnabled = true
        backView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(backBtnClicked)))
        
        playPause.isUserInteractionEnabled = true
        playPause.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(playPauseBtnClicked)))
        
        loadUI()
        if let musicURL = musicModel.musicUrl, !musicURL.isEmpty {
            let playerItem = AVPlayerItem(url: URL(string: musicURL)!)
            self.player =  AVPlayer(playerItem:playerItem)
            
            if let pl = player, !pl.isPlaying{
                play()
            }
        }
        
        progressbar.setThumbImage(UIImage(named: "record-button"), for: .normal)
        progressbar.setThumbImage(UIImage(named: "record-button"), for: .highlighted)
        
        nextBtn.isUserInteractionEnabled = true
        nextBtn.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(nextBtnClicked)))
        
        previous.isUserInteractionEnabled = true
        previous.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(previousBtnClicked)))
        
        aboutView.isUserInteractionEnabled = true
        aboutView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(aboutViewClicked)))
        
        checkFavoritesStatus(uid: Auth.auth().currentUser!.uid, musicId: musicModel.id ?? "123") { isFav in
            if isFav {
                self.favImage.image = UIImage(named: "love-2")
            }
            else {
                self.favImage.image = UIImage(named: "love")
            }
        }
        
        favImage.isUserInteractionEnabled = true
        let favGest = MyGesture(target: self, action: #selector(setFav(value: )))
        favGest.id = musicModel.id ?? "123"
        favImage.addGestureRecognizer(favGest)
        
        shareBtn.isUserInteractionEnabled = true
        shareBtn.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(shareBtnClicked)))
    }
    
    
    
    @objc func setFav(value : MyGesture){

        let id = value.id
        
        if let user = Auth.auth().currentUser {
            
     
            ProgressHUDShow(text: "")
            checkFavoritesStatus(uid: user.uid, musicId: id) { isFav in
                self.ProgressHUDHide()
                if isFav {
                    self.favImage.image = UIImage(named: "love")
                    
                    
                            Firestore.firestore().collection("Users").document(Auth.auth().currentUser!.uid).collection("Favorites").whereField("musicId", isEqualTo: id).getDocuments { snapshot, error in
                               
                                if error == nil {
                                    
                                    if let snapshot = snapshot , !snapshot.isEmpty {
                                        
                                        if let favModel = try? snapshot.documents.first!.data(as: FavouriteModel.self) {
                                          
                                            self.updateAlbumTracks(albumId: favModel.albumId ?? "123", count: -1)
                                        }
                                    }
                                }
                                
                                self.deleteFav(by: id, uid: user.uid) { response in
                                    if !response {
                                        self.favImage.image = UIImage(named : "love-2")
                                        
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
                                            self.favImage.image = UIImage(named :  "love-2")
                                            self.addFav(by: value.id, catId: self.musicModels![self.position].catId ?? "123" , albumId: self.albumModels[index].id ?? "123", uid: user.uid) { response in
                                                if !response {
                                                    self.favImage.image = UIImage(named: "love")
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
    
    @objc func aboutViewClicked(){
        
        performSegue(withIdentifier: "musicAboutSeg", sender: nil)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "musicAboutSeg" {
            if let vc = segue.destination as? MusicAboutUsViewController {
                vc.aboutUsText = self.musicModels![self.position].about ?? ""
            }
        }
    }
    
    @IBAction func progressBarChange(_ sender: UISlider) {
        if let player = player {
            player.seek(to: CMTime(seconds: Double(sender.value), preferredTimescale: 60000), toleranceBefore: .zero, toleranceAfter: .zero)
        }
    }
    @objc func nextBtnClicked(){
        if position < musicModels!.count - 1 {
            position = position + 1
          
            loadUI()
            if let musicURL = musicModels![position].musicUrl, !musicURL.isEmpty {
                let playerItem = AVPlayerItem(url: URL(string: musicURL)!)
                self.player =  AVPlayer(playerItem:playerItem)
            
                timer.invalidate()
                play()
                
            }

        }
    }
    
    @objc func previousBtnClicked(){
        if position > 0 {
          
            position = position - 1
    
            loadUI()
            if let musicURL = musicModels![position].musicUrl, !musicURL.isEmpty {
                let playerItem = AVPlayerItem(url: URL(string: musicURL)!)
                self.player =  AVPlayer(playerItem:playerItem)
                timer.invalidate()
                play()
            }

        }
    }
    
    @objc func playPauseBtnClicked() {
        
            if let pl = player, !pl.isPlaying{
                play()
            }
            else {
                pause()
            }
        
    }
    
    func loadUI(){
        let musicModel = musicModels![position]
        if let thumbnail = musicModel.thumbnail, !thumbnail.isEmpty {
            musicImage.sd_setImage(with: URL(string: thumbnail), placeholderImage: UIImage(named: "placeholder"))
        }
        musicName.text = musicModel.title ?? ""
        artist.text = musicModel.artistName ?? ""
        genre.text = musicModel.genre ?? ""
        startTime.text = "0:0"
        categoryName.text = musicModel.catName ?? ""
        progressbar.value = 0
        progressbar.maximumValue = Float(musicModel.duration ?? 0)
        endTime.text = convertSecondstoMinAndSec(totalSeconds: musicModel.duration ?? 0)
        
    
    }
    
    func play() {
        
            MyAudioPlayer.sharedInstance.stopBackground()
        
            player!.volume = 1.0
            player!.play()
            playPause.image = UIImage(named: "pause-3")
         
           self.timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true, block: { _ in
            self.updateCounting()
           })
    }
    
    func updateCounting(){
        let duration =  Float(CMTimeGetSeconds(player!.currentTime()))
        startTime.text = convertSecondstoMinAndSec(totalSeconds: Int(duration))
        progressbar.value = duration
        
        if duration >= progressbar.maximumValue {
            
            if position < musicModels!.count - 1 {
                self.nextBtnClicked()
            }
            else {
                timer.invalidate()
                playPause.image = UIImage(named: "play-button-3")
                MyAudioPlayer.sharedInstance.playBackground()
                progressbar.value = 0
                startTime.text = "00:00"
            }
          
            
        }
    }
    
    func pause(){
        timer.invalidate()
        MyAudioPlayer.sharedInstance.playBackground()
        self.player!.pause()
        playPause.image = UIImage(named: "play-button-3")
    }
    
    @objc func backBtnClicked(){
        timer.invalidate()
        MyAudioPlayer.sharedInstance.playBackground()
        self.dismiss(animated: true)
    }
    @objc func shareBtnClicked(){
        
            let someText:String = "Check Out Mind Motivation App."
            let objectsToShare:URL = URL(string: "https://apps.apple.com/us/app/mind-motivation/1603551591")!
            let sharedObjects:[AnyObject] = [objectsToShare as AnyObject,someText as AnyObject]
            let activityViewController = UIActivityViewController(activityItems : sharedObjects, applicationActivities: nil)
            activityViewController.popoverPresentationController?.sourceView = self.view
            self.present(activityViewController, animated: true, completion: nil)
        
    }
}

