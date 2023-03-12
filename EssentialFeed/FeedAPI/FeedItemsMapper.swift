//
//  FeedItemsMapper.swift
//  EssentialFeed
//
//  Created by Roland Schmitz on 13.02.23.
//

import Foundation

internal struct RemoteFeedItem: Decodable, Equatable {
    internal let id: UUID
    internal let description: String?
    internal let location: String?
    internal let image: URL
}

internal final class FeedItemsMapper {
    internal static func map(_ data: Data, from response: HTTPURLResponse) throws -> [RemoteFeedItem] {
        guard response.statusCode == ok_200,
              let root = try? JSONDecoder().decode(Root.self, from: data) else {
            throw RemoteFeedLoader.Error.invalidData
        }
        return root.items
    }

    private static var ok_200: Int { 200 }

    private struct Root: Decodable {
        let items: [RemoteFeedItem]
    }
}
