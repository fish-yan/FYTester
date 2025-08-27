//
//  FYTool.swift
//  FYTester
//
//  Created by 薛焱 on 2022/4/12.
//

import UIKit

public enum Env: String {
    case dev = "Dev"
    case fat = "FAT"
    case uat = "UAT"
    case release = "Release"

    var color: UIColor {
        switch FYTester.share.tool.env {
        case .dev:
            return .lightGray
        case .fat:
            return .systemTeal
        case .uat:
            return .orange
        case .release:
            return .red
        }
    }
}

open class FYTool: NSObject {
    public var envs: [Env] = [.dev, .fat, .uat, .release]
    public var commons: [String] = ["系统信息", "网络监控"]
    public var plugins: [String] = []
    public var others: [String] = []

    public var nav: UINavigationController?
    public weak var delegate: FYToolDelegate?
    public var env: Env = .dev

    public func dismiss() {
        let window = nav?.view.window
        nav?.dismiss(animated: true, completion: {
            window?.isHidden = true
        })
    }
}
