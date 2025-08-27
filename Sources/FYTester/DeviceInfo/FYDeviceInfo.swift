//
//  FYFPS.swift
//  FYTester
//
//  Created by 薛焱 on 2022/4/2.
//

import CoreTelephony
import UIKit
import FYTesterOC

class FYDeviceInfo: NSObject {
    /// 系统名称
    static var systemName: String {
        return UIDevice.current.systemName
    }
    /// 系统版本
    static var systemVersion: String {
        return UIDevice.current.systemVersion
    }
    /// 系统类型
    static var model: String {
        return UIDevice.current.model
    }
    /// 获取设备名称
    static var name: String {
        return UIDevice.current.name
    }
    /// 设备机型标识符
    static var deviceModel: String {
        return FYHardware.deviceModel()
    }

    // MARK: - CPU
    /// CPU 架构
    static var cpuArch: String {
        return FYHardware.cpuArch()
    }
    /// CPU 数量
    static var countOfCores: UInt32 {
        return FYHardware.countOfCores()
    }
    /// GPU 种类
    static var gpuType: String {
        return FYHardware.gpuType()
    }
    /// cpu占用
    static var cpuUsage: CGFloat {
        return FYCPU.cpuUsage()
    }
    /// 屏幕分辨率
    static var screenResolution: String {
        return FYHardware.screenResolution()
    }

    // MARK: - 内存
    /// 总内存
    static var memoryTotal: UInt64 {
        return FYMemoryInfo.memoryTotal()
    }
    /// 已用内存
    static var memoryUsage: UInt64 {
        return FYMemoryInfo.memoryUsed()
    }
    /// 剩余内存
    static var memoryFree: UInt64 {
        return FYMemoryInfo.memoryFree()
    }
    /// App 占用内存
    static var memoryAppUsage: UInt64 {
        return FYMemoryInfo.memoryAppUsed()
    }

    // MARK: - 磁盘
    /// 系统总存储
    static var diskTotal: UInt64 {
        var fs = blankof(type: statfs.self)
        if statfs("/var",&fs) >= 0{
            return UInt64(fs.f_bsize) * fs.f_blocks
        }
        return 0
    }
    /// 系统可用存储
    static var diskAvailable: UInt64 {
        var fs = blankof(type: statfs.self)
        if statfs("/var",&fs) >= 0{
            return UInt64(fs.f_bsize) * fs.f_bavail
        }
        return 0
    }

    // MARK: - 网络
    /// 当前网络
    static var network: String {
        return getNetWorkStatus()
    }
    /// ip
    static var ip: String {
        return deviceIP()
    }

    // MARK: - 相机
    /// 后摄分辨率
    static var backCameraResolution: String {
        return FYHardware.backCameraResolution()
    }
    /// 前摄分辨率
    static var frontCameraResolution: String {
        return FYHardware.frontCameraResolution()
    }
    // MARK: - 其他
    /// 生物识别
    static var biometryAvailable: Bool {
        return FYHardware.biometryAvailable()
    }
    /// Touch 3D
    static var touch3DAvailable: Bool {
        return FYHardware.touch3DAvailable()
    }
    /// 是否越狱
    static var isDeviceJailbroken: Bool {
        return FYHardware.isDeviceJailbroken()
    }

    private class func blankof<T>(type:T.Type) -> T {
        let ptr = UnsafeMutablePointer<T>.allocate(capacity: MemoryLayout<T>.size)
        let val = ptr.pointee
        return val
    }

    /// 获取当前设备IP
    private static func deviceIP() -> String {
        var addresses = [String]()
        var ifaddr : UnsafeMutablePointer<ifaddrs>? = nil
        if getifaddrs(&ifaddr) == 0 {
            var ptr = ifaddr
            while (ptr != nil) {
                let flags = Int32(ptr!.pointee.ifa_flags)
                var addr = ptr!.pointee.ifa_addr.pointee
                if (flags & (IFF_UP|IFF_RUNNING|IFF_LOOPBACK)) == (IFF_UP|IFF_RUNNING) {
                    if addr.sa_family == UInt8(AF_INET) || addr.sa_family == UInt8(AF_INET6) {
                        var hostname = [CChar](repeating: 0, count: Int(NI_MAXHOST))
                        if (getnameinfo(&addr, socklen_t(addr.sa_len), &hostname, socklen_t(hostname.count),nil, socklen_t(0), NI_NUMERICHOST) == 0) {
                            if let address = String(validatingUTF8:hostname) {
                                addresses.append(address)
                            }
                        }
                    }
                }
                ptr = ptr!.pointee.ifa_next
            }
            freeifaddrs(ifaddr)
        }
        if let ipStr = addresses.first {
            return ipStr
        } else {
            return ""
        }
    }

    /// 获取当前网络
    private static func getNetWorkStatus() -> String {
        var network = "UNKNOWN"
        let reachability = FYReachability()
        let status = reachability?.currentReachabilityStatus()
        switch status {
        case .reachableViaWiFi:
            network = "WIFI"
        case .reachableViaWWAN:
            let netInfo = CTTelephonyNetworkInfo()
            switch netInfo.currentRadioAccessTechnology {
            case CTRadioAccessTechnologyGPRS:
                network = "2G"
            case CTRadioAccessTechnologyEdge:
                network = "2.5G"
            case CTRadioAccessTechnologyWCDMA,
            CTRadioAccessTechnologyCDMA1x,
            CTRadioAccessTechnologyCDMAEVDORev0,
            CTRadioAccessTechnologyCDMAEVDORevA,
            CTRadioAccessTechnologyCDMAEVDORevB,
            CTRadioAccessTechnologyeHRPD:
                network = "3G"
            case CTRadioAccessTechnologyHSDPA,
            CTRadioAccessTechnologyHSUPA:
                network = "3.5G"
            case CTRadioAccessTechnologyLTE:
                network = "4G"
            default: break
            }
            if #available(iOS 14.1, *) {
                if netInfo.currentRadioAccessTechnology == CTRadioAccessTechnologyNRNSA ||
                    netInfo.currentRadioAccessTechnology == CTRadioAccessTechnologyNR {
                    network = "5G"
                }
            }
        default: break
        }
        return network
    }
}

