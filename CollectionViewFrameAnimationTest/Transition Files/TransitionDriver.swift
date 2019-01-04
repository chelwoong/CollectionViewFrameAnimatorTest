//
//  TransitionDrive.swift
//  CollectionViewFrameAnimationTest
//
//  Created by Stefan Louis on 1/3/19.
//  Copyright © 2019 Stefan Louis. All rights reserved.
//

import UIKit

class TransitionDriver: NSObject {
    
    private let operation: UINavigationController.Operation
    private let panGesture: UIPanGestureRecognizer
    var isInteractive: Bool { return transitionContext.isInteractive }
    
    let transitionContext: UIViewControllerContextTransitioning
    var transitionAnimator: UIViewPropertyAnimator!
    
    var runningAnimations = [UIViewPropertyAnimator]()
    var animationProgressWhenInterrupted: CGFloat = 0
    
    // MARK: Init
    
    init(operation: UINavigationController.Operation, context: UIViewControllerContextTransitioning, panGesture: UIPanGestureRecognizer) {
        self.transitionContext = context
        self.operation = operation
        self.panGesture = panGesture
        super.init()
        
    }
    
}
