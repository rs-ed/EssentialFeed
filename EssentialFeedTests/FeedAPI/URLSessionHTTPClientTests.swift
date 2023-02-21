//
//  URLSessionHTTPClientTests.swift
//  EssentialFeedTests
//
//  Created by Roland Schmitz on 21.02.23.
//

import EssentialFeed
import XCTest

class URLSessionHTTPClient {
    private let session: URLSession

    init(session: URLSession) {
        self.session = session
    }

    func get(from url: URL, completion: @escaping (HTTPClientResult) -> Void) {
        session.dataTask(with: url) { _, _, error in
            if let error {
                completion(.failure(error))
            }
        }.resume()
    }
}

final class URLSessionHTTPClientTests: XCTestCase {

    func test_getFromURL_resumesDataTaskWithURL() throws {
        let url = URL(string: "http://a-url.com/")!
        let session = URLSessionSpy()
        let task = URLSessionDataTaskSpy()
        session.stub(url: url, task: task)
        let sut = URLSessionHTTPClient(session: session)
        sut.get(from: url) {_ in}
        XCTAssertEqual(task.resumeCallCount, 1)
    }

    func test_getFromURL_failsOnRequestError() throws {
        let url = URL(string: "http://a-url.com/")!
        let session = URLSessionSpy()
        let task = URLSessionDataTaskSpy()
        let error = NSError(domain: "any error", code: 1)
        session.stub(url: url, error: error)
        let sut = URLSessionHTTPClient(session: session)
        let expectation = expectation(description: "Wait for completion")
        sut.get(from: url) { result in
            switch result {
            case .failure(let receivedError as NSError):
                XCTAssertEqual(receivedError, error)
            case .success:
                XCTFail("Expected error")
            }
            expectation.fulfill()
        }
        wait(for: [expectation], timeout: 2.0)
    }

    // MARK: - Helpers

    private class URLSessionSpy: URLSession {
        struct Stub {
            let task: URLSessionDataTask
            let error: Error?
        }

        var stubs: [URL: Stub] = [:]

        override func dataTask(with url: URL, completionHandler: @escaping (Data?, URLResponse?, Error?) -> Void) -> URLSessionDataTask {
            guard let stub = stubs[url] else {
                fatalError("no stub for url \(url)")
            }
            completionHandler(nil, nil, stub.error)
            return stub.task
        }

        func stub(url: URL, task: URLSessionDataTask = FakeURLSessionDataTask(), error: Error? = nil) {
            stubs[url] = Stub(task: task, error: error)
        }
    }

    private class FakeURLSessionDataTask: URLSessionDataTask {
        override func resume() {}
    }

    private class URLSessionDataTaskSpy: URLSessionDataTask {
        var resumeCallCount = 0

        override func resume() {
            resumeCallCount += 1
        }
    }
}
