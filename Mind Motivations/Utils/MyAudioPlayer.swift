//
//  MyAudioPlayer.swift
//  Mind Motivations
//
//  Created by Vijay Rathore on 11/11/22.
//
import AVFoundation

class MyAudioPlayer {
    static let sharedInstance = MyAudioPlayer()
    private var playerForBackground: AVAudioPlayer?
    private var playerForBreathe: AVAudioPlayer?

    func playBackground() {
        guard let url = Bundle.main.url(forResource: "myappbackgroundmusic", withExtension: "mp3") else { return }

        do {
            try AVAudioSession.sharedInstance().setCategory(AVAudioSession.Category.playback)
            try AVAudioSession.sharedInstance().setActive(true)

            playerForBackground = try AVAudioPlayer(contentsOf: url, fileTypeHint: AVFileType.mp3.rawValue)
        

            guard let playerForBackground = playerForBackground else { return }
            playerForBackground.numberOfLoops = -1
                
            playerForBackground.play()

        } catch let error {
            print(error.localizedDescription)
        }
    }
    
    func stopBackground() {
        playerForBackground?.stop()
    }
    
    func chnageBackgroundVolume(mVolume : Float){
        playerForBackground?.volume = mVolume
    }
    
    
    func playBreathe() {
        guard let url = Bundle.main.url(forResource: "breathe", withExtension: "mp3") else { return }

        do {
            try AVAudioSession.sharedInstance().setCategory(AVAudioSession.Category.playback)
            try AVAudioSession.sharedInstance().setActive(true)

            playerForBreathe = try AVAudioPlayer(contentsOf: url, fileTypeHint: AVFileType.mp3.rawValue)

            guard let playerForBreathe = playerForBreathe else { return }
            playerForBreathe.numberOfLoops = -1
            playerForBreathe.play()

        } catch let error {
            print(error.localizedDescription)
        }
    }

    func stopBreathe() {
        playerForBreathe?.stop()
        
    }
    
    func breathVolume() -> Float? {
        
        return playerForBreathe?.volume
        
    }
    
    func chnageBreatheVolume(mVolume : Float){
        playerForBreathe?.volume = mVolume
    }
   
    func isBrathePlaying() -> Bool? {
        return playerForBreathe?.isPlaying
    }
    
    func getCurrentTimeForBreathe() -> Int? {
        return Int(playerForBreathe?.currentTime ?? 0)
    }
}
