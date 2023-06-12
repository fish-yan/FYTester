//
//  ViewController.swift
//  FYTester
//
//  Created by 薛焱 on 04/02/2022.
//  Copyright (c) 2022 薛焱. All rights reserved.
//

import UIKit
import FYTester

class ViewController: UIViewController {

    private lazy var netBtn: UIButton = {
        let btn = UIButton(type: .system)
        btn.setTitle("网络", for: .normal)
        btn.addTarget(self, action: #selector(netAction), for: .touchUpInside)
        return btn
    }()

    private lazy var contentView: UIStackView = {
        let views: [UIView] = [netBtn]
        let stackView = UIStackView(arrangedSubviews: views)
        stackView.axis = .vertical
        stackView.spacing = 10
        return stackView
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        view.addSubview(contentView)
        contentView.frame = CGRect(x: 0, y: 100, width: 100, height: 50)
    }

    @objc func netAction() {
        let vc = NetTestController()
        navigationController?.pushViewController(vc, animated: true)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}

