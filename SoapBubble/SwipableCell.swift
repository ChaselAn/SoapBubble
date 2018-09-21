//
//  SwipableCell.swift
//  EditTableViewCell
//
//  Created by ancheng on 2018/5/18.
//  Copyright © 2018年 ancheng. All rights reserved.
//

import UIKit

public protocol UITableViewSwipableCellDelegate: class {
    func swipe_tableView(_ tableView: UITableView, editActionsOptionsForRowAt indexPath: IndexPath) -> [SwipedAction]

    func swipe_tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool
}

open class SwipableCell: UITableViewCell {

    open var scale: CGFloat = 0.75

    private var originalX: CGFloat = 0
    private weak var tableView: UITableView?
    private var animator: SwipeAnimator?
    private var actionsView: ActionsView?
    private var originalLayoutMargins: UIEdgeInsets = .zero

    private let head = SwipableHead()
    private let actionHead = SwipableActionHead()

    lazy var panGestureRecognizer: UIPanGestureRecognizer = {
        let gesture = UIPanGestureRecognizer(target: self, action: #selector(didPan))
        gesture.delegate = self
        return gesture
    }()

    lazy var tapGestureRecognizer: UITapGestureRecognizer = {
        let gesture = UITapGestureRecognizer(target: self, action: #selector(didTap))
        gesture.delegate = self
        return gesture
    }()

    override public init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)

        clipsToBounds = false

        addGestureRecognizer(panGestureRecognizer)
        addGestureRecognizer(tapGestureRecognizer)

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

    public func hideSwipe(animated: Bool, completion: ((Bool) -> Void)? = nil) {
        actionHead.brain.dispatch(.hide(animated, completion))
    }


    override open func didMoveToSuperview() {
        super.didMoveToSuperview()

        var view: UIView = self
        while let superview = view.superview {
            view = superview

            if let tableView = view as? UITableView {
                self.tableView = tableView

                tableView.panGestureRecognizer.removeTarget(self, action: nil)
                tableView.panGestureRecognizer.addTarget(self, action: #selector(tableViewDidPan))
                return
            }
        }
    }

    override open func point(inside point: CGPoint, with event: UIEvent?) -> Bool {
        guard let superview = superview else { return false }

        let point = convert(point, to: superview)

        return contains(point: point)
    }

    private func contains(point: CGPoint) -> Bool {
        return point.y > frame.minY && point.y < frame.maxY
    }

    deinit {
        tableView?.panGestureRecognizer.removeTarget(self, action: nil)
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
extension SwipableCell {

    private func beginPan(panGesture: UIPanGestureRecognizer) {
        guard let tableView = tableView,
            let indexPath = tableView.indexPath(for: self),
            let source = tableView.swipableCellDelegate,
            source.swipe_tableView(tableView, canEditRowAt: indexPath) else {
                removeGestureRecognizer(panGesture)
                return
        }
        stopAnimatorIfNeeded()
        originalX = frame.origin.x
        guard let target = panGesture.view else { return }
        if panGesture.velocity(in: target).x > 0 { return }
        actionHead.brain.dispatch(.show)
    }

    private func panning(panGesture: UIPanGestureRecognizer) {
        guard let tableView = tableView else { return }
        guard let target = panGesture.view else { return }
        let translationX = panGesture.translation(in: target).x * scale
        var offsetX = originalX + translationX
        if offsetX > 0 {
            target.frame.origin.x = 0
        } else {
            if offsetX < -tableView.bounds.width * 3 {
                offsetX = -tableView.bounds.width * 3
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
extension SwipableCell {

    @discardableResult
    private func showActionsView() -> Bool {

        guard let tableView = tableView else { return false }

        super.setHighlighted(false, animated: false)

        let selectedIndexPaths = tableView.indexPathsForSelectedRows
        selectedIndexPaths?.forEach { tableView.deselectRow(at: $0, animated: false) }

        self.actionsView?.removeFromSuperview()
        self.actionsView = nil

        guard let indexPath = tableView.indexPath(for: self),
            let source = tableView.swipableCellDelegate,
            source.swipe_tableView(tableView, canEditRowAt: indexPath) else { return false }

        let actions = source.swipe_tableView(tableView, editActionsOptionsForRowAt: indexPath)
        let actionsView = ActionsView(actions: actions)
        actionsView.leftMoveWhenConfirm = { [weak self] in
            
            guard let strongSelf = self else { return }
            strongSelf.frame.origin.x = -actionsView.preferredWidth
        }

        addSubview(actionsView)

        actionsView.translatesAutoresizingMaskIntoConstraints = false
        actionsView.heightAnchor.constraint(equalTo: heightAnchor).isActive = true
        actionsView.widthAnchor.constraint(equalTo: widthAnchor, multiplier: 3).isActive = true
        actionsView.topAnchor.constraint(equalTo: topAnchor).isActive = true

        actionsView.leftAnchor.constraint(equalTo: rightAnchor).isActive = true

        actionsView.setNeedsUpdateConstraints()

        layoutIfNeeded()

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

extension SwipableCell {

    override open func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {

        let swipeCells = tableView?.visibleCells.compactMap({ ($0 as? SwipableCell) }).filter({ $0.actionHead.brain.state == .showing || $0.actionHead.brain.state == .hiding })

        if gestureRecognizer == panGestureRecognizer,
            let view = gestureRecognizer.view,
            let gestureRecognizer = gestureRecognizer as? UIPanGestureRecognizer
        {
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
