//
//  TestASTableViewController.swift
//  EditTableViewCell
//
//  Created by ancheng on 2018/5/18.
//  Copyright © 2018年 ancheng. All rights reserved.
//

import UIKit
import AsyncDisplayKit
import SoapBubble

class TestASTableViewController: UIViewController {

    private lazy var tableNode = ASTableNode()
    private var count = 20

    override func viewDidLoad() {
        super.viewDidLoad()

        view.addSubnode(tableNode)
        tableNode.dataSource = self
        tableNode.swipableCellDelegate = self
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()

        tableNode.frame = view.bounds
    }
}

extension TestASTableViewController: ASTableDataSource {

    func numberOfSections(in tableNode: ASTableNode) -> Int {
        return 1
    }

    func tableNode(_ tableNode: ASTableNode, numberOfRowsInSection section: Int) -> Int {
        return count
    }

    func tableNode(_ tableNode: ASTableNode, nodeForRowAt indexPath: IndexPath) -> ASCellNode {
        let cell: ASCellNode
        cell = TextureDemoCellNode()
        return cell
    }
}

extension TestASTableViewController: ASTableNodeSwipableDelegate {

    public func swipe_tableNode(_ tableNode: ASTableNode, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }

    public func swipe_tableNode(_ tableNode: ASTableNode, editActionsOptionsForRowAt indexPath: IndexPath) -> [SoapBubbleAction] {

        guard let cell = tableNode.nodeForRow(at: indexPath) as? TextureDemoCellNode else { return [] }
        let deleteAction = SoapBubbleAction(title: "删除", backgroundColor: #colorLiteral(red: 1, green: 0.01568627451, blue: 0.3450980392, alpha: 1), titleColor: UIColor.white, titleFont: UIFont.systemFont(ofSize: 17, weight: .medium), preferredWidth: nil, handler: { [weak tableNode, weak self] (action) in
            action.isEnabled = false
            self?.count -= 1
            tableNode?.deleteRows(at: [indexPath], with: .automatic)
            action.isEnabled = true

        })
        deleteAction.needConfirm = .custom(title: "确认删除")

        let markAction: SoapBubbleAction

        let markAsRead = SoapBubbleAction(title: "标记未读", handler: { (_) in
//            cell.hideSwipe(animated: true)
        })
        markAction = markAsRead

        markAction.backgroundColor = #colorLiteral(red: 0.8117647059, green: 0.8117647059, blue: 0.8117647059, alpha: 1)
        markAction.titleFont = UIFont.systemFont(ofSize: 17, weight: .medium)
        markAction.horizontalMargin = 24
        deleteAction.horizontalMargin = 24

        return [markAction, deleteAction]
    }

}
