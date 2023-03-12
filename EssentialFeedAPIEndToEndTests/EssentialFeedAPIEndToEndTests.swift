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
        case let .success(imageFeed):
            XCTAssertEqual(imageFeed.count, 8, "Expected 8 images in the test account image feed")
                XCTAssertEqual(imageFeed[0], expectedImage(at: 0))
                XCTAssertEqual(imageFeed[1], expectedImage(at: 1))
                XCTAssertEqual(imageFeed[2], expectedImage(at: 2))
                XCTAssertEqual(imageFeed[3], expectedImage(at: 3))
                XCTAssertEqual(imageFeed[4], expectedImage(at: 4))
                XCTAssertEqual(imageFeed[5], expectedImage(at: 5))
                XCTAssertEqual(imageFeed[6], expectedImage(at: 6))
                XCTAssertEqual(imageFeed[7], expectedImage(at: 7))
        case .failure(let error):
            XCTFail("expected success, got \(error)")
        case nil:
            XCTFail("expected success, got nil")
        }
    }

    // HELPERS:

    private func getFeedResult(file: StaticString = #filePath, line: UInt = #line) -> LoadFeedResult? {

        let url = URL(string: "https://essentialdeveloper.com/feed-case-study/test-api/feed")!
        let client = URLSessionHTTPClient(session: URLSession(configuration: .ephemeral))
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

    func expectedImage(at index: Int) -> FeedImage {
        FeedImage(id: id(at: index), description: description(at: index), location: location(at: index), url: url(at: index))
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
