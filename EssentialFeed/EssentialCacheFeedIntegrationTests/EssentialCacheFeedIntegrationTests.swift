//
//  EssentialCacheFeedIntegrationTests.swift
//  EssentialCacheFeedIntegrationTests
//
//  Created by Akshay  on 2023-09-19.
//

import XCTest
import EssentialFeed

final class EssentialCacheFeedIntegrationTests: XCTestCase {
    
    override func setUp() {
        super.setUp()
        
        setUpStoreState()
    }
    
    override func tearDown() {
        super.tearDown()
        
        undoStoreSideEffects()
    }

    func test_load_deliversNoItemOnEmptyCache() {
        let sut = makeSUT()
        
        expect(sut, toLoad: [])
    }
    
    func test_load_deliversItemsSavedOnASeparateInstance() {
        let sutToPerformSave = makeSUT()
        let sutToPerformLoad = makeSUT()
        let feed = uniqueImageFeed().modelItems
        
        save(sutToPerformSave, toSave: feed)
        
        expect(sutToPerformLoad, toLoad: feed)
    }
    
    func test_save_overridesItemSavedOnASeparateInstance() {
        
        let sutToPerformFirstSave = makeSUT()
        let sutToPerformLastSave = makeSUT()
        let sutToPerformLoad = makeSUT()
        let firstFeed = uniqueImageFeed().modelItems
        let latestFeed = uniqueImageFeed().modelItems
        
        save(sutToPerformFirstSave, toSave: firstFeed)
        
        save(sutToPerformLastSave, toSave: latestFeed)
        
        expect(sutToPerformLoad, toLoad: latestFeed)
        
    }
    
    // MARK: Helpers
    
    private func makeSUT() -> LocalFeedLoader {
        let storeBundle = Bundle(for: CoreDataFeedStore.self)
        let storeURL = testSpecificStoreURL()
        let store = try! CoreDataFeedStore(storeURL: storeURL, bundle: storeBundle)
        let sut = LocalFeedLoader(store: store, currentDate: Date.init)
        trackMemoryLeaks(store, file: #file, line: #line)
        trackMemoryLeaks(sut, file: #file, line: #line)
        return sut
    }
    
    private func expect(_ sut: LocalFeedLoader, toLoad expectedFeed: [FeedImage], file: StaticString = #file, line: UInt = #line) {
        
        let loadExp = expectation(description: "wait for load completion")
        sut.load { result in
            switch result {
            case let .success(loadFeed):
                XCTAssertEqual(loadFeed, expectedFeed, file: file, line: line)
                
            case let .failure(error):
                XCTFail("Expected successful feed result, got \(error) instead", file: file, line: line)
            }
            loadExp.fulfill()
        }
        wait(for: [loadExp], timeout: 1.0)
        
    }
    
    private func save(_ sut: LocalFeedLoader, toSave feedToSave: [FeedImage], file: StaticString = #file, line: UInt = #line) {
        let saveExp = expectation(description: "wait for the First save to complete")
        sut.save(feedToSave) { result in
            if case let Result.failure(error) = result {
                XCTAssertNil(error, "Expected to save feed successfully", file: file, line: line)
            }
            saveExp.fulfill()
        }
        wait(for: [saveExp], timeout: 1.0)
    }
    
    private func testSpecificStoreURL() -> URL {
        return cachesDirectory().appendingPathExtension("\(type(of: self)).store")
    }
    
    private func cachesDirectory() -> URL {
        return FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask).first!
    }
    
    private func setUpStoreState() {
        deleteStoreArtifacts()
    }
    
    private func undoStoreSideEffects() {
        deleteStoreArtifacts()
    }
    
    private func deleteStoreArtifacts() {
        try? FileManager.default.removeItem(at: testSpecificStoreURL())
    }
}
