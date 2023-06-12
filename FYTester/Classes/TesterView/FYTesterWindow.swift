//
//  FYTesterWindow.swift
//  FYTester
//
//  Created by 薛焱 on 2022/4/3.
//

import UIKit

class FYTesterWindow: UIWindow {

    private let testerSize = CGSize(width: 70, height: 70)

    private lazy var testerView = FYTesterView(frame: CGRect(origin: .zero, size: testerSize))

    private lazy var fps = FYFPS()

    override init(frame: CGRect) {
        super.init(frame: CGRect(origin: CGPoint(x: 100, y: 100), size: testerSize))
        backgroundColor = .clear
        windowLevel = .alert + 100
        rootViewController = UIViewController()
        rootViewController?.view.addSubview(testerView)
        isHidden = false
        let pan = UIPanGestureRecognizer(target: self, action: #selector(panAction(_:)))
        addGestureRecognizer(pan)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }


    @objc func panAction(_ pan: UIPanGestureRecognizer) {
        guard let panView = pan.view else { return }
        /// 拖动位移
        let offsetPoint = pan.translation(in: panView)
        /// 清空位移
        pan.setTranslation(.zero, in: panView)
        /// 重新计算位置
        var newX = panView.center.x + offsetPoint.x
        var newY = panView.center.y + offsetPoint.y
        if newX < testerSize.width / 2 {
            newX = testerSize.width / 2
        }
        if newX > UIScreen.main.bounds.width - testerSize.width / 2 {
            newX = UIScreen.main.bounds.width - testerSize.width / 2
        }
        if newY < testerSize.height / 2 {
            newY = testerSize.height / 2
        }
        if newY > UIScreen.main.bounds.height - testerSize.height / 2 {
            newY = UIScreen.main.bounds.height - testerSize.height / 2
        }
        panView.center = CGPoint(x: newX, y: newY)
    }

    func start() {
        testerView.updateUI(FYDeviceInfo.cpuUsage, memory: FYDeviceInfo.memoryAppUsage, fps: fps.fps, net: FYDeviceInfo.network)
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            self.start()
        }
    }
    
}
