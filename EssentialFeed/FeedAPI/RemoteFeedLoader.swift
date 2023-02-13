//
//  RemoteFeedLoader.swift
//  EssentialFeed
//
//  Created by Roland Schmitz on 12.02.23.
//

import Foundation

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
                do {
                    let items = try FeedItemsMapper.map(data: data, response: response)
                    completion(.success(items))
                } catch {
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

    private class FeedItemsMapper {
        static var ok_200: Int { 200 }

        static func map(data: Data, response: HTTPURLResponse) throws -> [FeedItem] {
            guard response.statusCode == ok_200 else {
                throw RemoteFeedLoader.Error.invalidData
            }
            return try JSONDecoder().decode(Root.self, from: data).feedItems
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
}
