//
//  Extension.swift
//  EditTableViewCell
//
//  Created by chaselan on 2018/3/27.
//  Copyright © 2018年 chaselan. All rights reserved.
//

import UIKit
import AsyncDisplayKit

extension String {

    func soapBubble_getWidth(withFont font: UIFont) -> CGFloat {
        return (self as NSString).size(withAttributes: [.font: font]).width + 1
    }
}
