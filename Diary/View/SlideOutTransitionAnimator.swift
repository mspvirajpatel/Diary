//
//  SlideOutTransitionAnimator.swift
//  Diary
//
//  Created by 牛苒 on 2018/3/2.
//  Copyright © 2018年 牛苒. All rights reserved.
//

import UIKit

class SlideOutTransitionAnimator: NSObject, UIViewControllerAnimatedTransitioning, UIViewControllerTransitioningDelegate {
    let duration = 0.15
    var isPresenting = false
    
    // MARK: - UIViewControllerAnimatedTransitioning
    
    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return duration
    }
    
    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        // Get reference to our fromView, toView and the container view
        guard let fromView = transitionContext.view(forKey: UITransitionContextViewKey.from) else {
            return
        }
        
        guard let toView = transitionContext.view(forKey: UITransitionContextViewKey.to) else {
            return
        }
        
        // Set up the transform we'll use in the animation
        let container = transitionContext.containerView
        let offScreenLeft = CGAffineTransform(translationX: -container.frame.width, y: 0)
//        let offScreenDown = CGAffineTransform(translationX: container.frame.width, y: 0)
        
        // Make the toView off screen
        if isPresenting {
            toView.transform = offScreenLeft
        }
        
        // Add both views to the container view
        if isPresenting {
            container.addSubview(fromView)
            container.addSubview(toView)
        } else {
            container.addSubview(toView)
            container.addSubview(fromView)
        }
        
        
        // Perform the animation
        UIView.animate(withDuration: duration, animations: {
            if self.isPresenting {
                toView.transform = CGAffineTransform.identity
            } else {
                fromView.transform = offScreenLeft
            }
        }) { (true) in
            transitionContext.completeTransition(true)
        }
    }
    
    // MARK: - UIViewControllerTransitioningDelegate
    
    func animationController(forPresented presented: UIViewController, presenting: UIViewController, source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        isPresenting = true
        return self
    }
    
    func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        isPresenting = false
        return self
    }
}
