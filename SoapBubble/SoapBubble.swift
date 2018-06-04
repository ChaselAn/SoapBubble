//
//  SoapBubble.swift
//  SoapBubble
//
//  Created by chaselan on 2018/6/4.
//  Copyright © 2018年 chaselan. All rights reserved.
//

public class SoapBubble {

    private var object: SoapBubbleObject?

    public weak var swipableDelegate: SoapBubbleSource? {
        didSet {
            guard let swipableDelegate = swipableDelegate, oldValue == nil else { return }
            object = SoapBubbleObject(targetView: swipableDelegate.targetView())
            object?.delegate = swipableDelegate
        }
    }

    public var isEnable = true

    // If true, when there are multiple SoapBubbles, click or slide other SoapBubbles to hide all but the current SoapBubble. Default is true
    public var hideAllShowedSoapBubbleWhenTouch = true

    public func hide() {
        object?.hideSwipe(animated: true)
    }
}

extension UIView {

    private static var soapBubbleKey: Character!

    private weak var _soapBubble: SoapBubble? {
        set {
            objc_setAssociatedObject(self, &UIView.soapBubbleKey, newValue, .OBJC_ASSOCIATION_RETAIN)
        }
        get {
            return objc_getAssociatedObject(self, &UIView.soapBubbleKey) as? SoapBubble
        }
    }

    public var soapBubble: SoapBubble {
        if _soapBubble == nil {
            _soapBubble = SoapBubble()
        }
        return _soapBubble!
    }

}
