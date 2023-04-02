//
//  HTTPClient.swift
//  EssentialFeed
//
//  Created by Roland Schmitz on 13.02.23.
//

import Foundation

public enum HTTPClientResult {
    case success(Data, HTTPURLResponse)
    case failure(Error)
}

public protocol HTTPClient {
        /// The completion handler can be invoked in any thread.
        /// Clients are responsible to dispatch to appropriate threads,
    func get(from url: URL, completion: @escaping (HTTPClientResult) -> Void)
}
