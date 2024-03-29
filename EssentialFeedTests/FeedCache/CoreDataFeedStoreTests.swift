    //
    //  CoreDataFeedStoreTests.swift
    //  EssentialFeedTests
    //
    //  Created by Roland Schmitz on 25.03.23.
    //

import EssentialFeed
import XCTest

final class CoreDataFeedStoreTests: XCTestCase, FeedStoreSpecs {
    override func setUpWithError() throws {
        setupEmptyStoreState()
    }

    override func tearDownWithError() throws {
        undoStoreSideEffects()
    }

    func test_retrieve_deliversEmptyOnEmptyCache() throws {
        let sut = try makeSUT()
        assertThatRetrieveDeliversEmptyOnEmptyCache(on: sut)
    }

    func test_retrieve_hasNoSideEffectsOnEmptyCache() throws {
        let sut = try makeSUT()
        assertThatRetrieveHasNoSideEffectsOnEmptyCache(on: sut)
    }

    func test_retrieve_deliversFoundValuesOnNonEmptyCache() throws {
        let sut = try makeSUT()
        assertThatRetrieveDeliversFoundValuesOnNonEmptyCache(on: sut)
    }

    func test_retrieve_hasNoSideEffectsOnNonEmptyCache() throws {
        let sut = try makeSUT()
        assertThatRetrieveHasNoSideEffectsOnNonEmptyCache(on: sut)
    }

    func test_insert_deliversNoErrorOnEmptyCache() throws {
        let sut = try makeSUT()
        assertThatInsertDeliversNoErrorOnEmptyCache(on: sut)
    }

    func test_insert_deliversNoErrorOnNonEmptyCache() throws {
        let sut = try makeSUT()
        assertThatInsertDeliversNoErrorOnNonEmptyCache(on: sut)
    }

    func test_insert_overridesPreviouslyInsertedCacheValues() throws {
        let sut = try makeSUT()
        assertThatInsertOverridesPreviouslyInsertedCacheValues(on: sut)
    }

    func test_delete_deliversNoErrorOnEmptyCache() throws {
        let sut = try makeSUT()
        assertThatDeleteDeliversNoErrorOnEmptyCache(on: sut)
    }

    func test_delete_hasNoSideEffectsOnEmptyCache() throws {
        let sut = try makeSUT()
        assertThatDeleteHasNoSideEffectsOnEmptyCache(on: sut)
    }

    func test_delete_deliversNoErrorOnNonEmptyCache() throws {
        let sut = try makeSUT()
        assertThatDeleteDeliversNoErrorOnNonEmptyCache(on: sut)
    }

    func test_delete_emptiesPreviouslyInsertedCache() throws {
        let sut = try makeSUT()
        assertThatDeleteEmptiesPreviouslyInsertedCache(on: sut)
    }

    func test_storeSideEffects_runSerially() throws {
        let sut = try makeSUT()
        assertThatStoreSideEffectsRunSerially(on: sut)
    }

        // - MARK: Helpers

    private func makeSUT(file: StaticString = #filePath, line: UInt = #line) throws -> FeedStore {
        let sut = try CoreDataFeedStore(storeURL: inMemoryStoreURL())
        trackForMemoryLeaks(sut, file: file, line: line)
        return sut
    }

    private func inMemoryStoreURL() -> URL {
        URL(fileURLWithPath: "/dev/null")
            .appendingPathComponent("\(type(of: self)).store")
    }

    private func setupEmptyStoreState() {
        deleteStoreArtifacts()
    }

    private func undoStoreSideEffects() {
        deleteStoreArtifacts()
    }

    private func deleteStoreArtifacts() {
    }
}
