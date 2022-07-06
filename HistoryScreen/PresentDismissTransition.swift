//
//  PresentDismissTransition.swift
//  Altos-app
//
//  Created by Leonid Vilner on 22.02.2022.
//

import Foundation
import UIKit

class SideTransitionInteractor: UIPercentDrivenInteractiveTransition {
    var hasStarted = false
    var shouldFinish = false
}

class SideInteractiveTransition: NSObject, UIViewControllerAnimatedTransitioning {

    enum Direction {
        case left
        case right
    }

    enum Action {
        case present
        case dismiss
    }
    
    private var action: Action
    private var animator: UIViewImplicitlyAnimating?
    
    init(action: Action) {
        self.action = action
    }
    
    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return 0.3
    }
    
    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        let animator = interruptibleAnimator(using: transitionContext)
        animator.startAnimation()
    }
    
    func interruptibleAnimator(using transitionContext: UIViewControllerContextTransitioning) -> UIViewImplicitlyAnimating {
        
        if let animator = self.animator {
            return animator
        }
        
        let container = transitionContext.containerView
        let toViewController = transitionContext.viewController(forKey: .to)!
        let fromViewController = transitionContext.viewController(forKey: .from)!

        let fromViewInitialFrame = transitionContext.initialFrame(for: fromViewController)
        var fromViewFinalFrame = fromViewInitialFrame
        
        var toView: UIView
        let fromView = fromViewController.view!
        var toViewInitialFrame = fromViewInitialFrame
        
        switch action {
        case .present:
            fromViewFinalFrame.origin.x = fromViewFinalFrame.width
            toView = transitionContext.view(forKey: .to)!
            toViewInitialFrame.origin.x = -toView.frame.size.width
            toView.frame = toViewInitialFrame
            container.addSubview(toView)
        case .dismiss:
            fromViewFinalFrame.origin.x = -fromViewFinalFrame.width
            toView = transitionContext.viewController(forKey: .to)!.view!
            toViewInitialFrame.origin.x = toView.frame.size.width
            toView.frame = toViewInitialFrame
            // TODO: Should it be removed?
        }

        toViewController.beginAppearanceTransition(true, animated: true)
        fromViewController.beginAppearanceTransition(false, animated: true)

        print("<TRANSITION> viewController to show = \(toViewController)")
        print("<TRANSITION> viewController to hide = \(fromViewController)")

        let animator = UIViewPropertyAnimator(
            duration: transitionDuration(using: transitionContext),
            curve: .easeInOut,
            animations: {
                toView.frame = fromViewInitialFrame
                fromView.frame = fromViewFinalFrame
            }
        )
        animator.addCompletion { [weak toViewController, weak fromViewController] _ in
            if !transitionContext.transitionWasCancelled {
                toViewController?.endAppearanceTransition()
                fromViewController?.endAppearanceTransition()
            } else {
                toViewController?.beginAppearanceTransition(false, animated: false)
                toViewController?.endAppearanceTransition()
                fromViewController?.beginAppearanceTransition(true, animated: false)
                fromViewController?.endAppearanceTransition()
            }
            transitionContext.completeTransition(!transitionContext.transitionWasCancelled)
        }
        self.animator = animator
        return animator
    }
    
    static func calculateProgress(translationInView: CGPoint, viewBounds: CGRect, direction: Direction) -> CGFloat {
        let pointOnAxis = translationInView.x
        let axisLength = viewBounds.width
        let movementOnAxis = pointOnAxis / axisLength

        switch direction {
            case .right:
                let positiveMovementOnAxis = fmaxf(Float(movementOnAxis), 0.0)
                let positiveMovementOnAxisPercent = fminf(positiveMovementOnAxis, 1.0)
                return CGFloat(positiveMovementOnAxisPercent)
            case .left:
                let positiveMovementOnAxis = fminf(Float(movementOnAxis), 0.0)
                let positiveMovementOnAxisPercent = fmaxf(positiveMovementOnAxis, -1.0)
                return CGFloat(-positiveMovementOnAxisPercent)
        }
    }
        
    static func mapGestureStateToInteractor(
        gesture: UIScreenEdgePanGestureRecognizer,
        progress: CGFloat,
        transitionInteractor: SideTransitionInteractor?,
        transitionTrigger: () -> ()
    ) {
        guard let transitionInteractor = transitionInteractor else { return }
        switch gesture.state {
            case .began:
                transitionInteractor.hasStarted = true
                transitionTrigger()
            case .changed:
                transitionInteractor.shouldFinish = progress > 0.5
                transitionInteractor.update(progress)
            case .cancelled:
                transitionInteractor.hasStarted = false
                transitionInteractor.cancel()
            case .ended:
                transitionInteractor.hasStarted = false
                transitionInteractor.shouldFinish
                    ? transitionInteractor.finish()
                    : transitionInteractor.cancel()
            default:
                break
        }
    }
}
