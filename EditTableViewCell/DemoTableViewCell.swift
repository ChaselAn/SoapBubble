//
//  DemoTableViewCell.swift
//  EditTableViewCell
//
//  Created by chaselan on 2018/3/26.
//  Copyright © 2018年 chaselan. All rights reserved.
//

import UIKit
import SoapBubble

class DemoTableViewCell: UITableViewCell, SoapBubbleSource {

    var actions: (() -> [SoapBubbleAction])?

    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        soapBubble.swipableDelegate = self
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }


    func targetView() -> UIView {
        return self
    }

    func actions(in object: SoapBubbleObject) -> [SoapBubbleAction] {
        return actions?() ?? []
    }

    deinit {
        print("--------------------- DemoTableViewCell deinit")
        soapBubble.reset()
    }
}
