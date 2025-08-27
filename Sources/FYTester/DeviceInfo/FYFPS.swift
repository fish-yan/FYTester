//
//  FYFPS.swift
//  FYTester
//
//  Created by 薛焱 on 2022/4/2.
//

import Foundation
import UIKit

class FYFPS {
    var start = false
    var count = 0
    var fps = 60
    var lastTime: CFTimeInterval = 0
    var link: CADisplayLink?
    var fpsBlock: ((Int) -> Void)?

    init() {
        watch()
    }

    func watch() {
        if start { return }

        link = CADisplayLink(target: self, selector: #selector(trigger(link:)))
        link?.add(to: .main, forMode: .common)
    }

    func unWatch() {
        link?.isPaused = true
        link?.invalidate()
        link = nil
        lastTime = 0
        count = 0
    }
}

private extension FYFPS {

    /// 核心实现函数
    /// CADisplayLink 每次屏幕刷新会调用该方法 正常刷新率60Hz 即60帧在1s内会调用60次
    /// 统计1s内调用次数 即可反映帧率
    /// 但只有指导意义 它反映的是当前runloop的帧率 并不能反映Core Animation的性能情况
    ///  1. 记录上一次时间戳 与当前时间戳相减 不足1s 记录一次刷新count +1
    ///  2. 足1s 计算count数量 即过去1s 调用的次数
    /// - Parameter link:
    @objc func trigger(link: CADisplayLink) {
        if lastTime == 0 {
            lastTime = link.timestamp
            return
        }
        count += 1
        let delta = link.timestamp - lastTime
        if delta < 1 { return }

        lastTime = link.timestamp
        let fps = Double(count) / delta
        count = 0
        let intFps = Int(fps + 0.5)
        self.fps = intFps

        fpsBlock?(self.fps)
    }
}

