//
//  SwipableCellNode.swift
//  EditTableViewCell
//
//  Created by ancheng on 2018/5/18.
//  Copyright © 2018年 ancheng. All rights reserved.
//

import UIKit
import AsyncDisplayKit

public protocol ASTableNodeSwipableDelegate: class {
    func swipe_tableNode(_ tableNode: ASTableNode, editActionsOptionsForRowAt indexPath: IndexPath) -> [SwipedAction]

    func swipe_tableNode(_ tableNode: ASTableNode, canEditRowAt indexPath: IndexPath) -> Bool
}

open class SwipableCellNode: ASCellNode {

    open var scale: CGFloat = 0.75

    private var originalX: CGFloat = 0
    private weak var tableNode: ASTableNode?
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

    public init(tableNode: ASTableNode) {
        self.tableNode = tableNode
        super.init()

        clipsToBounds = false

        view.addGestureRecognizer(panGestureRecognizer)
        view.addGestureRecognizer(tapGestureRecognizer)

        tableNode.view.panGestureRecognizer.removeTarget(self, action: nil)
        tableNode.view.panGestureRecognizer.addTarget(self, action: #selector(tableViewDidPan))

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

    public required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override open func point(inside point: CGPoint, with event: UIEvent?) -> Bool {

        return contains(point: point)
    }

    private func contains(point: CGPoint) -> Bool {
        return point.y > frame.minY && point.y < frame.maxY
    }

    deinit {
        tableNode?.view.panGestureRecognizer.removeTarget(self, action: nil)
    }

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

    @objc private func tableViewDidPan(gesture: UIPanGestureRecognizer) {
        actionHead.brain.dispatch(.hide(true, nil))
    }
}

// MARK: - handle head command
extension SwipableCellNode {

    private func beginPan(panGesture: UIPanGestureRecognizer) {
        guard let tableNode = tableNode,
            let indexPath = tableNode.indexPath(for: self),
            let source = tableNode.swipableCellDelegate,
            source.swipe_tableNode(tableNode, canEditRowAt: indexPath) else {
                view.removeGestureRecognizer(panGesture)
                return
        }
        stopAnimatorIfNeeded()
        originalX = frame.origin.x
        guard let target = panGesture.view else { return }
        if panGesture.velocity(in: target).x > 0 { return }
        actionHead.brain.dispatch(.show)
    }

    private func panning(panGesture: UIPanGestureRecognizer) {
        guard let tableNode = tableNode else { return }
        guard let target = panGesture.view else { return }
        let translationX = panGesture.translation(in: target).x * scale
        var offsetX = originalX + translationX
        if offsetX > 0 {
            target.frame.origin.x = 0
        } else {
            if offsetX < -tableNode.bounds.width * 3 {
                offsetX = -tableNode.bounds.width * 3
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

        let distance = -frame.origin.x
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
extension SwipableCellNode {

    @discardableResult
    private func showActionsView() -> Bool {

        guard let tableNode = tableNode else { return false }

        super.isHighlighted = false

        let selectedIndexPaths = tableNode.indexPathsForSelectedRows
        selectedIndexPaths?.forEach { tableNode.deselectRow(at: $0, animated: false) }

        self.actionsView?.removeFromSuperview()
        self.actionsView = nil

        guard let indexPath = tableNode.indexPath(for: self),
            let source = tableNode.swipableCellDelegate,
            source.swipe_tableNode(tableNode, canEditRowAt: indexPath) else { return false }

        let actions = source.swipe_tableNode(tableNode, editActionsOptionsForRowAt: indexPath)
        let actionsView = ActionsView(actions: actions)
        actionsView.leftMoveWhenConfirm = { [weak self] in

            guard let strongSelf = self else { return }
            strongSelf.frame.origin.x = -actionsView.preferredWidth
        }

        view.addSubview(actionsView)

        actionsView.translatesAutoresizingMaskIntoConstraints = false
        actionsView.heightAnchor.constraint(equalTo: view.heightAnchor).isActive = true
        actionsView.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 3).isActive = true
        actionsView.topAnchor.constraint(equalTo: view.topAnchor).isActive = true

        actionsView.leftAnchor.constraint(equalTo: view.rightAnchor).isActive = true

        actionsView.setNeedsUpdateConstraints()

        self.actionsView = actionsView

        return true
    }

    private func reset() {
        clipsToBounds = false
        actionsView?.removeFromSuperview()
        actionsView = nil
    }

    private func hideSwipeCommand(animated: Bool, completion: ((Bool) -> Void)? = nil) {
        guard head.brain.state != .panning else { return }
        if animated {
            actionHead.brain.dispatch(.hideAnimate(0.5, actionsView?.isConfirming == true, true, { [weak self] (complete) in
                completion?(complete)
                self?.actionHead.brain.dispatch(.reset)
            }))
        } else {
            self.frame.origin = CGPoint(x: 0, y: self.frame.origin.y)

            self.layoutIfNeeded()
            actionHead.brain.dispatch(.reset)
        }
    }

    private func animate(duration: Double = 0.7, toOffset offset: CGFloat, withInitialVelocity velocity: CGFloat = 0, isConfirming: Bool = false, fromHideAction: Bool = false, completion: ((Bool) -> Void)? = nil) {

        stopAnimatorIfNeeded()
        layoutIfNeeded()

        if offset == 0, frame.origin.x >= -30 {
            frame.origin.x = 0
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

            self.frame.origin = CGPoint(x: offset, y: self.frame.origin.y)

            if !isConfirming {
                self.actionsView?.setProgress(offset <= 0 ? 1 : 0)
            }

            self.layoutIfNeeded()
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

extension SwipableCellNode: UIGestureRecognizerDelegate {

    override open func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {

        let swipeCells = tableNode?.visibleNodes.compactMap({ $0 as? SwipableCellNode }).filter({ $0.actionHead.brain.state == .showing || $0.actionHead.brain.state == .hiding })
        if gestureRecognizer == panGestureRecognizer,
            let view = gestureRecognizer.view,
            let gestureRecognizer = gestureRecognizer as? UIPanGestureRecognizer {
            if actionHead.brain.state != .showing {
                swipeCells?.forEach({ $0.hideSwipe(animated: true) })
            }
            let translation = gestureRecognizer.translation(in: view)
            return abs(translation.y) <= abs(translation.x)
        }

        if gestureRecognizer == tapGestureRecognizer {
            if actionHead.brain.state == .showing {
                return true
            }
            if swipeCells?.count != 0 {
                swipeCells?.forEach({ $0.hideSwipe(animated: true) })
                return true
            }
            return false
        }

        return true
    }
}
