//
//  Animations.swift
//  CollectionViewFrameAnimationTest
//
//  Created by Stefan Louis on 12/28/18.
//  Copyright © 2018 Stefan Louis. All rights reserved.
//

import UIKit

extension ViewController {
    
    @objc func handlePresentPanGesture(gestureRecognizer: UIPanGestureRecognizer) {
        
        let translation = gestureRecognizer.translation(in: self.cv.view)
        let translatedY = self.view.center.y + translation.y
        
        var progress: CGFloat!
        
        if expanded == true {
            progress = (translatedY / view.center.y) - 1
        } else {
            progress = 1 - (translatedY / view.center.y)
        }
        
        progress = max(0.001, min(0.999, progress))
        
        switch gestureRecognizer.state {
        case .began:
            startInteractiveStateTransition(gestureRecognizer: gestureRecognizer, state: nextState, duration: duration)
        case .changed:
            print(progress)
            updateInteractiveStateTransition(gestureRecognizer: gestureRecognizer, fractionComplete: progress)
        case .ended:
            continueInteractiveStateTransition(fractionComplete: progress)
        default:
            break
        }
    }

    func startInteractiveStateTransition(gestureRecognizer: UIPanGestureRecognizer, state: state, duration: TimeInterval) {
        
        if runningAnimations.isEmpty {
            animateStateTransitionIfNeeded(toState: state, duration: duration)
        }
        
        for animator in self.runningAnimations {
            animator.pauseAnimation()
            animator.fractionComplete = 0
            animationProgressWhenInterrupted = animator.fractionComplete
        }
    }
    
    func  animateStateTransitionIfNeeded(toState: state, duration: TimeInterval) {
        
        guard runningAnimations.isEmpty else {
            print("running animations not empty! will not start new")
            return
        }
        
        var collectionViewCollapsedFrame: CGRect!
        var collectionViewExpandedFrame: CGRect!
        
         frameAnimator = UIViewPropertyAnimator(duration: duration, dampingRatio: 2) {
            [unowned self] in
            
            collectionViewCollapsedFrame = CGRect(x: 0, y: 30, width: self.view.frame.width, height: (self.view.frame.height / 2) - 30 - 65)
            
            collectionViewExpandedFrame = CGRect(x: 0, y: 30, width: self.view.frame.width, height: (self.view.frame.height - 100) - 30 - 65)
            
            
            switch self.nextState {
            case .collapsed:
                
                // Comment and uncomment the below line and run.
                self.cv.collectionView?.frame = collectionViewCollapsedFrame
            
                self.expandedConstraint?.isActive = false
                self.collapsedConstraint?.isActive = true
                
            case .expanded:
                
                // Comment and uncomment the below line and run.
                self.cv.collectionView?.frame = collectionViewExpandedFrame
                
                self.collapsedConstraint?.isActive = false
                self.expandedConstraint?.isActive = true
                
            }
            self.view.layoutIfNeeded()
        }
        
        frameAnimator.scrubsLinearly = true
        
        frameAnimator.addCompletion {  [weak self] (position) in
            
            switch toState {
            case .collapsed:
                if position == .start {
                    self?.collapsedConstraint?.isActive = false
                    self?.expandedConstraint?.isActive = true
                    self?.expanded = true
                    
                    self?.cv.collectionView?.frame = collectionViewExpandedFrame // desired CV frames

                    
                } else if position == .end {
                    self?.expanded = false
                    
                    self?.cv.collectionView?.frame = collectionViewCollapsedFrame
                }
            case .expanded:
                if position == .start {
                    self?.expandedConstraint?.isActive = false
                    self?.collapsedConstraint?.isActive = true
                    self?.expanded = false
                    
                    self?.cv.collectionView?.frame = collectionViewCollapsedFrame

                    
                } else if position == .end {
                    self?.expanded = true
                    
                    self?.cv.collectionView?.frame = collectionViewExpandedFrame

                }
            }
            
            self?.view.layoutIfNeeded()
            print("container frame animation completed")
            self?.runningAnimations.removeAll()
            self?.frameAnimator.fractionComplete = 0
        }
        
        frameAnimator.startAnimation()
        self.runningAnimations.append(frameAnimator)
    }
    
    func updateInteractiveStateTransition(gestureRecognizer: UIPanGestureRecognizer, fractionComplete: CGFloat) {
        
        for animator in runningAnimations {
            if animator.isRunning {
                return
            }
        }
        
        if runningAnimations.isEmpty {
            startInteractiveStateTransition(gestureRecognizer: gestureRecognizer, state: nextState, duration: duration)
        }
        
        for animator in runningAnimations {
            animator.pauseAnimation()
            animator.fractionComplete = fractionComplete + animationProgressWhenInterrupted
        }
    }
    
    func continueInteractiveStateTransition(fractionComplete: CGFloat) {
        
        for animator in runningAnimations {
            if animator.isRunning {
                return
            }
        }
        
        for animator in runningAnimations {
            animator.pauseAnimation()
            animator.isReversed = (fractionComplete > 0.5) ? false : true
        }
        
        let springParam = UISpringTimingParameters(dampingRatio: 1)
        
        for animator in runningAnimations {
            let fraction = animator.fractionComplete
            animator.continueAnimation(withTimingParameters: springParam, durationFactor: fraction)
        }
    }
    
}
