//
//  NetTestController.swift
//  OPTAPM_Example
//
//  Created by yaoning on 12/12/19.
//  Copyright © 2019 CocoaPods. All rights reserved.
//

import UIKit
import FYTester

class NetTestController: UIViewController {

    private lazy var btn1: UIButton = {
        let b = UIButton()
        b.setTitle("test1", for: .normal)
        b.setTitleColor(UIColor.black, for: .normal)
        b.addTarget(self, action: #selector(test1Handler), for: .touchUpInside)
        return b
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor.white
        view.addSubview(btn1)
        btn1.frame = CGRect(x: 20, y: 100, width: 100, height: 40)
    }

    @objc func test1Handler() {
        let parameters = "{\"tabId\":0}"
        let postData = parameters.data(using: .utf8)

        var request = URLRequest(url: URL(string: "http://uat-sj-gateway.aihuishou.com/opt-content/app/ranking/items")!,timeoutInterval: Double.infinity)
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpMethod = "POST"
        request.httpBody = postData
        let config = URLSessionConfiguration.default
        FYTester.share.network.register(config)
        let session = URLSession(configuration: config)
        let task = session.dataTask(with: request) { data, response, error in
          guard let data = data else {
            print(String(describing: error))
            return
          }
//          print(String(data: data, encoding: .utf8)!)
        }

        task.resume()

        print("test1 Handler")

    }
}



