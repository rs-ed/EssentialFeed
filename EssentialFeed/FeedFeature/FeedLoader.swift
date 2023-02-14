//
//  FeedLoader.swift
//  EssentialFeed
//
//  Created by Roland Schmitz on 12.02.23.
//

import Foundation

public enum LoadFeedResult {
    case success([FeedItem])
    case failure(Error)
}

protocol FeedLoader {
    func load(completion: @escaping (LoadFeedResult) -> Void)
}
