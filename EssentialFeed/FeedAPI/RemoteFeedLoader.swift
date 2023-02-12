//
//  RemoteFeedLoader.swift
//  EssentialFeed
//
//  Created by Roland Schmitz on 12.02.23.
//

import Foundation

public enum HTTPClientResult {
    case success(Data, HTTPURLResponse)
    case failure(Error)
}

public protocol HTTPClient {
    func get(from url: URL, completion: @escaping (HTTPClientResult) -> Void)
}

public final class RemoteFeedLoader {
    public init(url: URL, httpClient: HTTPClient) {
        self.url = url
        self.httpClient = httpClient
    }

    private let url: URL
    private let httpClient: HTTPClient

    public func load(completion: @escaping (Result) -> Void) {
        httpClient.get(from: url) { result in
            switch result {
            case .success(let data, let response):
                if response.statusCode == 200,
                   let _ = try? JSONSerialization.jsonObject(with: data)
                {
                    completion(.success([]))
                } else {
                    completion(.failure(.invalidData))
                }
            case .failure(_):
                completion(.failure(.connectivity))
            }
        }
    }

    public enum Error: Swift.Error {
        case connectivity
        case invalidData
    }

    public enum Result: Equatable {
        case success([FeedItem])
        case failure(Error)
    }
}
