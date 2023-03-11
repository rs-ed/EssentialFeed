//
//  CacheFeedUseCaseTests.swift
//  EssentialFeedTests
//
//  Created by Roland Schmitz on 11.03.23.
//

import EssentialFeed
import XCTest

class LocalFeedLoader {
    init(store: FeedStore) {
        self.store = store
    }

    private let store: FeedStore

    func save(_ items: [FeedItem]) {
        store.deleteCachedFeed()
    }

}

class FeedStore {
    var deleteCachedFeedCallCount = 0

    func deleteCachedFeed() {
        deleteCachedFeedCallCount += 1
    }
}

final class CacheFeedUseCaseTests: XCTestCase {

    func test_init_doesNotDeleteCacheUponCreation() throws {
        let store = FeedStore()
        _ = LocalFeedLoader(store: store)
        XCTAssertEqual(store.deleteCachedFeedCallCount, 0)

    }

    func test_save_requestCacheDeletion() throws {
        let store = FeedStore()
        let sut = LocalFeedLoader(store: store)
        let items = [uniqueItem(), uniqueItem()]
        sut.save(items)
        XCTAssertEqual(store.deleteCachedFeedCallCount, 1)

    }

    private func uniqueItem() -> FeedItem {
        FeedItem(id: UUID(), description: "any", location: "any", imageURL: anyURL())
    }

    private func anyURL() -> URL {
        URL(string: "http://a-url.com/")!
    }
}
