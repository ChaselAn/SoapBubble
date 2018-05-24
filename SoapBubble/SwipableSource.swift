//
//  SwipableSource.swift
//  EditTableViewCell
//
//  Created by ancheng on 2018/5/22.
//  Copyright © 2018年 ancheng. All rights reserved.
//

import UIKit

@objc public protocol SwipableSource {
    var targetCellView: UIView { set get }
    var targetTableView: UITableView? { set get }

    @objc func prepareSwipe()

    var panGestureRecognizer: UIPanGestureRecognizer { get }
    var tapGestureRecognizer: UITapGestureRecognizer { get }

}

extension SwipableSource {

    func prepareSwipe() {

        targetCellView.addGestureRecognizer(panGestureRecognizer)
        targetCellView.addGestureRecognizer(tapGestureRecognizer)

        targetTableView?.panGestureRecognizer.removeTarget(self, action: nil)
        targetTableView?.panGestureRecognizer.addTarget(self, action: #selector(tableViewDidPan))

//        head.brain.subscribe { [weak self] (command) in
//            guard let strongSelf = self else { return }
//            switch command {
//            case .beginPan(let panGesture):
//                strongSelf.beginPan(panGesture: panGesture)
//            case .panning(let panGesture):
//                strongSelf.panning(panGesture: panGesture)
//            case .panned(let panGestrue):
//                strongSelf.panned(panGesture: panGestrue)
//            case .panCancel:
//                strongSelf.panCancel()
//            }
//        }
//
//        actionHead.brain.subscribe { [weak self] (command) in
//            guard let strongSelf = self else { return }
//            switch command {
//            case .show:
//                strongSelf.showActionsView()
//            case .setProgress(let offsetX):
//                guard let actionsView = strongSelf.actionsView else { return }
//                let progress = abs(offsetX) / actionsView.preferredWidth
//                if !actionsView.isConfirming {
//                    actionsView.setProgress(progress)
//                }
//            case .reset:
//                strongSelf.reset()
//            case .hide(let animated, let completion):
//                strongSelf.hideSwipeCommand(animated: animated, completion: completion)
//            case .hideAnimate(let duration, let isConfirming, let isFromHideAction, let completion):
//                strongSelf.animate(duration: duration, toOffset: 0, isConfirming: isConfirming, fromHideAction: isFromHideAction, completion: completion)
//            case .showAnimate(let isConfirming, let toOffsetX, let initialVelocity, let completion):
//                strongSelf.animate(duration: 0.4, toOffset: toOffsetX, withInitialVelocity: initialVelocity, isConfirming: isConfirming, completion: completion)
//            }
//        }
    }

    func tableViewDidPan(gesture: UIPanGestureRecognizer) {
//        actionHead.brain.dispatch(.hide(true, nil))
    }
}
