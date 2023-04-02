//
//  FeedStore.swift
//  EssentialFeed
//
//  Created by Roland Schmitz on 12.03.23.
//

import Foundation

public enum RetrieveCacheFeedResult {
    case empty
    case found(feed: [LocalFeedImage], timestamp: Date)
    case failure(Error)
}

public protocol FeedStore {
    typealias DeletionCompletion = (Error?) -> Void
    typealias InsertionCompletion = (Error?) -> Void
    typealias RetrievalCompletion = (RetrieveCacheFeedResult) -> Void

        /// The completion handler can be invoked in any thread.
        /// Clients are responsible to dispatch to appropriate threads,
    func deleteCachedFeed(completion: @escaping DeletionCompletion)

        /// The completion handler can be invoked in any thread.
        /// Clients are responsible to dispatch to appropriate threads,
    func insert(_ feed: [LocalFeedImage], timestamp: Date, completion: @escaping InsertionCompletion)

        /// The completion handler can be invoked in any thread.
        /// Clients are responsible to dispatch to appropriate threads,
    func retrieve(completion: @escaping RetrievalCompletion)
}
