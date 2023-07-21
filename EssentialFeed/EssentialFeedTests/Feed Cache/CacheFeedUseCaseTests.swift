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
    
    init(store: FeedStore) {
        self.store = store
    }
    
    func save(_ items: [FeedItem]) {
        store.deleteCachedFeed()
    }
}

class FeedStore {
    var deleteCachedFeedCount = 0
    var insertCallCount = 0
    
    func deleteCachedFeed() {
        deleteCachedFeedCount += 1
    }
    
    func completeDeletion(with error: NSError, at index: Int = 0) {
        
    }
}

class CacheFeedUseCaseTests: XCTestCase {
    
    func test_init_doesNotDeleteCacheUponCreation() {
        
        let (_, store) = makeSut()
        
        XCTAssertEqual(store.deleteCachedFeedCount, 0)
    }
    
    func test_save_requestcacheDeletion() {
        
        let items = [uniqueItem(), uniqueItem()]
        let (sut, store) = makeSut()
        
        sut.save(items)
        
        XCTAssertEqual(store.deleteCachedFeedCount, 1)
    }
    
    func test_save_doesNotRequestCacheInsertionOnDeletionError() {
        
        let items = [uniqueItem(), uniqueItem()]
        let (sut, store) = makeSut()
        let deletionError = anyNSError()
        
        sut.save(items)
        store.completeDeletion(with: deletionError)
        
        XCTAssertEqual(store.insertCallCount, 0)
    }
    
    
    // MARK: - Helpers
    
    private func makeSut(file: StaticString = #file, line: UInt = #line) -> (sut: LocalFeedLoader, store: FeedStore) {
        
        let store = FeedStore()
        let sut = LocalFeedLoader(store: store)
        
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
