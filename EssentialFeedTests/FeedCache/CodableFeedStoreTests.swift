//
//  CodableFeedStoreTests.swift
//  EssentialFeedTests
//
//  Created by Roland Schmitz on 25.03.23.
//

import EssentialFeed
import XCTest


class CodableFeedStore {
    private struct Cache: Codable {
        let feed: [CodableFeedImage]
        let timestamp: Date

        var localFeed: [LocalFeedImage] {
            feed.map { $0.local }
        }
    }

    private struct CodableFeedImage: Equatable, Codable {
        private let id: UUID
        private let description: String?
        private let location: String?
        private let url: URL

        init(_ local: LocalFeedImage) {
            self.id = local.id
            self.description = local.description
            self.location = local.location
            self.url = local.url
        }

        var local: LocalFeedImage {
            LocalFeedImage(id: id, description: description, location: location, url: url)
        }
    }


    private let storeURL = FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask).first!.appendingPathComponent("image-feed.store")

    func retrieve(completion: @escaping FeedStore.RetrievalCompletion) {
        guard let data = try? Data(contentsOf: storeURL) else {
            completion(.empty)
            return
        }
        let cache = try! JSONDecoder().decode(Cache.self, from: data)
        completion(.found(feed: cache.localFeed, timestamp: cache.timestamp))
    }

    func insert(_ feed: [LocalFeedImage], timestamp: Date, completion: @escaping FeedStore.InsertionCompletion) {
        let encoder = JSONEncoder()
        let cache = Cache(feed: feed.map(CodableFeedImage.init), timestamp: timestamp)
        let encoded = try! encoder.encode(cache)
        try! encoded.write(to: storeURL)
        completion(nil)
    }

}

final class CodableFeedStoreTests: XCTestCase {
    override func setUpWithError() throws {
        let storeURL = FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask).first!.appendingPathComponent("image-feed.store")
        try? FileManager.default.removeItem(at: storeURL)
    }

    override func tearDownWithError() throws {
        let storeURL = FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask).first!.appendingPathComponent("image-feed.store")
        try? FileManager.default.removeItem(at: storeURL)
    }

    func test_retrieve_deliversEmptyOnEmptyCache() {
        let sut = CodableFeedStore()
        let exp = expectation(description: "wait for cache retrieval")
        sut.retrieve { result in
            switch result {
            case .empty:
                break
            default:
                XCTFail("expected empty result, got \(result) instead")
            }
            exp.fulfill()
        }
        wait(for: [exp], timeout: 2.0)
    }

    func test_retrieve_hasNoSideEffectsOnEmptyCache() {
        let sut = CodableFeedStore()
        let exp = expectation(description: "wait for cache retrieval")
        sut.retrieve { firstResult in
            sut.retrieve { secondResult in
                switch (firstResult, secondResult) {
                case (.empty, .empty):
                    break
                default:
                    XCTFail("expected empty result twice, got \(firstResult) and \(secondResult)")
                }
                exp.fulfill()
            }
        }
        wait(for: [exp], timeout: 2.0)
    }

    func test_retrieveAfterInsertingToEmptyCache_deliversInsertedValues() {
        let sut = CodableFeedStore()
        let feed = uniqueFeed().local
        let timestamp = Date.now
        let exp = expectation(description: "wait for cache retrieval")
        sut.insert(feed, timestamp: timestamp) { insertionError in
            XCTAssertNil(insertionError)
            sut.retrieve { retrieveResult in
                switch retrieveResult {
                case .found(let retrievedFeed, let retrievedTimestamp):
                    XCTAssertEqual(retrievedFeed, feed)
                    XCTAssertEqual(retrievedTimestamp, timestamp)
                default:
                    XCTFail("expected found result with feed \(feed) and timestamp \(timestamp), got \(retrieveResult) instead")
                }
                exp.fulfill()
            }
        }
        wait(for: [exp], timeout: 2.0)
    }
}
