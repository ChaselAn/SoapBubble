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

    private let tableView = UITableView()
    private let dataSource = [("on UIView"),
                              ("on UITableViewCell"),
                              ("on ASCellNode(Texture)")]

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

        tableView.frame = view.bounds
        tableView.delegate = self
        tableView.dataSource = self
//        tableView.contentInset = UIEdgeInsets(top: 64, left: 0, bottom: 0, right: 0)
        view.addSubview(tableView)
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

extension ViewController: UITableViewDataSource, UITableViewDelegate {

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dataSource.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell(style: .default, reuseIdentifier: "a")
        cell.textLabel?.text = dataSource[indexPath.row]
        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let vc: UIViewController
        switch indexPath.row {
        case 0:
            vc = TestViewController()
        case 1:
            vc = TestTableViewController()
        case 2:
            vc = TestASTableViewController()
        default:
            return
        }
        navigationController?.pushViewController(vc, animated: true)
    }
}
