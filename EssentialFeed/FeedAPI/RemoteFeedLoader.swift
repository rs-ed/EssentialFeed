//
//  RemoteFeedLoader.swift
//  EssentialFeed
//
//  Created by Roland Schmitz on 12.02.23.
//

import Foundation

public protocol HTTPClient {
    func get(from url: URL, completion: @escaping (Error?, HTTPURLResponse?) -> Void)
}

public final class RemoteFeedLoader {
    public init(url: URL, httpClient: HTTPClient) {
        self.url = url
        self.httpClient = httpClient
    }

    private let url: URL
    private let httpClient: HTTPClient

    public func load(completion: @escaping (Error) -> Void) {
        httpClient.get(from: url) { clientError, response in
            if response != nil {
                completion(.invalidData)
            } else {
                completion(.connectivity)
            }
        }
    }

    public enum Error: Swift.Error {
        case connectivity
        case invalidData
    }
}
