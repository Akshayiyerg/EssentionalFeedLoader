//
//  LoadFeedFromCacheUseCaseTests.swift
//  EssentialFeedTests
//
//  Created by Akshay  on 2023-07-27.
//

import XCTest
import EssentialFeed

class LoadFeedFromCacheUseCaseTests: XCTestCase {
    
    func test_init_doesNotMessageStoreUponCreation() {
        
        let (_, store) = makeSut()
        
        XCTAssertEqual(store.receivedMessages, [])
    }

    // MARK: - Helpers
    
    private func makeSut(currentDate: @escaping () -> Date = Date.init, file: StaticString = #file, line: UInt = #line) -> (sut: LocalFeedLoader, store: FeedStoreSpy) {
        
        let store = FeedStoreSpy()
        let sut = LocalFeedLoader(store: store, currentDate: currentDate)
        
        trackMemoryLeaks(sut, file: file, line: line)
        trackMemoryLeaks(store, file: file, line: line)
        
        return (sut, store)
    }
    
    private class FeedStoreSpy: FeedStore {
        
        enum ReceivedMessage: Equatable {
            case deleteCachedFeed
            case Insert([LocalFeedImage], Date)
        }
        
        private(set) var receivedMessages = [ReceivedMessage]()
        
        private var deletionCompletion = [deletionCompletionTypealias]()
        private var insertionCompletion = [insertionCompletionTypealias]()
        
        func deleteCachedFeed(completion: @escaping deletionCompletionTypealias) {
            deletionCompletion.append(completion)
            receivedMessages.append(.deleteCachedFeed)
        }
        
        func completeDeletion(with error: NSError, at index: Int = 0) {
            deletionCompletion[index](error)
        }
        
        func completeDeletionSuccessfully(at index: Int = 0) {
            deletionCompletion[index](nil)
        }
        
        func insert(_ feed: [LocalFeedImage], timeStamp: Date, completion: @escaping insertionCompletionTypealias) {
            insertionCompletion.append(completion)
            receivedMessages.append(.Insert(feed, timeStamp))
        }
        
        func completeInsertion(with error: NSError, at index: Int = 0) {
            insertionCompletion[index](error)
        }
        
        func completeInsertionSuccesfully(at index: Int = 0) {
            insertionCompletion[index](nil)
        }
    }
    
}
