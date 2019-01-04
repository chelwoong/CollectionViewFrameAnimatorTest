//
//  ViewController.swift
//  CollectionViewFrameAnimationTest
//
//  Created by Stefan Louis on 12/28/18.
//  Copyright © 2018 Stefan Louis. All rights reserved.
//

import UIKit

class ViewController: UIViewController, UIGestureRecognizerDelegate {
    
    var panGestureRecognizer: UIPanGestureRecognizer!

    
    enum state {
        case expanded
        case collapsed
    }
    var nextState: state {
        return expanded ? .collapsed : .expanded
    }
    var expanded: Bool = true
    var expandedConstraint: NSLayoutConstraint!
    var collapsedConstraint: NSLayoutConstraint!

    
    let duration: TimeInterval = 0.4
    var runningAnimations = [UIViewPropertyAnimator]()
    var animationProgressWhenInterrupted: CGFloat = 0.0
    var frameAnimator: UIViewPropertyAnimator!

    
    let cv = CollectionViewController()
    
    func setupChildVC() {
        
        addChild(cv)
        cv.didMove(toParent: self)
        
        guard let cvView = cv.view else { return }
        cvView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(cvView)
        
        //view.layoutSubviews()
        
        expandedConstraint = cvView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 15)
        collapsedConstraint = NSLayoutConstraint(item: cvView, attribute: .top, relatedBy: .equal, toItem: view.safeAreaLayoutGuide, attribute: .centerY, multiplier: 1, constant: 0)
        
        let cvViewConstraints = [
            cvView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            cvView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            cvView.heightAnchor.constraint(equalTo: view.safeAreaLayoutGuide.heightAnchor, constant: 0),
            expandedConstraint!
        ]
        
        NSLayoutConstraint.activate(cvViewConstraints)
        
        panGestureRecognizer = UIPanGestureRecognizer(target: self, action: #selector(handlePresentPanGesture(gestureRecognizer:)))
        panGestureRecognizer.minimumNumberOfTouches = 1
        panGestureRecognizer.delegate = self
        panGestureRecognizer.cancelsTouchesInView = false
        panGestureRecognizer.isEnabled = true
        cvView.addGestureRecognizer(panGestureRecognizer)
    }
        
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .white
        setupChildVC()
    }
    
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
}

