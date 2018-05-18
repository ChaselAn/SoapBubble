//
//  Extension.swift
//  EditTableViewCell
//
//  Created by ancheng on 2018/3/27.
//  Copyright © 2018年 ancheng. All rights reserved.
//

import UIKit
import AsyncDisplayKit

public protocol SwipeTableViewCellDelegate {
    func swipe_tableView(_ tableView: UITableView, editActionsOptionsForRowAt indexPath: IndexPath) -> [SwipedAction]

    func swipe_tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool
}

//public class SwipedAction {
//
//    public enum ConfirmStyle {
//        case none
//        case custom(title: String)
//    }
//
//    public var title: String
//    public var backgroundColor: UIColor = UIColor.red
//    public var titleColor: UIColor = UIColor.white
//    public var titleFont: UIFont = UIFont.systemFont(ofSize: 14)
//    public var preferredWidth: CGFloat?
//    public var handler: ((SwipedAction) -> Void)?
//    public var needConfirm = ConfirmStyle.none
//
//    public init(title: String, handler: ((SwipedAction) -> Void)?) {
//        self.title = title
//        self.handler = handler
//    }
//
//    public init(title: String, backgroundColor: UIColor, titleColor: UIColor, titleFont: UIFont, preferredWidth: CGFloat?, handler: ((SwipedAction) -> Void)?) {
//        self.title = title
//        self.backgroundColor = backgroundColor
//        self.titleColor = titleColor
//        self.titleFont = titleFont
//        self.preferredWidth = preferredWidth
//        self.handler = handler
//    }
//}

extension String {

    func getWidth(withFont font: UIFont) -> CGFloat {
        return (self as NSString).size(withAttributes: [.font: font]).width + 1
    }
}

extension ASTableNode {

    private static var circle_swipeDelegateKey: Character!

    public weak var circle_swipeDelegate: ASTableNodeSwipableDelegate? {
        set {
            objc_setAssociatedObject(self, &ASTableNode.circle_swipeDelegateKey, newValue, .OBJC_ASSOCIATION_RETAIN)
        }
        get {
            return objc_getAssociatedObject(self, &ASTableNode.circle_swipeDelegateKey) as? ASTableNodeSwipableDelegate
        }
    }

}
