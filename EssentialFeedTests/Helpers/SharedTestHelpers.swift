//
//  SharedTestHelpers.swift
//  EssentialFeedTests
//
//  Created by Roland Schmitz on 22.03.23.
//

import Foundation

func anyURL() -> URL {
    URL(string: "http://a-url.com/")!
}

func anyNSError() -> NSError {
    NSError(domain: "any error", code: 0)
}
