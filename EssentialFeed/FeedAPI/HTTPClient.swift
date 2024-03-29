//
//  HTTPClient.swift
//  EssentialFeed
//
//  Created by Roland Schmitz on 13.02.23.
//

import Foundation


public protocol HTTPClient {
    typealias Result = Swift.Result<(Data, HTTPURLResponse), Error>

        /// The completion handler can be invoked in any thread.
        /// Clients are responsible to dispatch to appropriate threads,
    func get(from url: URL, completion: @escaping (HTTPClient.Result) -> Void)
}
