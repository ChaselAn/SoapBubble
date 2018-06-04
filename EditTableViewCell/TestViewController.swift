//
//  TestViewController.swift
//  EditTableViewCell
//
//  Created by ancheng on 2018/6/4.
//  Copyright © 2018年 ancheng. All rights reserved.
//

import UIKit
import SoapBubble

class TestViewController: UIViewController {

    private var testView = UIView()

    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = UIColor.white

        testView.backgroundColor = UIColor.black
        testView.frame = CGRect(x: 100, y: 100, width: 100, height: 100)
        testView.soapBubble.swipableDelegate = self
        testView.soapBubble.isEnable = false
        view.addSubview(testView)
    }

    deinit {
        print("------------ vc deinit")
    }

}

extension TestViewController: SoapBubbleSource {
    func targetView() -> UIView {
        return self.testView
    }

    func actions(in object: SoapBubbleObject) -> [SoapBubbleAction] {
        return []
    }
}
