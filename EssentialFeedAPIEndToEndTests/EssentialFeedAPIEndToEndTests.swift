//
//  EssentialFeedAPIEndToEndTests.swift
//  EssentialFeedAPIEndToEndTests
//
//  Created by Roland Schmitz on 03.03.23.
//

import EssentialFeed
import XCTest

final class EssentialFeedAPIEndToEndTests: XCTestCase {
    func test_endToEndTestServerGETFeedResult_matchesFixedTestAccountData() {
        switch getFeedResult() {
        case let .success(feedItems):
            XCTAssertEqual(feedItems.count, 8, "Expected 8 items in the test account feed")
//            feedItems.enumerated().forEach { (index, item) in
//                XCTAssertEqual(item, expectedItem(at: index))
                XCTAssertEqual(feedItems[0], expectedItem(at: 0))
                XCTAssertEqual(feedItems[1], expectedItem(at: 1))
                XCTAssertEqual(feedItems[2], expectedItem(at: 2))
                XCTAssertEqual(feedItems[3], expectedItem(at: 3))
                XCTAssertEqual(feedItems[4], expectedItem(at: 4))
                XCTAssertEqual(feedItems[5], expectedItem(at: 5))
                XCTAssertEqual(feedItems[6], expectedItem(at: 6))
                XCTAssertEqual(feedItems[7], expectedItem(at: 7))
//            }
        case .failure(let error):
            XCTFail("expected success, got \(error)")
        case nil:
            XCTFail("expected success, got nil")
        }
    }

    // HELPERS:

    private func getFeedResult(file: StaticString = #filePath, line: UInt = #line) -> LoadFeedResult? {
        let url = URL(string: "https://essentialdeveloper.com/feed-case-study/test-api/feed")!
        let client = URLSessionHTTPClient()
        let loader = RemoteFeedLoader(url: url, httpClient: client)
        trackForMemoryLeaks(client, file: file, line: line)
        trackForMemoryLeaks(loader)
        let exp = expectation(description: "wait for load completion")
        var receivedResult: LoadFeedResult?
        loader.load { result in
            receivedResult = result
            exp.fulfill()
        }
        wait(for: [exp], timeout: 20.0)
        return receivedResult
    }

    func expectedItem(at index: Int) -> FeedItem {
        FeedItem(id: id(at: index), description: description(at: index), location: location(at: index), imageURL: url(at: index))
    }

    func id(at index: Int) -> UUID {
        UUID(uuidString: [
            "73A7F70C-75DA-4C2E-B5A3-EED40DC53AA6",
            "BA298A85-6275-48D3-8315-9C8F7C1CD109",
            "5A0D45B3-8E26-4385-8C5D-213E160A5E3C",
            "FF0ECFE2-2879-403F-8DBE-A83B4010B340",
            "DC97EF5E-2CC9-4905-A8AD-3C351C311001",
            "557D87F1-25D3-4D77-82E9-364B2ED9CB30",
            "A83284EF-C2DF-415D-AB73-2A9B8B04950B",
            "F79BD7F8-063F-46E2-8147-A67635C3BB01",
        ][index])!
    }

    func description(at index: Int) -> String? {
        [
            "Description 1",
            nil,
            "Description 3",
            nil,
            "Description 5",
            "Description 6",
            "Description 7",
            "Description 8",
        ][index]
    }

    func location(at index: Int) -> String? {
        [
            "Location 1",
            "Location 2",
            nil,
            nil,
            "Location 5",
            "Location 6",
            "Location 7",
            "Location 8",
        ][index]
    }

    func url(at index: Int) -> URL {
        URL(string: "https://url-\(index+1).com")!
    }
}
