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
    
    func save(_ items: [FeedItem]) {
        store.deleteCachedFeed { [unowned self] error in
            if error == nil {
                self.store.insert(items, timeStamp: self.currentDate())
            }
            
        }
    }
}

class FeedStore {
    
    typealias deletionCompletionTypealias = (Error?) -> Void
    
    enum ReceivedMessage: Equatable {
        case deleteCachedFeed
        case Insert([FeedItem], Date)
    }
    
    private(set) var receivedMessages = [ReceivedMessage]()
    
    private var deletionCompletion = [deletionCompletionTypealias]()
    
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
    
    func insert(_ items: [FeedItem], timeStamp: Date) {
        receivedMessages.append(.Insert(items, timeStamp))
    }
}

class CacheFeedUseCaseTests: XCTestCase {
    
    func test_init_doesNotMessageStoreUponCreation() {
        
        let (_, store) = makeSut()
        
        XCTAssertEqual(store.receivedMessages, [])
    }
    
    func test_save_requestcacheDeletion() {
        
        let items = [uniqueItem(), uniqueItem()]
        let (sut, store) = makeSut()
        
        sut.save(items)
        
        XCTAssertEqual(store.receivedMessages, [.deleteCachedFeed])
    }
    
    func test_save_doesNotRequestCacheInsertionOnDeletionError() {
        
        let items = [uniqueItem(), uniqueItem()]
        let (sut, store) = makeSut()
        let deletionError = anyNSError()
        
        sut.save(items)
        store.completeDeletion(with: deletionError)
        
        XCTAssertEqual(store.receivedMessages, [.deleteCachedFeed])
    }
    
    func test_save_requestNewCacheInsertionWithTimeStampOnSuccessfulDeletion() {
        
        let timeStamp = Date()
        let items = [uniqueItem(), uniqueItem()]
        let (sut, store) = makeSut(currentDate: { timeStamp })
        
        sut.save(items)
        store.completeDeletionSuccessfully()
        
        XCTAssertEqual(store.receivedMessages, [.deleteCachedFeed, .Insert(items, timeStamp)])
        
    }
    
    
    // MARK: - Helpers
    
    private func makeSut(currentDate: @escaping () -> Date = Date.init, file: StaticString = #file, line: UInt = #line) -> (sut: LocalFeedLoader, store: FeedStore) {
        
        let store = FeedStore()
        let sut = LocalFeedLoader(store: store, currentDate: currentDate)
        
        trackMemoryLeaks(sut, file: file, line: line)
        trackMemoryLeaks(store, file: file, line: line)
        
        return (sut, store)
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
