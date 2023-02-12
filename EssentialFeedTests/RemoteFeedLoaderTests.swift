//
//  RemoteFeedLoaderTests.swift
//  EssentialFeedTests
//
//  Created by Roland Schmitz on 12.02.23.
//

import XCTest
import EssentialFeed

final class RemoteFeedLoaderTests: XCTestCase {
    func test_init_doesNotRequestDataFromHTTPClient() throws {
        let (_, client) = makeSUT()
        XCTAssertEqual(client.requestedURLs, [])
    }

    func test_load_doesRequestDataFromHTTPClient() throws {
        let url = URL(string: "https://example.com/")!
        let (sut, client) = makeSUT(url: url)
        sut.load()
        XCTAssertEqual(client.requestedURLs, [url])
    }

    // MARK: - Helpers

    func makeSUT(url: URL = URL(string: "https://example.com/")!)
    -> ( sut: RemoteFeedLoader, client: HTTPClientSpy) {
        let url = URL(string: "https://example.com/")!
        let client = HTTPClientSpy()
        let sut = RemoteFeedLoader(url: url, httpClient: client)
        return (sut, client)
    }

    class HTTPClientSpy: HTTPClient {
        var requestedURLs: [URL] = []

        func get(from url: URL) {
            requestedURLs.append(url)
        }
    }
}
