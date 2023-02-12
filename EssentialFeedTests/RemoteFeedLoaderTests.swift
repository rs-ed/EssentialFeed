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
        expect(sut, toCompleteWith: .failure(.connectivity), when: {
            let clientError: Error = URLError(.networkConnectionLost)
            client.complete(with: clientError)
        })
    }

    func test_load_deliversErrorOnNon200StatusCodeResponse() throws {
        let (sut, client) = makeSUT()
        let statusCodes = [199, 201, 300, 400, 500]
        statusCodes.enumerated().forEach { index, statusCode in
            expect(sut, toCompleteWith: .failure(.invalidData), when: {
                client.complete(withStatusCode: statusCode, at: index)
            })
        }
    }

    func test_load_deliversErrorOn200ResponseWithInvalidJSON() throws {
        let (sut, client) = makeSUT()
        expect(sut, toCompleteWith: .failure(.invalidData), when: {
            let invalidJSON = Data("invalid JSON".utf8)
            client.complete(withStatusCode: 200, data: invalidJSON)
        })
    }

    func test_load_deliversNoItemsOn200ResponseWithEmptyJSONList() throws {
        let (sut, client) = makeSUT()
        expect(sut, toCompleteWith: .success([]), when: {
            let emptyItemsJSON = Data(#"{"items":[]}"#.utf8)
            client.complete(withStatusCode: 200, data: emptyItemsJSON)
        })
    }

    func test_load_deliversItemsOn200ResponseWithJSONItems() throws {
        let (sut, client) = makeSUT()
        let item1 = FeedItem(
            id: UUID(),
            description: nil,
            location: nil,
            imageURL: URL(string: "https://example.com/an-image.png")!
        )
        let item1JSON = [
            "id": item1.id.uuidString,
            "image": item1.imageURL.absoluteString,
        ]
        let item2 = FeedItem(
            id: UUID(),
            description: "some description",
            location: "some location",
            imageURL: URL(string: "https://example.com/another-image.png")!
        )
        let item2JSON = [
            "id": item2.id.uuidString,
            "description": item2.description!,
            "location": item2.location!,
            "image": item2.imageURL.absoluteString,
        ]
        let itemsJSON = ["items": [item1JSON, item2JSON]]
        let json = try! JSONSerialization.data(withJSONObject: itemsJSON)
        expect(sut, toCompleteWith: .success([item1, item2]), when: {
            client.complete(withStatusCode: 200, data: json)
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
        toCompleteWith result: RemoteFeedLoader.Result,
        when action: () -> Void,
        file: StaticString = #filePath,
        line: UInt = #line
    ) {
        var capturedResults: [RemoteFeedLoader.Result] = []
        sut.load { capturedResults.append($0) }
        action()
        XCTAssertEqual(capturedResults, [result], file: file, line: line)
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
