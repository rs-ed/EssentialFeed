//
//  CacheFeedUseCaseTests.swift
//  EssentialFeedTests
//
//  Created by Roland Schmitz on 11.03.23.
//

import XCTest

class FeedStore {
    var deleteCachedFeedCallCount = 0
}

class LocalFeedLoader {
    init(store: FeedStore) {

    }

}

final class CacheFeedUseCaseTests: XCTestCase {

    func test_initDoesNotDeleteCacheUponCreation() throws {
        let store = FeedStore()
        _ = LocalFeedLoader(store: store)
        XCTAssertEqual(store.deleteCachedFeedCallCount, 0)

    }
}
