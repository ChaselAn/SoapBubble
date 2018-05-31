//
//  TestTableViewController.swift
//  EditTableViewCell
//
//  Created by ancheng on 2018/5/18.
//  Copyright © 2018年 ancheng. All rights reserved.
//

import UIKit
import SoapBubble

class TestTableViewController: UIViewController {

    private lazy var tableView = UITableView()
    private var count = 20

    override func viewDidLoad() {
        super.viewDidLoad()
        view.addSubview(tableView)
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
        tableView.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
        tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true

        tableView.dataSource = self
        tableView.register(DemoTableViewCell.self, forCellReuseIdentifier: "DemoTableViewCell")
    }

}

extension TestTableViewController: UITableViewDataSource {

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "DemoTableViewCell", for: indexPath) as! DemoTableViewCell
        cell.actions = {
            let deleteAction = SoapBubbleAction(title: "删除") { [weak self, weak tableView] (_) in
                self?.count -= 1
                tableView?.deleteRows(at: [indexPath], with: .automatic)
            }
            deleteAction.needConfirm = .custom(title: "确认删除")
            let unreadAction = SoapBubbleAction(title: "标记未读") { (_) in

            }
            unreadAction.needConfirm = .custom(title: "确认删除")
            unreadAction.backgroundColor = .gray

            if indexPath.row % 3 == 0 {
                deleteAction.preferredWidth = 100
            }

            if indexPath.row % 2 == 1 {
                return [unreadAction, deleteAction]
            } else {
                return [deleteAction]
            }
        }
        cell.textLabel?.text = "哈哈哈哈哈哈哈哈哈哈"
        return cell
    }
}
