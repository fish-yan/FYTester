//
//  FYNetworkResponseViewController.swift
//  FYTester
//
//  Created by 薛焱 on 2022/4/13.
//

import UIKit

class FYNetworkResponseViewController: UIViewController {

    var response: [String: Any?]?
    private lazy var textView: UITextView = {
        let tv = UITextView(frame: view.bounds)
        tv.font = UIFont.systemFont(ofSize: 12)
        tv.textColor = UIColor(white: 0.2, alpha: 1)
        tv.isEditable = false
        tv.textContainerInset = UIEdgeInsets(top: 12, left: 12, bottom: 12, right: 12)
        tv.textContainer.lineFragmentPadding = 0
        tv.backgroundColor = .clear
        return tv
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Response"
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Copy", style: .plain, target: self, action: #selector(copyAction))
        view.backgroundColor = .white
        view.addSubview(textView)
        if let response = response,
           let data = try? JSONSerialization.data(withJSONObject: response, options: .prettyPrinted) {
            let str = String(data: data, encoding: .utf8)
            textView.text = str?.replacingOccurrences(of: "\\", with: "")
        }
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        textView.setContentOffset(.init(x: 0, y: -UIApplication.shared.statusBarFrame.height
                                        - 44), animated: false)
    }

    @objc func copyAction() {
        UIPasteboard.general.string = textView.text
    }

}
