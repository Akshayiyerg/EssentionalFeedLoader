//
//  CacheFeedUseCaseTests.swift
//  EssentialFeedTests
//
//  Created by Akshay  on 2023-07-21.
//

import XCTest
import EssentialFeed

class CacheFeedUseCaseTests: XCTestCase {
    
    func test_init_doesNotMessageStoreUponCreation() {
        
        let (_, store) = makeSut()
        
        XCTAssertEqual(store.receivedMessages, [])
    }
    
    func test_save_requestcacheDeletion() {
        
        let (sut, store) = makeSut()
        
        sut.save(uniqueImageFeed().modelItems) { _ in }
        
        XCTAssertEqual(store.receivedMessages, [.deleteCachedFeed])
    }
    
    func test_save_doesNotRequestCacheInsertionOnDeletionError() {
        
        let (sut, store) = makeSut()
        let deletionError = anyNSError()
        
        sut.save(uniqueImageFeed().modelItems) { _ in }
        store.completeDeletion(with: deletionError)
        
        XCTAssertEqual(store.receivedMessages, [.deleteCachedFeed])
    }
    
    func test_save_requestNewCacheInsertionWithTimeStampOnSuccessfulDeletion() {
        
        let timestamp = Date()
        let feed = uniqueImageFeed()
        let (sut, store) = makeSut(currentDate: { timestamp })
        
        sut.save(feed.modelItems) { _ in }
        store.completeDeletionSuccessfully()
        
        XCTAssertEqual(store.receivedMessages, [.deleteCachedFeed, .Insert(feed.localItems, timestamp)])
        
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
        
        let (sut, store) = makeSut()
        
        expect(sut, toCompleteWith: nil, when: {
            store.completeDeletionSuccessfully()
            store.completeInsertionSuccesfully()
        })
    }
    
    func test_save_doesNotDeliverDeletionErrorAfterSUTInstanceDeallocated() {
        
        let store = FeedStoreSpy()
        var sut : LocalFeedLoader? = LocalFeedLoader(store: store, currentDate: Date.init)
        
        var receivedErrors = [LocalFeedLoader.SaveResult]()
        
        sut?.save([uniqueImage()]) { receivedErrors.append($0)}
        
        sut = nil
        store.completeDeletion(with: anyNSError())
        
        XCTAssertTrue(receivedErrors.isEmpty)
    }
    
    func test_save_doesNotDeliverinsertionErrorAfterSUTInstanceDeallocated() {
        
        let store = FeedStoreSpy()
        var sut : LocalFeedLoader? = LocalFeedLoader(store: store, currentDate: Date.init)
        
        var receivedErrors = [LocalFeedLoader.SaveResult]()
        
        sut?.save([uniqueImage()]) { receivedErrors.append($0)}
        
        store.completeDeletionSuccessfully()
        sut = nil
        store.completeInsertion(with: anyNSError())
        
        
        XCTAssertTrue(receivedErrors.isEmpty)
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
        
        sut.save([uniqueImage()]) { expectedError in
            receivedError = expectedError
            exp.fulfill()
        }
        
        action()
        wait(for: [exp], timeout: 1.0)
        
        XCTAssertEqual(receivedError as NSError?, expectedError, file: file, line: line)
    }
    
    private func uniqueImage() -> FeedImage {
        return FeedImage(id: UUID(), description: "any", location: "any", url: anyURL())
    }
    
    private func uniqueImageFeed() -> (modelItems: [FeedImage], localItems: [LocalFeedImage]) {
        let feed = [uniqueImage(), uniqueImage()]
        let localFeed = feed.map { LocalFeedImage(id: $0.id, description: $0.description, location: $0.location, url: $0.url) }
        return (feed, localFeed)
    }
    
    private func anyURL() -> URL {
        return URL(string: "https://any-url.com")!
    }
    
    private func anyNSError() -> NSError {
        return NSError(domain: "any Error", code: 1)
    }
}
