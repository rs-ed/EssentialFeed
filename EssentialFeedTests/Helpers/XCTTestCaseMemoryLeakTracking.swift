//
//  XCTTestCaseMemoryLeakTracking.swift
//  EssentialFeedTests
//
//  Created by Roland Schmitz on 25.02.23.
//

import Foundation
import XCTest

extension XCTestCase {
    func trackForMemoryLeaks(
        _ instance: AnyObject,
        file: StaticString = #filePath,
        line: UInt = #line
    ) {
        addTeardownBlock { [weak instance] in
            XCTAssertNil(
                instance, "memory leak, instance should have been deallocated",
                file: file, line: line
            )
        }
    }
}
