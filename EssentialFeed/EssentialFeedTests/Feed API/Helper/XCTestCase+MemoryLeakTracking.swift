//
//  XCTestCase+MemoryLeakTracking.swift
//  EssentialFeedTests
//
//  Created by Akshay  on 2023-06-24.
//

import XCTest

extension XCTestCase {
    
    func trackMemoryLeaks( _ instance: AnyObject, file: StaticString = #file, line: UInt = #line) {
        addTeardownBlock { [weak instance] in
            XCTAssertNil(instance, "Potential memeory leak", file: file, line: line)
        }
    }
}
