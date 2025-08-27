//
//  FYNetwork.swift
//  FYTester
//
//  Created by 薛焱 on 2022/4/4.
//

import UIKit

public class FYNetwork {
    var networks = [NetworkModel]()

    public func register(_ configuration: URLSessionConfiguration) {
        var protocolClasses = configuration.protocolClasses
        protocolClasses?.insert(FYURLProtocol.self, at: 0)
        configuration.protocolClasses = protocolClasses
    }
}

extension FYNetwork {
    struct NetworkModel {
        var params: [String: Any?]?
        var header: [String: String]?
        var response: [String: Any?]?
        var url: String?
        var method: String?
        var duration: Int = 0
        var curl: String?
    }
}
