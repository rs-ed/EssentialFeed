//
//  RemoteFeedLoaderTests.swift
//  EssentialFeedTests
//
//  Created by Roland Schmitz on 12.02.23.
//

import XCTest
import EssentialFeed

final class RemoteFeedLoaderTests: XCTestCase {
    func test_init_doesNotRequestData() throws {
        let (_, client) = makeSUT()
        XCTAssertEqual(client.requestedURLs, [])
    }

    func test_load_requestsDataFromURL() throws {
        let url = URL(string: "https://example.com/")!
        let (sut, client) = makeSUT(url: url)
        sut.load()
        XCTAssertEqual(client.requestedURLs, [url])
    }

    func test_loadTwice_requestsDataFromURLTwice() throws {
        let url = URL(string: "https://example.com/")!
        let (sut, client) = makeSUT(url: url)
        sut.load()
        sut.load()
        XCTAssertEqual(client.requestedURLs, [url, url])
    }

    func test_load_deliversErrorOnClientError() throws {
        let url = URL(string: "https://example.com/")!
        let (sut, client) = makeSUT(url: url)
        var capturedErrors: [RemoteFeedLoader.Error] = []
        sut.load { capturedErrors.append($0) }
        client.completions[0](URLError(.networkConnectionLost))
        XCTAssertEqual(capturedErrors, [.connectivity])
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
        var completions: [(Error) -> Void] = []

        func get(from url: URL, completion: @escaping (Error) -> Void) {
            requestedURLs.append(url)
            completions.append(completion)
        }
    }
}
