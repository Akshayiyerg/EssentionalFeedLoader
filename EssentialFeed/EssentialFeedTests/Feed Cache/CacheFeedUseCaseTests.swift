//
//  CacheFeedUseCaseTests.swift
//  EssentialFeedTests
//
//  Created by Akshay  on 2023-07-21.
//

import XCTest
import EssentialFeed

class LocalFeedLoader {
    
    private let store: FeedStore
    private let currentDate: () -> Date
    
    init(store: FeedStore, currentDate: @escaping () -> Date) {
        self.store = store
        self.currentDate = currentDate
    }
    
    func save(_ items: [FeedItem], completion: @escaping (Error?) -> Void) {
        store.deleteCachedFeed { [unowned self] error in
            if error == nil {
                self.store.insert(items, timeStamp: self.currentDate(), completion: completion)
            } else {
                completion(error)
            }
            
        }
    }
}

protocol FeedStore {
    typealias deletionCompletionTypealias = (Error?) -> Void
    typealias insertionCompletionTypealias = (Error?) -> Void
    
    func deleteCachedFeed(completion: @escaping deletionCompletionTypealias)
    func insert(_ items: [FeedItem], timeStamp: Date, completion: @escaping insertionCompletionTypealias)
}

class CacheFeedUseCaseTests: XCTestCase {
    
    func test_init_doesNotMessageStoreUponCreation() {
        
        let (_, store) = makeSut()
        
        XCTAssertEqual(store.receivedMessages, [])
    }
    
    func test_save_requestcacheDeletion() {
        
        let items = [uniqueItem(), uniqueItem()]
        let (sut, store) = makeSut()
        
        sut.save(items) { _ in }
        
        XCTAssertEqual(store.receivedMessages, [.deleteCachedFeed])
    }
    
    func test_save_doesNotRequestCacheInsertionOnDeletionError() {
        
        let items = [uniqueItem(), uniqueItem()]
        let (sut, store) = makeSut()
        let deletionError = anyNSError()
        
        sut.save(items) { _ in }
        store.completeDeletion(with: deletionError)
        
        XCTAssertEqual(store.receivedMessages, [.deleteCachedFeed])
    }
    
    func test_save_requestNewCacheInsertionWithTimeStampOnSuccessfulDeletion() {
        
        let timeStamp = Date()
        let items = [uniqueItem(), uniqueItem()]
        let (sut, store) = makeSut(currentDate: { timeStamp })
        
        sut.save(items) { _ in }
        store.completeDeletionSuccessfully()
        
        XCTAssertEqual(store.receivedMessages, [.deleteCachedFeed, .Insert(items, timeStamp)])
        
    }
    
    func test_save_failsOnDeletionError() {
        
        let (sut, store) = makeSut()
        let deletionError = anyNSError()
        
        expect(sut, toCompleteWith: deletionError, when: {
            store.completeDeletion(with: deletionError)
        })
    }
    
    func test_save_failsOnInsertionError() {
        
        let (sut, store) = makeSut()
        let insertionError = anyNSError()
        expect(sut, toCompleteWith: insertionError, when: {
            store.completeDeletionSuccessfully()
            store.completeInsertion(with: insertionError)
        })
    }
    
    func test_save_succedsOnSuccesfulCacheInsertion() {
        
        let items = [uniqueItem(), uniqueItem()]
        let (sut, store) = makeSut()
        
        expect(sut, toCompleteWith: nil, when: {
            store.completeDeletionSuccessfully()
            store.completeInsertionSuccesfully()
        })
    }
    
    // MARK: - Helpers
    
    private func makeSut(currentDate: @escaping () -> Date = Date.init, file: StaticString = #file, line: UInt = #line) -> (sut: LocalFeedLoader, store: FeedStoreSpy) {
        
        let store = FeedStoreSpy()
        let sut = LocalFeedLoader(store: store, currentDate: currentDate)
        
        trackMemoryLeaks(sut, file: file, line: line)
        trackMemoryLeaks(store, file: file, line: line)
        
        return (sut, store)
    }
    
    private func expect( _ sut: LocalFeedLoader, toCompleteWith expectedError: NSError?, when action: () -> Void, file: StaticString = #file, line: UInt = #line) {
        
        let exp = expectation(description: "wait for save completion")
        
        var receivedError: Error?
        
        sut.save([uniqueItem()]) { expectedError in
            receivedError = expectedError
            exp.fulfill()
        }
        
        action()
        wait(for: [exp], timeout: 1.0)
        
        XCTAssertEqual(receivedError as NSError?, expectedError, file: file, line: line)
    }
    
    private class FeedStoreSpy: FeedStore {
        
        enum ReceivedMessage: Equatable {
            case deleteCachedFeed
            case Insert([FeedItem], Date)
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
        
        func insert(_ items: [FeedItem], timeStamp: Date, completion: @escaping insertionCompletionTypealias) {
            insertionCompletion.append(completion)
            receivedMessages.append(.Insert(items, timeStamp))
        }
        
        func completeInsertion(with error: NSError, at index: Int = 0) {
            insertionCompletion[index](error)
        }
        
        func completeInsertionSuccesfully(at index: Int = 0) {
            insertionCompletion[index](nil)
        }
    }

    
    private func uniqueItem() -> FeedItem {
        return FeedItem(id: UUID(), description: "any", location: "any", imageURL: anyURL())
    }
    
    private func anyURL() -> URL {
        return URL(string: "https://any-url.com")!
    }
    
    private func anyNSError() -> NSError {
        return NSError(domain: "any Error", code: 1)
    }
}
