//
//  RemoteFeedItem.swift
//  EssentialFeed
//
//  Created by Roland Schmitz on 12.03.23.
//

import Foundation

struct RemoteFeedItem: Decodable, Equatable {
    let id: UUID
    let description: String?
    let location: String?
    let image: URL
}
