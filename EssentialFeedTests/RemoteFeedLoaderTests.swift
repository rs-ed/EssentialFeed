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
        sut.load { _ in }
        XCTAssertEqual(client.requestedURLs, [url])
    }

    func test_loadTwice_requestsDataFromURLTwice() throws {
        let url = URL(string: "https://example.com/")!
        let (sut, client) = makeSUT(url: url)
        sut.load { _ in }
        sut.load { _ in }
        XCTAssertEqual(client.requestedURLs, [url, url])
    }

    func test_load_deliversErrorOnClientError() throws {
        let url = URL(string: "https://example.com/")!
        let (sut, client) = makeSUT(url: url)
        var capturedErrors: [RemoteFeedLoader.Error] = []
        sut.load { capturedErrors.append($0) }
        let clientError: Error = URLError(.networkConnectionLost)
        client.complete(with: clientError)
        XCTAssertEqual(capturedErrors, [.connectivity])
    }

    func test_load_deliversErrorOnNon200StatusCodeResponse() throws {
        let url = URL(string: "https://example.com/")!
        let (sut, client) = makeSUT(url: url)
        var capturedErrors: [RemoteFeedLoader.Error] = []
        sut.load { capturedErrors.append($0) }
        client.complete(withStatusCode: 400)
        XCTAssertEqual(capturedErrors, [.invalidData])
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
        private var messages: [(url: URL, completion: (Error?, HTTPURLResponse?) -> Void)] = []

        var requestedURLs: [URL] { messages.map(\.url) }

        func get(from url: URL, completion: @escaping (Error?, HTTPURLResponse?) -> Void) {
            messages.append((url, completion))
        }

        func complete(with error: Error, at index: Int = 0) {
            messages[index].completion(error, nil)
        }

        func complete(withStatusCode status: Int, at index: Int = 0) {
            let response = HTTPURLResponse(url: requestedURLs[index], statusCode: status, httpVersion: nil, headerFields: nil)
            messages[index].completion(nil, response)
        }
    }
}
