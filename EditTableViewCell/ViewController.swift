//
//  ViewController.swift
//  EditTableViewCell
//
//  Created by chaselan on 2018/3/26.
//  Copyright © 2018年 chaselan. All rights reserved.
//

import UIKit
import AsyncDisplayKit

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        let tableViewButton = UIButton(type: .system)
        tableViewButton.setTitle("UITableView", for: .normal)
        tableViewButton.addTarget(self, action: #selector(tableViewButtonClicked), for: .touchUpInside)
        tableViewButton.frame = CGRect(x: 50, y: 200, width: 100, height: 50)

        let asTableViewButton = UIButton(type: .system)
        asTableViewButton.setTitle("ASTableView", for: .normal)
        asTableViewButton.addTarget(self, action: #selector(asTableViewButtonClicked), for: .touchUpInside)
        asTableViewButton.frame = CGRect(x: 200, y: 200, width: 100, height: 50)

        view.addSubview(tableViewButton)
        view.addSubview(asTableViewButton)
    }

    @objc private func tableViewButtonClicked() {
        let tableVC = TestTableViewController()
        navigationController?.pushViewController(tableVC, animated: true)
    }

    @objc private func asTableViewButtonClicked() {
        let tableVC = TestASTableViewController()
        navigationController?.pushViewController(tableVC, animated: true)
    }
}
