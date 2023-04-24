//
//  FeedItemsMapper.swift
//  EssentialFeed
//
//  Created by Roland Schmitz on 13.02.23.
//

import Foundation

final class FeedItemsMapper {
    static func map(_ data: Data, from response: HTTPURLResponse) throws -> [RemoteFeedItem] {
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
