//
//  FYWindow.swift
//  FYTester
//
//  Created by 薛焱 on 2022/4/2.
//

import Foundation

public class FYTester {
    public static let share = FYTester()

    public var tool = FYTool()

    public var network = FYNetwork()

    var window: FYTesterWindow?

    private init() {}

    public func start() {
        if window != nil { return }
        window = FYTesterWindow(frame: .zero)
        window?.start()
    }
}
