//
//  TransitionCoordinator.swift
//  CollectionViewFrameAnimationTest
//
//  Created by Stefan Louis on 1/3/19.
//  Copyright © 2019 Stefan Louis. All rights reserved.
//

import UIKit

let transitionDuration: TimeInterval = 1

class TransitionCoordinator: NSObject {
    
    weak var navigationController: UINavigationController?
    var operation: UINavigationController.Operation = .none
    var viewController: ViewController!
    
    var initiallyInteractive = false
    var panGestureRecognizer: UIPanGestureRecognizer = UIPanGestureRecognizer()
    var transitionDriver: TransitionDriver?
    
    init(navigationController nc: UINavigationController, viewController: ViewController) {
        navigationController = nc
        super.init()
        
        nc.delegate = self
        self.viewController = viewController
        
        configurePanGestureRecognizer()
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(viewTap))
        tap.cancelsTouchesInView = true
        tap.numberOfTapsRequired = 1
        navigationController!.view.addGestureRecognizer(tap)
        
    }
    
    @objc func viewTap() {
        print("tapped")
    }
    
    func configurePanGestureRecognizer() {

        panGestureRecognizer.isEnabled = true
        panGestureRecognizer.delegate = self
        panGestureRecognizer.maximumNumberOfTouches = 1
        panGestureRecognizer.minimumNumberOfTouches = 1
        panGestureRecognizer.addTarget(self, action: #selector(initiateTransitionInteractively))
        panGestureRecognizer.cancelsTouchesInView = true
        
        navigationController!.view.addGestureRecognizer(panGestureRecognizer)
        
         guard let interactivePopGestureRecognizer = navigationController?.interactivePopGestureRecognizer else { return }
         panGestureRecognizer.require(toFail: interactivePopGestureRecognizer)
    }
    
    @objc func initiateTransitionInteractively(_ panGesture: UIPanGestureRecognizer) {
        if panGesture.state == .began && transitionDriver == nil {
            initiallyInteractive = true
            let _ = navigationController?.pushViewController(ViewController(), animated: true)
        }
    }

    @objc func handleP() {
        if panGestureRecognizer.state == .changed {
            print("changed")
        }
    }
}

extension TransitionCoordinator: UIGestureRecognizerDelegate {
    
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
    
    func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        guard let transitionDriver = self.transitionDriver else {
            let translation = panGestureRecognizer.translation(in: panGestureRecognizer.view)
            let translationIsVertical = (translation.y > 0) && (abs(translation.y) > abs(translation.x))
            return translationIsVertical && (navigationController?.viewControllers.count ?? 0 > 1)
        }
        
        return transitionDriver.isInteractive
    }
}

extension TransitionCoordinator: UINavigationControllerDelegate {
    
    func navigationController(_ navigationController: UINavigationController, animationControllerFor operation: UINavigationController.Operation, from fromVC: UIViewController, to toVC: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        // Remember the direction of the transition (.push or .pop)
        self.operation = operation
        // Return ourselves as the animation controller for the pending transition
        return self
    }
    
    func navigationController(_ navigationController: UINavigationController, interactionControllerFor animationController: UIViewControllerAnimatedTransitioning) -> UIViewControllerInteractiveTransitioning? {
        
        // Return ourselves as the interaction controller for the pending transition
        return self
    }
}

extension TransitionCoordinator: UIViewControllerInteractiveTransitioning {
    
    func startInteractiveTransition(_ transitionContext: UIViewControllerContextTransitioning) {
        
        transitionDriver = TransitionDriver(operation: operation, context: transitionContext, panGesture: panGestureRecognizer)
    }
    
    var wantsInteractiveStart: Bool {
        // Determines whether the transition begins in an interactive state
        return initiallyInteractive
    }
}

extension TransitionCoordinator: UIViewControllerAnimatedTransitioning {
    
    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return 1.0
    }
    
    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {}
    
    func animationEnded(_ transitionCompleted: Bool) {
        // Clean up our helper object and any additional state
        transitionDriver = nil
        initiallyInteractive = false
        operation = .none
    }
    
    func interruptibleAnimator(using transitionContext: UIViewControllerContextTransitioning) -> UIViewImplicitlyAnimating {
        // The transition driver (helper object), creates the UIViewPropertyAnimator (transitionAnimator)
        // to be used for this transition. It must live the lifetime of the transitionContext.
        return (transitionDriver?.transitionAnimator)!
    }
    
}


