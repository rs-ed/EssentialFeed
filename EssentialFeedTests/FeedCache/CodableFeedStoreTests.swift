//
//  CodableFeedStoreTests.swift
//  EssentialFeedTests
//
//  Created by Roland Schmitz on 25.03.23.
//

import EssentialFeed
import XCTest

final class CodableFeedStoreTests: XCTestCase, FailableFeedStoreSpecs {
    override func setUpWithError() throws {
        setupEmptyStoreState()
    }

    override func tearDownWithError() throws {
        undoStoreSideEffects()
    }

    func test_retrieve_deliversEmptyOnEmptyCache() {
        let sut = makeSUT()
        expect(sut, toRetrieve: .empty)
    }

    func test_retrieve_hasNoSideEffectsOnEmptyCache() {
        let sut = makeSUT()
        expect(sut, toRetrieveTwice: .empty)
    }

    func test_retrieve_deliversFoundValuesOnNonEmptyCache() {
        let sut = makeSUT()
        let feed = uniqueFeed().local
        let timestamp = Date.now

        insert((feed, timestamp), to: sut)

        expect(sut, toRetrieve: .found(feed: feed, timestamp: timestamp))
    }

    func test_retrieve_hasNoSideEffectsOnNonEmptyCache() {
        let sut = makeSUT()
        let feed = uniqueFeed().local
        let timestamp = Date.now

        insert((feed, timestamp), to: sut)

        expect(sut, toRetrieveTwice: .found(feed: feed, timestamp: timestamp))
    }

    func test_retrieve_deliversFailureOnRetrievalError() {
        let storeURL: URL = testSpecificStoreURL()
        let sut = makeSUT(storeURL: storeURL)

        try? "invalid data".write(to: storeURL, atomically: false, encoding: .utf8)

        expect(sut, toRetrieve: .failure(anyNSError()))
    }

    func test_retrieve_hasNoSideEffectsOnFailure() {
        let storeURL: URL = testSpecificStoreURL()
        let sut = makeSUT(storeURL: storeURL)

        try? "invalid data".write(to: storeURL, atomically: false, encoding: .utf8)

        expect(sut, toRetrieveTwice: .failure(anyNSError()))
    }

    func test_insert_deliversNoErrorOnEmptyCache() {
        let sut = makeSUT()

        let firstInsertionError = insert((uniqueFeed().local, Date.now), to: sut)
        XCTAssertNil(firstInsertionError)
    }

    func test_insert_deliversNoErrorOnNonEmptyCache() {
        let sut = makeSUT()

        insert((uniqueFeed().local, Date.now), to: sut)

        let latestFeed = uniqueFeed().local
        let latestTimestamp = Date.now

        let latestInsertionError = insert((latestFeed, latestTimestamp), to: sut)
        XCTAssertNil(latestInsertionError)
    }

    func test_insert_overridesPreviouslyInsertedCacheValues() {
        let sut = makeSUT()

        insert((uniqueFeed().local, Date.now), to: sut)

        let latestFeed = uniqueFeed().local
        let latestTimestamp = Date.now

        insert((latestFeed, latestTimestamp), to: sut)

        expect(sut, toRetrieveTwice: .found(feed: latestFeed, timestamp: latestTimestamp))
    }

    func test_insert_deliversErrorOnInsertionError() {
        let invalidStoreURL = URL(string: "invalid://store.url")
        let sut = makeSUT(storeURL: invalidStoreURL)

        let insertionError = insert((uniqueFeed().local, Date.now), to: sut)

        XCTAssertNotNil(insertionError, "Expected cache insertion to fail with an error")
    }

    func test_insert_hasNoSideEffectsOnInsertionError() {
        let invalidStoreURL = URL(string: "invalid://store.url")
        let sut = makeSUT(storeURL: invalidStoreURL)

        insert((uniqueFeed().local, Date.now), to: sut)

        expect(sut, toRetrieve: .empty)
    }

    func test_delete_deliversNoErrorOnEmptyCache() {
        let sut = makeSUT()

        let deletionError = deleteCache(from: sut)
        XCTAssertNil(deletionError, "Expected empty cache deletion to succeed")
    }

    func test_delete_hasNoSideEffectsOnEmptyCache() {
        let sut = makeSUT()

        deleteCache(from: sut)

        expect(sut, toRetrieve: .empty)
    }

    func test_delete_deliversNoErrorOnNonEmptyCache() {
        let sut = makeSUT()

        insert((uniqueFeed().local, Date.now), to: sut)

        let deletionError = deleteCache(from: sut)
        XCTAssertNil(deletionError, "Expected non empty cache deletion to succeed")
    }

    func test_delete_emptiesPreviouslyInsertedCache() {
        let sut = makeSUT()

        insert((uniqueFeed().local, Date.now), to: sut)

        deleteCache(from: sut)

        expect(sut, toRetrieve: .empty)
    }

    func test_delete_deliversErrorOnDeletionError() {
        let nonDeletableStoreURL = cachesDirectory()
        let sut = makeSUT(storeURL: nonDeletableStoreURL)

        let deletionError = deleteCache(from: sut)
        XCTAssertNotNil(deletionError, "Expected cache deletion to fail")
    }

    func test_delete_hasNoSideEffectsOnDeletionError() {
        let nonDeletableStoreURL = cachesDirectory()
        let sut = makeSUT(storeURL: nonDeletableStoreURL)

        deleteCache(from: sut)
        expect(sut, toRetrieve: .empty)
    }

    func test_storeSideEffects_runSerially() {
        let sut = makeSUT()
        var completedOperationsInOrder: [XCTestExpectation] = []

        let op1 = expectation(description: "Opertion 1")
        sut.insert(uniqueFeed().local, timestamp: Date.now) { _ in
            completedOperationsInOrder.append(op1)
            op1.fulfill()
        }

        let op2 = expectation(description: "Opertion 2")
        sut.deleteCachedFeed { _ in
            completedOperationsInOrder.append(op2)
            op2.fulfill()
        }

        let op3 = expectation(description: "Opertion 3")
        sut.insert(uniqueFeed().local, timestamp: Date.now) { _ in
            completedOperationsInOrder.append(op3)
            op3.fulfill()
        }

        waitForExpectations(timeout: 5)

        XCTAssertEqual(completedOperationsInOrder, [op1, op2, op3])
    }

    // - MARK: Helpers

    private func makeSUT(
        storeURL: URL? = nil,
        file: StaticString = #filePath,
        line: UInt = #line
    ) -> FeedStore {
        let sut = CodableFeedStore(storeURL: storeURL ?? testSpecificStoreURL())
        trackForMemoryLeaks(sut, file: file, line: line)
        return sut
        
    }

    private func setupEmptyStoreState() {
        deleteStoreArtifacts()
    }

    private func undoStoreSideEffects() {
        deleteStoreArtifacts()
    }

    private func deleteStoreArtifacts() {
        try? FileManager.default.removeItem(at: testSpecificStoreURL())
    }

    private func testSpecificStoreURL() -> URL {
        cachesDirectory()
            .appendingPathComponent("\(type(of: self)).store")
    }

    private func cachesDirectory() -> URL {
        FileManager.default
            .urls(for: .cachesDirectory, in: .userDomainMask)
            .first!
    }
}
