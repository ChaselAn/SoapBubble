//
//  SwipableHead.swift
//  EditTableViewCell
//
//  Created by ancheng on 2018/5/15.
//  Copyright © 2018年 ancheng. All rights reserved.
//

import UIKit

class SwipableHead {

    enum State {
        case none
        case panning
    }

    enum Message {
        case beginPan(UIPanGestureRecognizer)
        case panning(UIPanGestureRecognizer)
        case panned(UIPanGestureRecognizer)
        case panCancel
    }

    enum Command {
        case beginPan(UIPanGestureRecognizer)
        case panning(UIPanGestureRecognizer)
        case panned(UIPanGestureRecognizer)
        case panCancel
    }

    private(set) lazy var brain = Brain<State, Message, Command>(state: .none) { [unowned self] (state, message) -> (State, Command?) in
        let nextState: State
        var command: Command?
        switch message {
        case .beginPan(let panGesture):
            nextState = .panning
            command = .beginPan(panGesture)
        case .panning(let panGesture):
            nextState = .panning
            command = .panning(panGesture)
        case .panned(let panGesture):
            nextState = .none
            command = .panned(panGesture)
        case .panCancel:
            nextState = .none
            command = .panCancel
        }
        return (nextState, command)
    }
}

class SwipableActionHead {

    typealias HideCompletion = (Bool) -> Void
    typealias HideAnimated = Bool
    typealias ActionViewOffsetX = CGFloat
    typealias AnimationDuration = Double
    typealias IsConfirming = Bool
    typealias AnimationCompletion = (Bool) -> Void
    typealias AnimationToOffsetX = CGFloat
    typealias AnimationInitialVelocity = CGFloat
    typealias IsFromHideAction = Bool

    enum State {
        case showing
        case hidden
        case hiding
    }

    enum Message {
        case show
        case setProgress(ActionViewOffsetX)
        case reset
        case hide(HideAnimated, HideCompletion?)
        case hideAnimate(AnimationDuration, IsConfirming, IsFromHideAction, AnimationCompletion?)
        case showAnimate(IsConfirming, AnimationToOffsetX, AnimationInitialVelocity, AnimationCompletion?)
    }

//    enum Command {
//        case show
//        case setProgress(ActionViewOffsetX)
//        case reset
//        case hide(HideAnimated, HideCompletion?)
//        case hideAnimate(AnimationDuration, IsConfirming, AnimationCompletion?)
//        case showAnimate
//    }

    private(set) lazy var brain = Brain<State, Message, Message>(state: .hidden) { [unowned self] (state, message) -> (State, Message?) in
        let nextState: State
        var command: Message? = message
        switch message {
        case .show:
            nextState = .showing
//            command = .show
        case .setProgress(let offsetX):
            nextState = .showing
//            command = .setProgress(offsetX)
        case .reset:
            nextState = .hidden
//            command = .reset
        case .hide(let animated, let completion):
            if state == .showing {
                nextState = .hiding
//                command = .hide(animated, completion)
            } else {
                nextState = state
                command = nil
            }
        case .hideAnimate(_, _, let fromHideAction, _):
            if fromHideAction {
                nextState = .hiding
            } else {
                nextState = .hidden
            }
//            command = .hideAnimate()
        case .showAnimate:
            nextState = .showing
//            command = .showAnimate
        }
        return (nextState, command)
    }
}

class Brain<State, Message, Command> {
    typealias Reducer = (State, Message) -> (State, Command?)
    typealias Subscriber = (Command) -> Void

    private(set) var state: State
    private let reducer: Reducer
    private var subscriber: Subscriber?

    init(state: State, reducer: @escaping Reducer) {
        self.state = state
        self.reducer = reducer
    }

    func subscribe(_ subscriber: @escaping Subscriber) {
        self.subscriber = subscriber
    }

    func dispatch(_ message: Message) {
        let (nextState, command) = reducer(state, message)
        state = nextState
        if let command = command {
            subscriber?(command)
        }
    }
}
