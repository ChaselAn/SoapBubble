//
//  Extension.swift
//  EditTableViewCell
//
//  Created by ancheng on 2018/3/27.
//  Copyright © 2018年 ancheng. All rights reserved.
//

import UIKit
import AsyncDisplayKit

extension String {

    func getWidth(withFont font: UIFont) -> CGFloat {
        return (self as NSString).size(withAttributes: [.font: font]).width + 1
    }
}

extension ASTableNode {

    private static var swipableCellDelegateKey: Character!

    public weak var swipableCellDelegate: ASTableNodeSwipableDelegate? {
        set {
            objc_setAssociatedObject(self, &ASTableNode.swipableCellDelegateKey, newValue, .OBJC_ASSOCIATION_RETAIN)
        }
        get {
            return objc_getAssociatedObject(self, &ASTableNode.swipableCellDelegateKey) as? ASTableNodeSwipableDelegate
        }
    }

}

extension UITableView {

    private static var swipableCellDelegateKey: Character!

    public weak var swipableCellDelegate: UITableViewSwipableCellDelegate? {
        set {
            objc_setAssociatedObject(self, &UITableView.swipableCellDelegateKey, newValue, .OBJC_ASSOCIATION_RETAIN)
        }
        get {
            return objc_getAssociatedObject(self, &UITableView.swipableCellDelegateKey) as? UITableViewSwipableCellDelegate
        }
    }

}
