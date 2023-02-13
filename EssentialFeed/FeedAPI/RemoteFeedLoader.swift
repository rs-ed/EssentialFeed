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
                   let root = try? JSONDecoder().decode(Root.self, from: data)
                {
                    completion(.success(root.feedItems))
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

    private struct Root: Decodable {
        let items: [Item]

        var feedItems: [FeedItem] {
            items.map(\.feedItem)
        }
    }

    private struct Item: Decodable, Equatable {
        let id: UUID
        let description: String?
        let location: String?
        let image: URL

        var feedItem: FeedItem {
            FeedItem(id: id, description: description, location: location, imageURL: image)
        }
    }

}
