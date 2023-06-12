//
//  Extension.swift
//  FYTester
//
//  Created by 薛焱 on 2022/4/13.
//

import UIKit

extension URLRequest {

    var curl: String {
        guard let url = url, let method = httpMethod else {
            return "$ curl command could not be created"
        }

        var components = ["curl -v"]
        components.append("-X \(method)")
        var headers: [String: String] = [:]
        if let headerFields = allHTTPHeaderFields {
            for (field, value) in headerFields {
                headers[field] = value
            }
        }

        for (field, value) in headers {
            if field == "Accept-Encoding" { continue }
            let escapedValue = value.replacingOccurrences(of: "\"", with: "\\\"")
            components.append("-H \"\(field): \(escapedValue)\"")
        }

        if let httpBodyData = httpBody, let httpBody = String(data: httpBodyData, encoding: .utf8) {
            var escapedBody = httpBody.replacingOccurrences(of: "\\\"", with: "\\\\\"")
            escapedBody = escapedBody.replacingOccurrences(of: "\"", with: "\\\"")
            components.append("-d \"\(escapedBody)\"")
        }
        if let httpBodyStream = httpBodyStream {
            let streamData = Data(reading: httpBodyStream)
            if let streamString = String(data: streamData, encoding: .utf8) {
                var escapedBody = streamString.replacingOccurrences(of: "\\\"", with: "\\\\\"")
                escapedBody = escapedBody.replacingOccurrences(of: "\"", with: "\\\"")
                components.append("-d \"\(escapedBody)\"")
            }
        }
        components.append("\"\(url.absoluteString)\"")
        return components.joined(separator: " \\\n\t")
    }
}

extension Data {
    /**
     Consumes the specified input stream, creating a new Data object
     with its content.
     - Parameter reading: The input stream to read data from.
     - Note: Closes the specified stream.
     */
    init(reading input: InputStream) {
        self.init()
        input.open()

        let bufferSize = 1024
        let buffer = UnsafeMutablePointer<UInt8>.allocate(capacity: bufferSize)
        while input.hasBytesAvailable {
            let read = input.read(buffer, maxLength: bufferSize)
            self.append(buffer, count: read)
        }
        buffer.deallocate()

        input.close()
    }
}

extension Bool {
    var string: String {
        return self ? "是" : "否"
    }
}

extension UInt64 {
    /// 将文件大小转换成字符串用以显示
    var fileString: String {
        return size(1000)
    }
    /// 将内存大小转换成字符串用以显示
    var memoryString: String {
        return size(1024)
    }

    private func size(_ unit: CGFloat) -> String {

        let size = CGFloat(self)
        let KB: CGFloat = unit // 厂家存储计算方式是按1000而非1024
        let MB: CGFloat = KB*KB
        let GB: CGFloat = MB*KB

        if size < 10 {
            return "0B"
        } else if size < KB {
            return "< 1K"
        } else if size < MB {
            return String(format: "%.1fK", size/KB)
        } else if size < GB {
            return String(format: "%.1fM", size/MB)
        } else {
            return String(format: "%.1fG", size/GB)
        }
    }
}
