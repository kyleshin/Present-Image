//
//  InteractiveTransitionAnimator.swift
//  TapPresentImage
//
//  Created by Kyle Shin on 4/27/18.
//  Copyright © 2018 Kyle Shin. All rights reserved.
//

import UIKit

class InteractiveTransitionController: UIPercentDrivenInteractiveTransition {
    
    var panGesture:UIPanGestureRecognizer?
    var transitionContext: UIViewControllerContextTransitioning?
    
    //we need to handle the case where user pan changes direction
    //and crosses the initial touch point.
    var initialLocation:CGPoint?
    var initialTranslation:CGPoint?
    
    override func startInteractiveTransition(_ transitionContext: UIViewControllerContextTransitioning) {
        super.startInteractiveTransition(transitionContext)
        //save transitionContext for later use
        //Usually try not to use self when not necessary, but this case
        //using self increase clarity.
        self.transitionContext = transitionContext
        //create pan gesture to monitor events
        panGesture?.addTarget(self, action: #selector(handlePanGesture(_:)))
        initialTranslation = panGesture?.translation(in: transitionContext.containerView)
    }
    
    @objc func handlePanGesture(_ panGesture:UIPanGestureRecognizer){
        
        let progress = calculatePercentComplete(panGesture: panGesture)
        
        switch panGesture.state
        {
            
        case .changed:
            
            //we need to handle the case where user pan one direction and reverse direction beyond the initial point of touch
            //progress would return -1 under that case.
            if progress < 0.0 {
                cancel()
                panGesture.removeTarget(self, action: #selector(handlePanGesture(_:)))
            }else{
                update(progress)
            }
            
        case .ended, .cancelled:
            let velocity = panGesture.velocity(in: panGesture.view?.superview)
            //If velocity is sufficiently large, then we finish the animation.
            //You may want to experiment to get a value that feels right.
            if abs(velocity.y) > 200 {
                finish()
            }else{
                if progress < 0.3 {
                    cancel()
                }else{
                    finish()
                }
            }
        default:
            //something went wrong.
            cancel()
        }
    }
    
    //return value of -1 would cancel the interaction
    private func calculatePercentComplete(panGesture:UIPanGestureRecognizer) -> CGFloat{
        
        let transitionContainerView =  transitionContext?.containerView
        
        let translation = panGesture.translation(in: transitionContainerView)
        
        let floatZero: CGFloat = 0.0
        guard let initialTranslation_y = initialTranslation?.y else { return -1 }
        if (initialTranslation_y > floatZero && translation.y < floatZero ) || (initialTranslation_y < floatZero && translation.y > floatZero ){
            //switched direction
            return -1
        }
        
        guard let viewHeight = transitionContainerView?.bounds.height else { return -1 }
        let progress: CGFloat = abs(translation.y / viewHeight  )
        return min(progress,1)
    }
    
    
}
