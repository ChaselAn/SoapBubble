//
//  SwipableView.swift
//  SoapBubble
//
//  Created by ancheng on 2018/5/30.
//  Copyright © 2018年 ancheng. All rights reserved.
//

import UIKit

//typealias SwipableTargetView = UIView
public protocol SwipableSource: class {

//    func targetView(_ targetView: UIView)
//    func swipableTargetView(_ targetView: UIView, editActionsOptionsForRowAt indexPath: IndexPath) -> [SwipedAction]
//
//    func swipableTargetView(_ targetView: UIView, canEditRowAt indexPath: IndexPath) -> Bool

    func targetView() -> UIView

}

class SwipableManager {
    static let shared = SwipableManager()

    var swipableObjects: Set<SwipableObject> = Set()

}

public class SwipableObject: NSObject {

    var scale: CGFloat = 0.75

    private weak var targetView: UIView!

    private var originalX: CGFloat = 0
    private var actionsView: ActionsView?
    private var animator: SwipeAnimator?

    private let head = SwipableHead()
    private let actionHead = SwipableActionHead()

    private lazy var panGestureRecognizer: UIPanGestureRecognizer = {
        let gesture = UIPanGestureRecognizer(target: self, action: #selector(didPan))
        gesture.delegate = self
        return gesture
    }()

    private lazy var tapGestureRecognizer: UITapGestureRecognizer = {
        let gesture = UITapGestureRecognizer(target: self, action: #selector(didTap))
        gesture.delegate = self
        return gesture
    }()

    public init(targetView: UIView) {
        self.targetView = targetView
        super.init()

        targetView.clipsToBounds = false
        targetView.addGestureRecognizer(panGestureRecognizer)
        targetView.addGestureRecognizer(tapGestureRecognizer)

        head.brain.subscribe { [weak self] (command) in
            guard let strongSelf = self else { return }
            switch command {
            case .beginPan(let panGesture):
                strongSelf.beginPan(panGesture: panGesture)
            case .panning(let panGesture):
                strongSelf.panning(panGesture: panGesture)
            case .panned(let panGestrue):
                strongSelf.panned(panGesture: panGestrue)
            case .panCancel:
                strongSelf.panCancel()
            }
        }

        actionHead.brain.subscribe { [weak self] (command) in
            guard let strongSelf = self else { return }
            switch command {
            case .show:
                strongSelf.showActionsView()
            case .setProgress(let offsetX):
                guard let actionsView = strongSelf.actionsView else { return }
                let progress = abs(offsetX) / actionsView.preferredWidth
                if !actionsView.isConfirming {
                    actionsView.setProgress(progress)
                }
            case .reset:
                strongSelf.reset()
            case .hide(let animated, let completion):
                strongSelf.hideSwipeCommand(animated: animated, completion: completion)
            case .hideAnimate(let duration, let isConfirming, let isFromHideAction, let completion):
                strongSelf.animate(duration: duration, toOffset: 0, isConfirming: isConfirming, fromHideAction: isFromHideAction, completion: completion)
            case .showAnimate(let isConfirming, let toOffsetX, let initialVelocity, let completion):
                strongSelf.animate(duration: 0.4, toOffset: toOffsetX, withInitialVelocity: initialVelocity, isConfirming: isConfirming, completion: completion)
            }
        }
    }

    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    deinit {
        print("---------------------")
    }

//    override open func point(inside point: CGPoint, with event: UIEvent?) -> Bool {
//
//        return contains(point: point)
//    }
//
//    private func contains(point: CGPoint) -> Bool {
//        return point.y > frame.minY && point.y < frame.maxY
//    }

    public func hideSwipe(animated: Bool, completion: ((Bool) -> Void)? = nil) {
        actionHead.brain.dispatch(.hide(animated, completion))
    }

    @objc private func didPan(gesture: UIPanGestureRecognizer) {

        switch gesture.state {
        case .began:
            head.brain.dispatch(.beginPan(gesture))
        case .changed:
            head.brain.dispatch(.panning(gesture))
        case .ended:
            head.brain.dispatch(.panned(gesture))
        case .cancelled:
            head.brain.dispatch(.panCancel)
        default:
            break
        }
    }

    @objc private func didTap(gesture: UITapGestureRecognizer) {
        actionHead.brain.dispatch(.hide(true, nil))
    }
}

// MARK: - handle head command
extension SwipableObject {

    private func beginPan(panGesture: UIPanGestureRecognizer) {
//        guard let tableNode = tableNode,
//            let indexPath = tableNode.indexPath(for: self),
//            let source = tableNode.swipableCellDelegate,
//            source.swipe_tableNode(tableNode, canEditRowAt: indexPath) else {
//                view.removeGestureRecognizer(panGesture)
//                return
//        }
        stopAnimatorIfNeeded()
        originalX = targetView.frame.origin.x
        guard let target = panGesture.view else { return }
        if panGesture.velocity(in: target).x > 0 { return }
        actionHead.brain.dispatch(.show)
    }

    private func panning(panGesture: UIPanGestureRecognizer) {
//        guard let tableNode = tableNode else { return }
        guard let target = panGesture.view else { return }
        let translationX = panGesture.translation(in: target).x * scale
        var offsetX = originalX + translationX
        if offsetX > 0 {
            target.frame.origin.x = 0
        } else {
            if offsetX < -targetView.bounds.width * 3 {
                offsetX = -targetView.bounds.width * 3
            }
            target.frame.origin.x = offsetX
            actionHead.brain.dispatch(.setProgress(offsetX))
        }
    }

    private func panned(panGesture: UIPanGestureRecognizer) {
        guard let actionsView = actionsView else {
            actionHead.brain.dispatch(.reset)
            return
        }
        guard let target = panGesture.view else { return }
        let translationX = panGesture.translation(in: target).x * scale
        if originalX + translationX >= 0 {
            actionHead.brain.dispatch(.reset)
            return
        }

        let offSetX = translationX < 0 ? -actionsView.preferredWidth : 0
        let velocity = panGesture.velocity(in: target)

        let distance = -targetView.frame.origin.x
        let normalizedVelocity = velocity.x / distance

        let completion: SwipableActionHead.AnimationCompletion = { [weak self] _ in
            guard let strongSelf = self else { return }

            if strongSelf.actionHead.brain.state == .showing && translationX >= 0 {
                strongSelf.actionHead.brain.dispatch(.reset)
            }
        }
        if offSetX == 0 {
            actionHead.brain.dispatch(.hideAnimate(0.4, actionsView.isConfirming, false, completion))
        } else {
            actionHead.brain.dispatch(.showAnimate(actionsView.isConfirming, offSetX, normalizedVelocity * 0.4, completion))
        }
    }

    private func panCancel() {
        actionHead.brain.dispatch(.hide(false, nil))
    }
}

// MARK: - handle actionHead command
extension SwipableObject {

    @discardableResult
    private func showActionsView() -> Bool {

//        guard let tableNode = tableNode else { return false }
//
//        super.isHighlighted = false

//        let selectedIndexPaths = targetTableView.indexPathsForSelectedRows
//        selectedIndexPaths?.forEach { targetTableView.deselectRow(at: $0, animated: false) }

        self.actionsView?.removeFromSuperview()
        self.actionsView = nil

//        guard let indexPath = tableNode.indexPath(for: self),
//            let source = tableNode.swipableCellDelegate,
//            source.swipe_tableNode(tableNode, canEditRowAt: indexPath) else { return false }
//
//        let actions = source.swipe_tableNode(tableNode, editActionsOptionsForRowAt: indexPath)
        let deleteAction = SwipedAction(title: "删除", handler: nil)
        let markAction = SwipedAction(title: "标记", handler: nil)
        let actionsView = ActionsView(actions: [markAction, deleteAction])
        actionsView.leftMoveWhenConfirm = { [weak self] in

            guard let strongSelf = self else { return }
            strongSelf.targetView.frame.origin.x = -actionsView.preferredWidth
        }

        targetView.addSubview(actionsView)

        actionsView.translatesAutoresizingMaskIntoConstraints = false
        actionsView.heightAnchor.constraint(equalTo: targetView.heightAnchor).isActive = true
        actionsView.widthAnchor.constraint(equalTo: targetView.widthAnchor, multiplier: 3).isActive = true
        actionsView.topAnchor.constraint(equalTo: targetView.topAnchor).isActive = true

        actionsView.leftAnchor.constraint(equalTo: targetView.rightAnchor).isActive = true

        actionsView.setNeedsUpdateConstraints()
        targetView.layoutIfNeeded()

        self.actionsView = actionsView
        SwipableManager.shared.swipableObjects.insert(self)
        return true
    }

    private func reset() {
//        targetView.clipsToBounds = false
        actionsView?.removeFromSuperview()
        actionsView = nil
        if SwipableManager.shared.swipableObjects.contains(self) {
            SwipableManager.shared.swipableObjects.remove(self)
        }
    }

    private func hideSwipeCommand(animated: Bool, completion: ((Bool) -> Void)? = nil) {
        guard head.brain.state != .panning else { return }
        if animated {
            actionHead.brain.dispatch(.hideAnimate(0.5, actionsView?.isConfirming == true, true, { [weak self] (complete) in
                completion?(complete)
                self?.actionHead.brain.dispatch(.reset)
            }))
        } else {
            targetView.frame.origin = CGPoint(x: 0, y: targetView.frame.origin.y)

            targetView.layoutIfNeeded()
            actionHead.brain.dispatch(.reset)
        }
    }

    private func animate(duration: Double = 0.7, toOffset offset: CGFloat, withInitialVelocity velocity: CGFloat = 0, isConfirming: Bool = false, fromHideAction: Bool = false, completion: ((Bool) -> Void)? = nil) {

        stopAnimatorIfNeeded()
        targetView.layoutIfNeeded()

        if offset == 0, targetView.frame.origin.x >= -30 {
            targetView.frame.origin.x = 0
            if !isConfirming {
                self.actionsView?.setProgress(offset <= 0 ? 1 : 0)
            }
            completion?(true)
            return
        }

        let animator: SwipeAnimator = {
            if velocity > 0 {

                return UIViewSpringAnimator(duration: duration, damping: 1.0, initialVelocity: velocity)

            } else {

                return UIViewSpringAnimator(duration: duration, damping: 1.0)

            }
        }()

        animator.addAnimations({

            self.targetView.frame.origin = CGPoint(x: offset, y: self.targetView.frame.origin.y)

            if !isConfirming {
                self.actionsView?.setProgress(offset <= 0 ? 1 : 0)
            }

            self.targetView.layoutIfNeeded()
        })

        if let completion = completion {
            animator.addCompletion(completion: completion)
        }

        self.animator = animator

        animator.startAnimation()
    }

    private func stopAnimatorIfNeeded() {
        if animator?.isRunning == true {
            animator?.stopAnimation(true)
        }
    }

}

extension SwipableObject: UIGestureRecognizerDelegate {

    open func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {

        let swipeCells = SwipableManager.shared.swipableObjects.filter({ $0.actionHead.brain.state == .showing || $0.actionHead.brain.state == .hiding })
        if gestureRecognizer == panGestureRecognizer,
            let view = gestureRecognizer.view,
            let gestureRecognizer = gestureRecognizer as? UIPanGestureRecognizer {
            if actionHead.brain.state != .showing {
                swipeCells.forEach({ $0.hideSwipe(animated: true) })
            }
            let translation = gestureRecognizer.translation(in: view)
            return abs(translation.y) <= abs(translation.x)
        }

        if gestureRecognizer == tapGestureRecognizer {
            if actionHead.brain.state == .showing {
                return true
            }
            if swipeCells.count != 0 {
                swipeCells.forEach({ $0.hideSwipe(animated: true) })
                return true
            }
            return false
        }

        return true
    }
}

public class SoapBubble {
    static let shared = SoapBubble()

    private var objects: [SwipableObject] = []

    public var swipableDelegate: SwipableSource? {
        didSet {
            guard let swipableDelegate = swipableDelegate, oldValue != nil else { return }
            objects.append(SwipableObject(targetView: swipableDelegate.targetView()))
        }
    }
}

extension UIView {

    public var soapBubble: SoapBubble {
        return SoapBubble.shared
    }

}
