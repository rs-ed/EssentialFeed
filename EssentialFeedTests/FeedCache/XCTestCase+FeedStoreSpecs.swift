//
//  XCTestCase+FeedStoreSpecs.swift
//  EssentialFeedTests
//
//  Created by Roland Schmitz on 14.04.23.
//

import XCTest
import EssentialFeed

extension FeedStoreSpecs where Self: XCTestCase {
    func assertThatRetrieveDeliversEmptyOnEmptyCache(on sut: FeedStore, file: StaticString = #filePath, line: UInt = #line) {
        expect(sut, toRetrieve: .success(.none), file: file, line: line)
    }

    func assertThatRetrieveHasNoSideEffectsOnEmptyCache(on sut: FeedStore, file: StaticString = #filePath, line: UInt = #line) {
        expect(sut, toRetrieveTwice: .success(.none), file: file, line: line)
    }

    func assertThatRetrieveDeliversFoundValuesOnNonEmptyCache(on sut: FeedStore, file: StaticString = #filePath, line: UInt = #line) {

        let feed = uniqueFeed().local
        let timestamp = Date.now

        insert((feed, timestamp), to: sut)

        expect(sut, toRetrieve: .success(CachedFeed(feed: feed, timestamp: timestamp)))
    }

    func assertThatRetrieveHasNoSideEffectsOnNonEmptyCache(on sut: FeedStore, file: StaticString = #filePath, line: UInt = #line) {
        let feed = uniqueFeed().local
        let timestamp = Date.now

        insert((feed, timestamp), to: sut)

        expect(sut, toRetrieveTwice: .success(CachedFeed(feed: feed, timestamp: timestamp)))
    }

    func assertThatRetrieveDeliversFailureOnRetrievalError(on sut: FeedStore, file: StaticString = #filePath, line: UInt = #line) {
        expect(sut, toRetrieve: .failure(anyNSError()))
    }

    func assertThatRetrieveHasNoSideEffectsOnFailure(on sut: FeedStore, file: StaticString = #filePath, line: UInt = #line) {
        expect(sut, toRetrieveTwice: .failure(anyNSError()))
    }

    func assertThatInsertDeliversNoErrorOnEmptyCache(on sut: FeedStore, file: StaticString = #filePath, line: UInt = #line) {
        let firstInsertionError = insert((uniqueFeed().local, Date.now), to: sut)
        XCTAssertNil(firstInsertionError)
    }

    func assertThatInsertDeliversNoErrorOnNonEmptyCache(on sut: FeedStore, file: StaticString = #filePath, line: UInt = #line) {
        insert((uniqueFeed().local, Date.now), to: sut)

        let latestFeed = uniqueFeed().local
        let latestTimestamp = Date.now

        let latestInsertionError = insert((latestFeed, latestTimestamp), to: sut)
        XCTAssertNil(latestInsertionError)
    }

    func assertThatInsertOverridesPreviouslyInsertedCacheValues(on sut: FeedStore, file: StaticString = #filePath, line: UInt = #line) {
        insert((uniqueFeed().local, Date.now), to: sut)

        let latestFeed = uniqueFeed().local
        let latestTimestamp = Date.now

        insert((latestFeed, latestTimestamp), to: sut)

        expect(sut, toRetrieveTwice: .success(CachedFeed(feed: latestFeed, timestamp: latestTimestamp)))
    }

    func assertThatInsertDeliversErrorOnInsertionError(on sut: FeedStore, file: StaticString = #filePath, line: UInt = #line) {
        let insertionError = insert((uniqueFeed().local, Date.now), to: sut)

        XCTAssertNotNil(insertionError, "Expected cache insertion to fail with an error")
    }

    func assertThatInsertHasNoSideEffectsOnInsertionError(on sut: FeedStore, file: StaticString = #filePath, line: UInt = #line) {
        insert((uniqueFeed().local, Date.now), to: sut)

        expect(sut, toRetrieve: .success(.none))
    }

    func assertThatDeleteDeliversNoErrorOnEmptyCache(on sut: FeedStore, file: StaticString = #filePath, line: UInt = #line) {
        let deletionError = deleteCache(from: sut)
        XCTAssertNil(deletionError, "Expected empty cache deletion to succeed")
    }

    func assertThatDeleteHasNoSideEffectsOnEmptyCache(on sut: FeedStore, file: StaticString = #filePath, line: UInt = #line) {
        deleteCache(from: sut)

        expect(sut, toRetrieve: .success(.none))
    }

    func assertThatDeleteDeliversNoErrorOnNonEmptyCache(on sut: FeedStore, file: StaticString = #filePath, line: UInt = #line) {
        insert((uniqueFeed().local, Date.now), to: sut)

        let deletionError = deleteCache(from: sut)
        XCTAssertNil(deletionError, "Expected non empty cache deletion to succeed")
    }

    func assertThatDeleteEmptiesPreviouslyInsertedCache(on sut: FeedStore, file: StaticString = #filePath, line: UInt = #line) {
        insert((uniqueFeed().local, Date.now), to: sut)

        deleteCache(from: sut)

        expect(sut, toRetrieve: .success(.none))
    }

    func assertThatDeleteDeliversErrorOnDeletionError(on sut: FeedStore, file: StaticString = #filePath, line: UInt = #line) {
        let deletionError = deleteCache(from: sut)
        XCTAssertNotNil(deletionError, "Expected cache deletion to fail")
    }

    func assertThatDeleteHasNoSideEffectsOnDeletionError(on sut: FeedStore, file: StaticString = #filePath, line: UInt = #line) {
        deleteCache(from: sut)
        expect(sut, toRetrieve: .success(.none))
    }

    func assertThatStoreSideEffectsRunSerially(on sut: FeedStore, file: StaticString = #filePath, line: UInt = #line) {
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

    @discardableResult
    func insert(
        _ cache: (feed: [LocalFeedImage], timestamp: Date),
        to sut: FeedStore
    ) -> Error? {
        let exp = expectation(description: "Wait for cache insertion")
        var insertionError: Error?
        sut.insert(cache.feed, timestamp: cache.timestamp) { receivedInsertionResult in
            if case .failure(let error) = receivedInsertionResult {
                insertionError = error
            }
            exp.fulfill()
        }
        wait(for: [exp], timeout: 2.0)
        return insertionError
    }

    @discardableResult
    func deleteCache(from sut: FeedStore) -> Error? {
        let exp = expectation(description: "Wait for cache deletion")
        var deletionError: Error?
        sut.deleteCachedFeed { receivedDeletionResult in
            if case .failure(let error) = receivedDeletionResult {
                deletionError = error
            }
            exp.fulfill()
        }
        wait(for: [exp], timeout: 6.0)
        return deletionError
    }

    func expect(
        _ sut: FeedStore,
        toRetrieve expectedResult: FeedStore.RetrievalResult,
        file: StaticString = #filePath,
        line: UInt = #line
    ) {
        let expectation = expectation(description: "Wait for retrieve result")
        sut.retrieve { receivedResult in
            switch (receivedResult, expectedResult) {
            case(.success(.none), .success(.none)), (.failure, .failure):
                break
            case let (.success(.some(received)), .success(.some(expected))):
                XCTAssertEqual(received.feed, expected.feed, file: file, line: line)
                XCTAssertEqual(received.timestamp, expected.timestamp, file: file, line: line)
            default:
                XCTFail(
                    "expected to retrieve \(expectedResult), got \(receivedResult) instead",
                    file: file,
                    line: line
                )
            }
            expectation.fulfill()
        }
        wait(for: [expectation], timeout: 2.0)
    }

    func expect(
        _ sut: FeedStore,
        toRetrieveTwice expectedResult: FeedStore.RetrievalResult,
        file: StaticString = #filePath,
        line: UInt = #line
    ) {
        expect(sut, toRetrieve: expectedResult)
        expect(sut, toRetrieve: expectedResult)
    }
}
