//
//  FullScreenImageViewController.swift
//  TapPresentImage
//
//  Created by Kyle Shin on 4/20/18.
//  Copyright © 2018 Kyle Shin. All rights reserved.
//

import UIKit

class SecondViewController: UIViewController {

    
    @IBOutlet var pictureImage: UIImageView!
    var image: UIImage?
    var useInteractiveDismiss = false
    
    @IBOutlet var scrollView: UIScrollView!
    
    @IBOutlet var dismissButton: UIButton!
    
    override var prefersStatusBarHidden: Bool{
        return true
    }

    //MARK:- View Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupImageScrolView()
        setupTapGesture()
        setupPanGesture()
    }
    
    //hiding the image here instead of pan gesture state .began and .ended
    //will create a smoother animation during pan gesture interactive dismiss
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        pictureImage.isHidden = false
        showHUD(true)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        pictureImage.isHidden = useInteractiveDismiss ? true : false
    }
    
    override func viewWillLayoutSubviews() {
        setZoomForSize(scrollView.bounds.size)
    }
        
    //MARK:- ScrollView and Image Setup
    
    
    func setupImageScrolView(){
        pictureImage.contentMode = .scaleAspectFit
        pictureImage.image = image
        
        pictureImage.clipsToBounds = true
        scrollView.delegate = self
        scrollView.contentInsetAdjustmentBehavior = .never
        if let imageSize = pictureImage.image?.size {
            scrollView.contentSize = imageSize
            setZoomForSize(scrollView.bounds.size)
        }
    }
    
    func setZoomForSize(_ scrollViewSize: CGSize){
        let imageSize = pictureImage.bounds.size
        let widthScale = scrollViewSize.width / imageSize.width
        let heightScale = scrollViewSize.height / imageSize.height
        let minScale = min(heightScale, widthScale)
        
        scrollView.minimumZoomScale = minScale
        scrollView.maximumZoomScale = 3.0
        scrollView.zoomScale = minScale
    }
    
    private func setupTapGesture(){
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleTap(gesture:)))
        scrollView.addGestureRecognizer(tapGesture)
    }
    
    
    @objc private func handleTap(gesture: UITapGestureRecognizer){
        if scrollView.zoomScale != 1.0 {
            UIView.animate(withDuration: 0.3) {
                self.scrollView.zoomScale = 1.0
                self.showHUD(true)
            }
        }else{
            dismissButton.alpha < 1.0 ? showHUD(true) : showHUD(false)
        }
    }
    
    // This method hides or display the HUD. For this example, we only have the dismiss button.
    // A more robust app would likely include a description label, upvote button, and share button.
    // Placing all items in one or two stack view would be a way to manage them.
    private func showHUD(_ isVisible: Bool){
        
        UIView.animate(withDuration: 0.3) {
            
            let alphaValue:CGFloat = isVisible ? 1.0 : 0.0
            self.dismissButton.alpha = alphaValue
        }
    }
    
    
    @IBAction func handleDismiss(_ sender: Any) {
        
        if let delegate = transitioningDelegate as? TransitionDelegate {
            delegate.useInteractiveDismiss = false
            dismiss(animated: true, completion: nil)
        }
    }
}

extension SecondViewController: UIScrollViewDelegate {
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return pictureImage
    }
    
    func scrollViewDidZoom(_ scrollView: UIScrollView) {
        if !dismissButton.isHidden{
            showHUD(false)
        }
    }
}


//MARK:- Pan Gesture
extension SecondViewController{
    private func setupPanGesture(){
        let panGesture = UIPanGestureRecognizer(target: self, action: #selector(handlePan(gesture:)))
        scrollView.addGestureRecognizer(panGesture)
    }
    
    //will try to use this as interactive
    @objc func handlePan(gesture: UIPanGestureRecognizer){
        //we will only handle pan when zoomScale is 1
        guard scrollView.zoomScale == 1.0 else { return }
        
        guard transitionCoordinator == nil else { return }
        
        if gesture.state == .began {
            
            if let delegate = transitioningDelegate as? TransitionDelegate {
                //Instead of hiding the image here, we set useInteractiveDismiss to true
                //and viewWillDisappear will hide the image. This would create a smoother
                // animation
                useInteractiveDismiss = true
                delegate.useInteractiveDismiss = true
                delegate.panGesture = gesture
                
                showHUD(false)
                
                delegate.dismissVelocity = getGestureVelocity(panGesture: gesture)

                dismiss(animated: true)
                beginInteractiveTransitionIfPossible(gesture: gesture)
            }else if gesture.state == .changed {
                beginInteractiveTransitionIfPossible(gesture: gesture)
            }
        }
    }
    
    func beginInteractiveTransitionIfPossible(gesture: UIPanGestureRecognizer){

        transitionCoordinator?.animate(alongsideTransition: nil, completion: { (context) in

            if (context.isCancelled && gesture.state == .changed) {
                if let delegate = self.transitioningDelegate as? TransitionDelegate {
                    delegate.dismissVelocity = self.getGestureVelocity(panGesture: gesture)
                    self.dismiss(animated: true, completion: nil)
                    self.beginInteractiveTransitionIfPossible(gesture: gesture)
                }
            }
        })
    }
    
    private func getGestureVelocity(panGesture: UIPanGestureRecognizer) -> CGFloat{
        //get the direction by checking the sign of y in velocity
        let velocity = panGesture.velocity(in: scrollView)
        return velocity.y
    }
}



