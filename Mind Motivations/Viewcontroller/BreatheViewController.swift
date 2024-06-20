//
//  BreatheViewController.swift
//  Mind Motivations
//
//  Created by Vijay Rathore on 11/11/22.
//

import UIKit

class BreatheViewController : UIViewController {
    
    @IBOutlet weak var volumeOnOffBtn: UIImageView!
    @IBOutlet weak var playBtn: UIImageView!
    @IBOutlet weak var breatheInOutLabel: UILabel!
    var timer = Timer()
    
    @IBOutlet weak var circleView: UIImageView!
    
    override func viewDidLoad() {
        
        
        playBtn.isUserInteractionEnabled = true
        playBtn.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(playBreethe)))
        
        circleView.isUserInteractionEnabled = true
        circleView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(playBreethe)))
        
        volumeOnOffBtn.isUserInteractionEnabled = true
        volumeOnOffBtn.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(volumneBtnTapped)))
        
        
    }
    

    
    override func viewWillDisappear(_ animated: Bool) {
        if MyAudioPlayer.sharedInstance.isBrathePlaying() ?? false {
            MyAudioPlayer.sharedInstance.stopBreathe()
            playBtn.image = UIImage(named: "play-button")
            MyAudioPlayer.sharedInstance.chnageBackgroundVolume(mVolume: 0.8)
            timer.invalidate()
        }
       
    }
    
    func updateCounting(){
        if let count = MyAudioPlayer.sharedInstance.getCurrentTimeForBreathe() {
           
           
            if (count == 0 || count == 15 || count == 31 || count == 46) {
                breatheInOutLabel.text = "Breathe\nIn"
            
            }
            else if (count == 9 || count == 24 || count == 40 || count == 56) {
                breatheInOutLabel.text = "Breathe\nOut"
            
            }
            else if (count == 5 || count == 20 || count == 36 || count == 49) {
                breatheInOutLabel.text = "Hold"
            
            }
        }
    }
    
    @objc func volumneBtnTapped(){
        if let volume =  MyAudioPlayer.sharedInstance.breathVolume(), volume == 0 {
            volumeOnOffBtn.image = UIImage(named: "volume-2")
            MyAudioPlayer.sharedInstance.chnageBreatheVolume(mVolume: 0.9)
        }
        else {
            volumeOnOffBtn.image = UIImage(named: "silent")
            MyAudioPlayer.sharedInstance.chnageBreatheVolume(mVolume: 0)
        }
    }
    
    @objc func playBreethe(){
        if let isPlaying = MyAudioPlayer.sharedInstance.isBrathePlaying(), isPlaying {
            MyAudioPlayer.sharedInstance.stopBreathe()
            playBtn.image = UIImage(named: "play-button")
            MyAudioPlayer.sharedInstance.chnageBackgroundVolume(mVolume: 0.8)
            timer.invalidate()
        }
        else {
            self.timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true, block: { _ in
                self.updateCounting()
               })
            
            MyAudioPlayer.sharedInstance.chnageBackgroundVolume(mVolume: 0.2)
            MyAudioPlayer.sharedInstance.playBreathe()
            playBtn.image = UIImage(named: "pause-2")
        }
    }
}
