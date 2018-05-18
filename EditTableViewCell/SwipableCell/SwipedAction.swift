//
//  SwipedAction.swift
//  EditTableViewCell
//
//  Created by ancheng on 2018/5/18.
//  Copyright © 2018年 ancheng. All rights reserved.
//

import UIKit

public class SwipedAction {

    public enum ConfirmStyle {
        case none
        case custom(title: String)
    }

    public var title: String
    public var backgroundColor: UIColor = UIColor.red
    public var titleColor: UIColor = UIColor.white
    public var titleFont: UIFont = UIFont.systemFont(ofSize: 14)
    public var preferredWidth: CGFloat?
    public var handler: ((SwipedAction) -> Void)?
    public var needConfirm = ConfirmStyle.none
    public var horizontalMargin: CGFloat = 10

    public init(title: String, handler: ((SwipedAction) -> Void)?) {
        self.title = title
        self.handler = handler
    }

    public init(title: String, backgroundColor: UIColor, titleColor: UIColor, titleFont: UIFont, preferredWidth: CGFloat?, handler: ((SwipedAction) -> Void)?) {
        self.title = title
        self.backgroundColor = backgroundColor
        self.titleColor = titleColor
        self.titleFont = titleFont
        self.preferredWidth = preferredWidth
        self.handler = handler
    }
}
