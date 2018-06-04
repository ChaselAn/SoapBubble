//
//  SwipeAnimator.swift
//  EditTableViewCell
//
//  Created by chaselan on 2018/3/26.
//  Copyright © 2018年 chaselan. All rights reserved.

import UIKit

protocol SwipeAnimator {

    var isRunning: Bool { get }

    func addAnimations(_ animation: @escaping () -> Void)

    func addCompletion(completion: @escaping (Bool) -> Void)

    func startAnimation()

    func startAnimation(afterDelay delay: TimeInterval)

    func stopAnimation(_ withoutFinishing: Bool)
}

class UIViewSpringAnimator: SwipeAnimator {
    var isRunning: Bool = false

    let duration: TimeInterval
    let damping: CGFloat
    let velocity: CGFloat

    var animations: (() -> Void)?
    var completion: ((Bool) -> Void)?

    required init(duration: TimeInterval,
                  damping: CGFloat,
                  initialVelocity velocity: CGFloat = 0) {
        self.duration = duration
        self.damping = damping
        self.velocity = velocity
    }

    func addAnimations(_ animations: @escaping () -> Void) {
        self.animations = animations
    }

    func addCompletion(completion: @escaping (Bool) -> Void) {
        self.completion = { [weak self] finished in
            guard self?.isRunning == true else { return }

            self?.isRunning = false
            self?.animations = nil
            self?.completion = nil

            completion(finished)
        }
    }

    func startAnimation() {
        self.startAnimation(afterDelay: 0)
    }

    func startAnimation(afterDelay delay: TimeInterval) {
        guard let animations = animations else { return }

        isRunning = true

        UIView.animate(withDuration: duration,
                       delay: delay,
                       usingSpringWithDamping: damping,
                       initialSpringVelocity: velocity,
                       options: [.curveEaseInOut, .allowUserInteraction],
                       animations: animations,
                       completion: completion)
    }

    func stopAnimation(_ withoutFinishing: Bool) {
        isRunning = false
    }
}
