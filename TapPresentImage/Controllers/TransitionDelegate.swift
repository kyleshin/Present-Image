//
//  TransitionDelegate.swift
//  TapPresentImage
//
//  Created by Kyle Shin on 4/26/18.
//  Copyright © 2018 Kyle Shin. All rights reserved.
//

import UIKit

class TransitionDelegate:NSObject, UIViewControllerTransitioningDelegate {
    
    var imageView: UIImageView?
    var panGesture: UIPanGestureRecognizer?
    var useInteractiveDismiss: Bool = false
    var dismissVelocity: CGFloat = 1.0
    
    //MARK:-
    func animationController(forPresented presented: UIViewController, presenting: UIViewController, source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        
        if let tappedImageView = imageView{
            let animator = ImageTransitionAnimator()
            animator.tappedImageView = tappedImageView
            return animator
        }else{
            return nil
        }
    }
    
    //This example employs two types of dismiss: a non-interactive dismiss(tap dismiss button) and the
    //interactive version which uses pan gesture
    func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        
        if !useInteractiveDismiss{
            return nil
        }else{
            let animator = ImageTransitionAnimator()
            animator.presenting = false
            animator.isDismissInteractive = true
            animator.tappedImageView = imageView
            animator.dismissVelocity = dismissVelocity
            return animator
        }
    }
    
    //MARK:-
    
    //Presenting Interactive Transition
    //For our example, the presenting is not interactive, so we return nil
    func interactionControllerForPresentation(using animator: UIViewControllerAnimatedTransitioning) -> UIViewControllerInteractiveTransitioning? {
        return nil
    }
    
    //dismiss interaction
    func interactionControllerForDismissal(using animator: UIViewControllerAnimatedTransitioning) -> UIViewControllerInteractiveTransitioning? {
        
        if !useInteractiveDismiss || panGesture == nil{
            return nil
        }else{
            let interactiveController = InteractiveTransitionController()
            interactiveController.panGesture = panGesture
            return interactiveController
        }
    }
    
}
