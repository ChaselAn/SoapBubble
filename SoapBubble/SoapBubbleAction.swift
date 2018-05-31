//
//  SoapBubbleAction.swift
//  EditTableViewCell
//
//  Created by ancheng on 2018/5/18.
//  Copyright © 2018年 ancheng. All rights reserved.
//

import UIKit

public class SoapBubbleAction {

    public enum ConfirmStyle {
        case none
        case custom(title: String)
    }

    public var title: String
    public var backgroundColor: UIColor = UIColor.red
    public var titleColor: UIColor = UIColor.white
    public var titleFont: UIFont = UIFont.systemFont(ofSize: 14)
    public var preferredWidth: CGFloat?
    public var needConfirm = ConfirmStyle.none
    public var horizontalMargin: CGFloat = 10
    public var handler: ((SoapBubbleAction) -> Void)?

    public var isEnabled: Bool = true

    public init(title: String, handler: ((SoapBubbleAction) -> Void)?) {
        self.title = title
        self.handler = handler
    }

    public init(title: String, backgroundColor: UIColor, titleColor: UIColor, titleFont: UIFont, preferredWidth: CGFloat?, handler: ((SoapBubbleAction) -> Void)?) {
        self.title = title
        self.backgroundColor = backgroundColor
        self.titleColor = titleColor
        self.titleFont = titleFont
        self.preferredWidth = preferredWidth
        self.handler = handler
    }
}
