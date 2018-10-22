//
//  Downloader.swift
//  simplePlayer
//
//  Created by Brian D Keane on 10/22/18.
//  Copyright © 2018 Brian D Keane. All rights reserved.
//

import UIKit

public class Downloader: NSObject, Downloadable {
    public var delegate: DownloadableDelegate?
    public var progress: Float = 0
    public var state: DownloadableState = .notStarted {
        didSet {
            delegate?.download(self, changedState: state)
        }
    }
    public var url:URL?  {
        didSet {
            if state == .started {
                stop()
            }
            
            if let url = url {
                progress = 0.0
                state = .notStarted
                totalBytesCount = 0
                totalBytesCount = 0
                task = session.dataTask(with: url)
            } else {
                task = nil
            }
        }
    }
    
    /// The `URLSession` currently being used as the HTTP/HTTPS implementation for the downloader.
    fileprivate lazy var session: URLSession = {
        return URLSession(configuration: .default, delegate: self, delegateQueue: nil)
    }()
    
    /// A `URLSessionDataTask` representing the data operation for the current `URL`.
    fileprivate var task: URLSessionDataTask?
    
    /// A `Int64` representing the total amount of bytes received
    var totalBytesReceived: Int64 = 0
    
    /// A `Int64` representing the total amount of bytes for the entire file
    var totalBytesCount: Int64 = 0
    
    public func start() {
        guard let task = task else {
            return
        }
        
        switch state {
        case .completed, .started:
            return
        default:
            state = .started
            task.resume()
        }
    }
    
    public func pause() {
        guard let task = task else {
            return
        }
        
        guard state == .started else {
            return
        }
        
        state = .stopped
        task.cancel()
    }
    
    public func stop() {
        guard let task = task else {
            return
        }
        
        guard state == .started else {
            return
        }
        
        state = .stopped
        task.cancel()
    }
}

extension Downloader: URLSessionDataDelegate {
    public func urlSession(_ session: URLSession, dataTask: URLSessionDataTask, didReceive response: URLResponse, completionHandler: @escaping (URLSession.ResponseDisposition) -> Void) {
        totalBytesCount = response.expectedContentLength
        completionHandler(.allow)
    }
    
    public func urlSession(_ session: URLSession, dataTask: URLSessionDataTask, didReceive data: Data) {
        totalBytesReceived += Int64(data.count)
        progress = Float(totalBytesReceived) / Float(totalBytesCount)
        delegate?.download(self, didReceiveData: data, progress: progress)
//        progressHandler?(data, progress)
    }
    
    public func urlSession(_ session: URLSession, task: URLSessionTask, didCompleteWithError error: Error?) {
        state = .completed
        delegate?.download(self, completedWithError: error)
//        completionHandler?(error)
    }
}
