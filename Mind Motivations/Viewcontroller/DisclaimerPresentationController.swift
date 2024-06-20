//
//  DisclaimerPresentationController.swift
//  Mind Motivations
//
//  Created by Vijay Rathore on 18/11/22.
//

import UIKit
import StoreKit
import Firebase
import FirebaseAuth

class DisclaimerPresentationController : UIPresentationController{
    
    
    let blurEffectView: UIView!
    var tapGestureRecognizer: UITapGestureRecognizer = UITapGestureRecognizer()
    var isBlurBtnSelected = false
    
    
    
    
    override init(presentedViewController: UIViewController, presenting presentingViewController: UIViewController?) {
        
      
        
        
        blurEffectView = UIView()
        blurEffectView.backgroundColor = UIColor.clear
        
        super.init(presentedViewController: presentedViewController, presenting: presentingViewController)
        
        tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(self.dismissController(r:)))
        
        blurEffectView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        self.blurEffectView.isUserInteractionEnabled = true
        blurEffectView.tag = 2
        self.blurEffectView.addGestureRecognizer(tapGestureRecognizer)
        
        
    }

        
 
    override var frameOfPresentedViewInContainerView: CGRect {
        
        return CGRect(origin: CGPoint(x: 0, y: self.containerView!.frame.height - 520),
                      size: CGSize(width: self.containerView!.frame.width, height: self.containerView!.frame.height *
                                   520))
    }
    
    override func presentationTransitionWillBegin() {
        
      
        self.containerView?.addSubview(blurEffectView)
        self.presentedViewController.transitionCoordinator?.animate(alongsideTransition: { (UIViewControllerTransitionCoordinatorContext) in
            
        }, completion: { (UIViewControllerTransitionCoordinatorContext) in })
    }
    
    override func dismissalTransitionWillBegin() {
        self.presentedViewController.transitionCoordinator?.animate(alongsideTransition: { (UIViewControllerTransitionCoordinatorContext) in
            
            
        }, completion: { (UIViewControllerTransitionCoordinatorContext) in
            self.blurEffectView.removeFromSuperview()
            if !self.isBlurBtnSelected {
                self.dismissController(r: UITapGestureRecognizer())
            }
            
            
        })
    }
    
    override func containerViewWillLayoutSubviews() {
        super.containerViewWillLayoutSubviews()
        presentedView!.roundCorners(corners: [.topLeft, .topRight], radius: 50)
    }
    
    override func containerViewDidLayoutSubviews() {
        super.containerViewDidLayoutSubviews()
        presentedView?.frame = frameOfPresentedViewInContainerView
        blurEffectView.frame = containerView!.bounds
    }
    
    @objc  func dismissController(r : UITapGestureRecognizer){
        if r.view?.tag == 2 {
            isBlurBtnSelected = true
        }
        else {
            isBlurBtnSelected = false
        }
        
        self.presentedViewController.dismiss(animated: true, completion: nil)
    }
}


