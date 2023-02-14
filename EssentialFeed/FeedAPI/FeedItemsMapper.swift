//
//  FeedItemsMapper.swift
//  EssentialFeed
//
//  Created by Roland Schmitz on 13.02.23.
//

import Foundation

internal final class FeedItemsMapper {
    internal static func map(_ data: Data, from response: HTTPURLResponse) -> RemoteFeedLoader.Result {
        guard response.statusCode == ok_200,
              let root = try? JSONDecoder().decode(Root.self, from: data) else {
            return .failure(RemoteFeedLoader.Error.invalidData)
        }
        return .success(root.feedItems)
    }

    private static var ok_200: Int { 200 }

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
