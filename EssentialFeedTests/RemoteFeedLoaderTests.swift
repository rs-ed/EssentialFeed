//
//  RemoteFeedLoaderTests.swift
//  EssentialFeedTests
//
//  Created by Roland Schmitz on 12.02.23.
//

import XCTest

protocol HTTPClient {
    func get(from url: URL)
}

class HTTPClientSpy: HTTPClient {
    var requestedURLs: [URL] = []

    func get(from url: URL) {
        requestedURLs.append(url)
    }
}

final class RemoteFeedLoader {
    init(url: URL, httpClient: HTTPClient) {
        self.url = url
        self.httpClient = httpClient
    }

    private let url: URL
    private let httpClient: HTTPClient

    func load() {
        httpClient.get(from: url)
    }

}

final class RemoteFeedLoaderTests: XCTestCase {
    func test_init_doesNotRequestDataFromHTTPClient() throws {
        let url = URL(string: "https://example.com/")!
        let client = HTTPClientSpy()
        _ = RemoteFeedLoader(url: url, httpClient: client)
        XCTAssertEqual(client.requestedURLs, [])
    }

    func test_load_doesRequestDataFromHTTPClient() throws {
        let url = URL(string: "https://example.com/")!
        let client = HTTPClientSpy()
        let sut = RemoteFeedLoader(url: url, httpClient: client)
        sut.load()
        XCTAssertEqual(client.requestedURLs, [url])
    }
}
