//
//  FYURLProtocol.swift
//  FYTester
//
//  Created by 薛焱 on 2022/4/4.
//

import UIKit

class FYURLProtocol: URLProtocol {

    private var dataTask: URLSessionDataTask?

    private var mutData: Data?

    private var response: [String: Any?]?

    private var startTime: Date?

    private static let propertyKey = "FYURLProtocolPropertyKey"

    /// 可以处理哪些请求
    override class func canInit(with request: URLRequest) -> Bool {
        // 已处理过
        if let result = URLProtocol.property(forKey: propertyKey, in: request) as? Bool, result {
            return false
        }
        // 只处理 http 和 https
        if request.url?.scheme != "http" && request.url?.scheme != "https" {
            return false
        }
        // 文件类型不做处理
        if let contentType = request.value(forHTTPHeaderField: "Content-Type"),
           contentType.contains("multipart/form-data") {
            return false
        }
        return true
    }

    /// 可以修改request
    override class func canonicalRequest(for request: URLRequest) -> URLRequest {
        if let mutableReq = (request as NSURLRequest).mutableCopy() as? NSMutableURLRequest {
            URLProtocol.setProperty(true, forKey: propertyKey, in: mutableReq)
            return mutableReq as URLRequest
        }
        return request
    }
    override func startLoading() {
        startTime = Date()
        let config = URLSessionConfiguration.default
        let session = URLSession(configuration: config, delegate: self, delegateQueue: nil)
        dataTask = session.dataTask(with: request)
        dataTask?.resume()
    }

    override func stopLoading() {
        var data = Data()
        if let input = request.httpBodyStream {
            input.open()
            let bufferSize = 1024
            let buffer = UnsafeMutablePointer<UInt8>.allocate(capacity: bufferSize)
            while input.hasBytesAvailable {
                let read = input.read(buffer, maxLength: bufferSize)
                data.append(buffer, count: read)
            }
            buffer.deallocate()
            input.close()
        }
        let params = try? JSONSerialization.jsonObject(with: data, options: .mutableContainers) as? [String: Any?]
        let endTime = Date()
        let startTime = startTime ?? Date()
        let time = Int(round(endTime.timeIntervalSince(startTime) * 1000))
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            let network = FYNetwork.NetworkModel(
                params: params,
                header: self.request.allHTTPHeaderFields,
                response: self.response,
                url: self.request.url?.absoluteString,
                method: self.request.httpMethod,
                duration: time,
                curl: self.request.curl
            )
            FYTester.share.network.networks.insert(network, at: 0)
            if FYTester.share.network.networks.count > 200 {
                FYTester.share.network.networks = FYTester.share.network.networks.dropLast()
            }
        }
        if dataTask != nil {
            dataTask?.cancel()
            dataTask = nil
        }
    }
}

extension FYURLProtocol: URLSessionDataDelegate, URLSessionTaskDelegate {
    func urlSession(_ session: URLSession, dataTask: URLSessionDataTask, didReceive response: URLResponse, completionHandler: @escaping (URLSession.ResponseDisposition) -> Void) {
        client?.urlProtocol(self, didReceive: response, cacheStoragePolicy: .allowed)
        mutData = Data()
        completionHandler(.allow)
    }

    func urlSession(_ session: URLSession, dataTask: URLSessionDataTask, didReceive data: Data) {
        client?.urlProtocol(self, didLoad: data)
        mutData?.append(data)
    }

    func urlSession(_ session: URLSession, task: URLSessionTask, didCompleteWithError error: Error?) {
        if let error = error {
            client?.urlProtocol(self, didFailWithError: error)
        } else {
            client?.urlProtocolDidFinishLoading(self)
        }
        if let data = mutData {
            response = try? JSONSerialization.jsonObject(with: data, options: .mutableContainers) as? [String: Any?]
        }
    }
}
