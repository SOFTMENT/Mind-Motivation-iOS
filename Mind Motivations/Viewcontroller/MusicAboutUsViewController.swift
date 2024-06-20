//
//   MusicAboutUsViewController.swift
//  Mind Motivations
//
//  Created by Vijay Rathore on 05/12/22.
//

import UIKit

class MusicAboutUsViewController : UIViewController {

    @IBOutlet weak var closeView: UIImageView!
    @IBOutlet weak var aboutUsLabel: UILabel!
    var aboutUsText : String?
    
    @IBOutlet weak var aboutView: UIView!
    override func viewDidLoad() {
        guard let aboutUsText = aboutUsText else {
            DispatchQueue.main.async {
                self.dismiss(animated: true)
            }
            return
        }
        aboutUsLabel.text = aboutUsText
        aboutView.layer.cornerRadius = 8
        
        closeView.isUserInteractionEnabled = true
        closeView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(closeViewBtnClicked)))
    }
    
    @objc func closeViewBtnClicked(){
        self.dismiss(animated: true)
    }
}
