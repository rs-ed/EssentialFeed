//
//  URLSessionHTTPClientTests.swift
//  EssentialFeedTests
//
//  Created by Roland Schmitz on 21.02.23.
//

import XCTest

class URLSessionHTTPClient {
    private let session: URLSession

    init(session: URLSession) {
        self.session = session
    }

    func get(from url: URL) {
        session.dataTask(with: url) { _, _, _ in }.resume()
    }
}

final class URLSessionHTTPClientTests: XCTestCase {

    func test_getFromURL_createsDataTaskWithURL() throws {
        let url = URL(string: "http://a-url.com/")!
        let session = URLSessionSpy()
        let sut = URLSessionHTTPClient(session: session)
        sut.get(from: url)
        XCTAssertEqual(session.receivedURLs, [url])
    }

    func test_getFromURL_resumesDataTaskWithURL() throws {
        let url = URL(string: "http://a-url.com/")!
        let session = URLSessionSpy()
        let task = URLSessionDataTaskSpy()
        session.stub(url: url, with: task)
        let sut = URLSessionHTTPClient(session: session)
        sut.get(from: url)
        XCTAssertEqual(task.resumeCallCount, 1)
    }

    // MARK: - Helpers

    private class URLSessionSpy: URLSession {
        var receivedURLs: [URL] = []
        var stubs: [URL: URLSessionDataTask] = [:]

        override func dataTask(with url: URL, completionHandler: @escaping (Data?, URLResponse?, Error?) -> Void) -> URLSessionDataTask {
            receivedURLs.append(url)
            return stubs[url] ?? FakeURLSessionDataTask()
        }

        func stub(url: URL, with task: URLSessionDataTask) {
            stubs[url] = task
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
