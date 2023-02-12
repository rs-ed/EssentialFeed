//
//  RemoteFeedLoaderTests.swift
//  EssentialFeedTests
//
//  Created by Roland Schmitz on 12.02.23.
//

import XCTest

protocol HTTPClient {
    func get(url: URL)
}

class HTTPClientSpy: HTTPClient {
    var requestedURLs: [URL] = []

    func get(url: URL) {
        requestedURLs.append(url)
    }
}

final class RemoteFeedLoader {
    init(httpClient: HTTPClient) {
        self.httpClient = httpClient
    }

    private let httpClient: HTTPClient

    func load() {

        httpClient.get(url: URL(string: "https://example.com/")!)
    }

}

final class RemoteFeedLoaderTests: XCTestCase {
    func test_init_doesNotRequestDataFromHTTPClient() throws {
        let client = HTTPClientSpy()
        let sut = RemoteFeedLoader(httpClient: client)
        XCTAssertEqual(client.requestedURLs, [])
    }
}
