//
//  CodableFeedStoreTests.swift
//  EssentialFeedTests
//
//  Created by Akshay  on 2023-08-03.
//

import XCTest
import EssentialFeed

class CodableFeedStore {
    
    func retrieve(completion: @escaping FeedStore.RetrievalCompletionTypealias) {
        completion(.empty)
    }
    
}

final class CodableFeedStoreTests: XCTestCase {

    func test_retrieve_deliversEmptyOnEmptyCache() {
        
        let sut = CodableFeedStore()
        let exp = expectation(description: "Wait for the cache retrival")
        
        sut.retrieve { result in
            switch result {
            case .empty:
                break
                
            default:
                XCTFail("Expected empty, got \(result) instead")
            }
            exp.fulfill()
        }
        wait(for: [exp], timeout: 1.0)
    }
}
