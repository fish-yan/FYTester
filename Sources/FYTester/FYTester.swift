//
//  FYWindow.swift
//  FYTester
//
//  Created by 薛焱 on 2022/4/2.
//

import UIKit

public class FYTester {
    public static let share = FYTester()

    public var tool = FYTool()

    public var network = FYNetwork()

    var window: FYTesterWindow?

    private init() {}

    /// Call on the main thread. Scene-based apps should prefer `start(in:)`.
    public func start() {
        precondition(Thread.isMainThread, "FYTester must be started on the main thread.")

        if #available(iOS 13.0, *) {
            let scenes = UIApplication.shared.connectedScenes.compactMap { $0 as? UIWindowScene }
            if let scene = scenes.first(where: { $0.activationState == .foregroundActive })
                ?? scenes.first(where: { $0.activationState == .foregroundInactive }) {
                start(in: scene)
                return
            }

            // Wait for the caller to supply a scene instead of creating an unattached window.
            if Bundle.main.object(forInfoDictionaryKey: "UIApplicationSceneManifest") != nil {
                return
            }
        }

        show(window ?? FYTesterWindow(frame: .zero))
    }

    /// Shows FYTester in the supplied scene without making the floating window key.
    /// Call on the main thread after setting up the scene's main window.
    @available(iOS 13.0, *)
    public func start(in windowScene: UIWindowScene) {
        precondition(Thread.isMainThread, "FYTester must be started on the main thread.")

        let window = window ?? FYTesterWindow(frame: .zero)
        window.attach(to: windowScene)
        show(window)
    }

    private func show(_ window: FYTesterWindow) {
        let shouldStart = self.window == nil
        self.window = window
        window.isHidden = false
        if shouldStart {
            window.start()
        }
    }
}
