//
//  XCTestCase+MemoryLeakTracking.swift
//  news-iosTests
//
//  Created by Mohamed Ibrahim on 17/09/2024.
//

import XCTest

extension XCTestCase {
    
    func trackForMemoryLeaks(
        _ instance: AnyObject,
        file: StaticString = #filePath,
        line: UInt = #line
    ) {
        addTeardownBlock { [weak instance] in
            XCTAssertNil(instance,"instance should have been deallocated. Potential memory leak.",file: file,line: line)
        }
    }
}
