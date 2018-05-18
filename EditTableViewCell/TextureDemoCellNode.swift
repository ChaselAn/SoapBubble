//
//  TextureDemoCellNode.swift
//  EditTableViewCell
//
//  Created by ancheng on 2018/3/29.
//  Copyright © 2018年 ancheng. All rights reserved.
//

import UIKit
import AsyncDisplayKit

class TextureDemoCellNode: SwipableCellNode {

    let textNode = ASTextNode()

    override init(tableNode: ASTableNode) {
        super.init(tableNode: tableNode)

        view.backgroundColor = UIColor.green

        addSubnode(textNode)
        textNode.attributedText = NSAttributedString(string: "哈哈哈哈哈哈哈哈哈哈", attributes: [.foregroundColor: UIColor.black])

    }

    override func layoutSpecThatFits(_ constrainedSize: ASSizeRange) -> ASLayoutSpec {
        textNode.style.preferredSize = CGSize(width: 100, height: 100)
        return ASStackLayoutSpec(direction: .horizontal, spacing: 0, justifyContent: .center, alignItems: .center, children: [textNode])
    }


    public required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
