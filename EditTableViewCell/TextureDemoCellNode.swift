//
//  TextureDemoCellNode.swift
//  EditTableViewCell
//
//  Created by chaselan on 2018/3/29.
//  Copyright © 2018年 chaselan. All rights reserved.
//

import UIKit
import AsyncDisplayKit
import SoapBubble

class TextureDemoCellNode: ASCellNode, SoapBubbleSource {

    let textNode = ASTextNode()
    var actions: (() -> [SoapBubbleAction])?

    override init() {
        super.init()

        view.backgroundColor = UIColor.green
        view.soapBubble.swipableDelegate = self

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

    func targetView() -> UIView {
        return view
    }

    func canSwipe(in object: SoapBubbleObject) -> Bool {
        return true
    }

    func actions(in object: SoapBubbleObject) -> [SoapBubbleAction] {
        return actions?() ?? []
    }
}
