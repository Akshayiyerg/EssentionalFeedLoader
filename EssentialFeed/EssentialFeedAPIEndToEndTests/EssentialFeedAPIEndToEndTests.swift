//
//  EssentialFeedAPIEndToEndTests.swift
//  EssentialFeedAPIEndToEndTests
//
//  Created by Akshay  on 2023-06-24.
//

import XCTest
import EssentialFeed

final class MyFeedLoaderAPIEndToEndTests: XCTestCase {

    func test_endToEndTestServerGetFeedResult_matchingFixedTestAccountData() {
        
        let testServerURL = URL(string: "https://essentialdeveloper.com/feed-case-study/test-api/feed")!
        let client = URLSessionHTTPClient()
        let loader = RemoteFeedLoader(client: client, url: testServerURL)
        
        let exp = expectation(description: "wait for the load completion")
        var receivedResult: LoadFeedResult?
        loader.load { result in
            receivedResult = result
            exp.fulfill()
        }
        wait(for: [exp], timeout: 10.0)
        
        switch receivedResult {
        case let .success(items):
            XCTAssertEqual(items.count, 8, "Expected 8 items in the test account feed.")
            
        case let .failure(error):
            XCTFail("Expected Succesful feed, but got \(error) error instead.")
            
        default:
            XCTFail("Expected Succedd, got failure.")
        }
    }
    
}
