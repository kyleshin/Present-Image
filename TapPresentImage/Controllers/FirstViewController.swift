//
//  ViewController.swift
//  TapPresentImage
//
//  Created by Kyle Shin on 4/20/18.
//  Copyright © 2018 Kyle Shin. All rights reserved.
//

import UIKit
import AVKit

class FirstViewController: UIViewController{

    @IBOutlet var mainImageView: UIImageView!
    @IBOutlet var tapImageLabel: UILabel!

    let customTransitionDelegate = TransitionDelegate()
    
    //The animation would work for both landscape or portrait image. Try it yourself by picking
    //different testImage
    let testImage = UIImage(named: "landscape")
//    let testImage = UIImage(named: "portrait")
    
    override var prefersStatusBarHidden: Bool{
        return true
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupImageView()
    }
    
    //MARK:- Setup mainImageView
    private func setupImageView(){
        
        //add tap gesture
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(imagedTapped(_:)))
        mainImageView.addGestureRecognizer(tapGesture)
        
        //default value for isUserInteractionEnabled is false. Tap won't work until
        //it is set to true (can also do this in storyboard)
        mainImageView.isUserInteractionEnabled = true
        mainImageView.contentMode = .center
        
        guard let image = testImage else { return }
        let scaledImage = scaleImageToSize(image: image)
        mainImageView.image = scaledImage
    }
    
    private func scaleImageToSize(_ size: CGSize? = nil,image:UIImage) -> UIImage?{

        //We need a new image sized to the target rect, while maintaining
        //the original aspect ratio. AVKit has a handy method that returns such a rect.
        //You can also calculate it yourself without using AVKit.
        let aspectRatio = image.size
        
        let boundingRect = size != nil ? CGRect(origin: CGPoint.zero, size: size!) : self.view.convert(self.view.bounds, to: nil)
        
        let targetFrame = AVMakeRect(aspectRatio: aspectRatio, insideRect: boundingRect)
        let newSize = targetFrame.size
        UIGraphicsBeginImageContextWithOptions(newSize, false, 0)
        image.draw(in: CGRect(origin: CGPoint.zero, size: newSize))

        let scaledImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return scaledImage
    }

    
    
    //This is for using ImageTransition.
    @objc func imagedTapped(_ gesture: UITapGestureRecognizer){
        
        //we prepare the view controller for the transition
        mainImageView.isUserInteractionEnabled = false
        mainImageView.isHidden = true
        
        guard let secondVC = self.storyboard?.instantiateViewController(withIdentifier: "SecondViewController") as? SecondViewController  else {
            return
        }
        //setting this provides more accurate initial and final frame
        secondVC.modalPresentationStyle = .fullScreen
        secondVC.modalTransitionStyle = .crossDissolve
        secondVC.image = mainImageView.image
        customTransitionDelegate.imageView = mainImageView
        
        secondVC.transitioningDelegate = customTransitionDelegate
        transitioningDelegate = customTransitionDelegate
        
        self.present(secondVC, animated: true) {
            //return to normal state
            self.mainImageView.isUserInteractionEnabled = true
            self.mainImageView.isHidden = false
        }
    }
    
    //MARK:- Rotation
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        
        guard let image = testImage else { return }
        let scaledImage = scaleImageToSize(size,image: image)
        mainImageView.image = scaledImage
    }
    
    
    
}
