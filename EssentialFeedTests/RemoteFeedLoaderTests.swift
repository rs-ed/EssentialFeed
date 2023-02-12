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
        let (sut, client) = makeSUT()
        expect(sut, toCompleteWithError: .connectivity, when: {
            let clientError: Error = URLError(.networkConnectionLost)
            client.complete(with: clientError)
        })
    }

    func test_load_deliversErrorOnNon200StatusCodeResponse() throws {
        let (sut, client) = makeSUT()
        let statusCodes = [199, 201, 300, 400, 500]
        statusCodes.enumerated().forEach { index, statusCode in
            expect(sut, toCompleteWithError: .invalidData, when: {
                client.complete(withStatusCode: statusCode, at: index)
            })
        }
    }

    func test_load_deliversErrorOn200ResponseWithInvalidJSON() throws {
        let (sut, client) = makeSUT()
        expect(sut, toCompleteWithError: .invalidData, when: {
            let invalidJSON = Data("invalid JSON".utf8)
            client.complete(withStatusCode: 200, data: invalidJSON)
        })
    }

    // MARK: - Helpers

    func makeSUT(url: URL = URL(string: "https://example.com/")!)
    -> ( sut: RemoteFeedLoader, client: HTTPClientSpy) {
        let url = URL(string: "https://example.com/")!
        let client = HTTPClientSpy()
        let sut = RemoteFeedLoader(url: url, httpClient: client)
        return (sut, client)
    }

    func expect(
        _ sut: RemoteFeedLoader,
        toCompleteWithError error: RemoteFeedLoader.Error,
        when action: () -> Void,
        file: StaticString = #filePath,
        line: UInt = #line
    ) {
        var capturedResults: [RemoteFeedLoader.Result] = []
        sut.load { capturedResults.append($0) }
        action()
        XCTAssertEqual(capturedResults, [.failure(error)], file: file, line: line)
    }

    class HTTPClientSpy: HTTPClient {
        private var messages: [(url: URL, completion: (HTTPClientResult) -> Void)] = []

        var requestedURLs: [URL] { messages.map(\.url) }

        func get(from url: URL, completion: @escaping (HTTPClientResult) -> Void) {
            messages.append((url, completion))
        }

        func complete(with error: Error, at index: Int = 0) {
            messages[index].completion(.failure(error))
        }

        func complete(withStatusCode status: Int, data: Data = Data(), at index: Int = 0) {
            let response = HTTPURLResponse(url: requestedURLs[index], statusCode: status, httpVersion: nil, headerFields: nil)!
                messages[index].completion(.success(data, response))
        }
    }
}
