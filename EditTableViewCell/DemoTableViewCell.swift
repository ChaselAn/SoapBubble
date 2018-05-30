//
//  DemoTableViewCell.swift
//  EditTableViewCell
//
//  Created by ancheng on 2018/3/26.
//  Copyright © 2018年 ancheng. All rights reserved.
//

import UIKit
import SoapBubble

class DemoTableViewCell: UITableViewCell, SwipableSource {

    weak var tableView: UITableView!

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
}
