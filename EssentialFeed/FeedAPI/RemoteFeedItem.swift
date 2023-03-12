//
//  RemoteFeedItem.swift
//  EssentialFeed
//
//  Created by Roland Schmitz on 12.03.23.
//

import Foundation

internal struct RemoteFeedItem: Decodable, Equatable {
    internal let id: UUID
    internal let description: String?
    internal let location: String?
    internal let image: URL
}
