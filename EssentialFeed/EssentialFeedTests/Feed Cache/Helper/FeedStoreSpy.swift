//
//  FeedStoreSpy.swift
//  EssentialFeedTests
//
//  Created by Akshay  on 2023-07-27.
//

import Foundation
import EssentialFeed

class FeedStoreSpy: FeedStore {
    
    enum ReceivedMessage: Equatable {
        case deleteCachedFeed
        case Insert([LocalFeedImage], Date)
        case retrieve
    }
    
    private(set) var receivedMessages = [ReceivedMessage]()
    
    private var deletionCompletion = [DeletionCompletionTypealias]()
    private var insertionCompletion = [InsertionCompletionTypealias]()
    private var retrievalCompletion = [RetrievalCompletionTypealias]()
    
    func deleteCachedFeed(completion: @escaping DeletionCompletionTypealias) {
        deletionCompletion.append(completion)
        receivedMessages.append(.deleteCachedFeed)
    }
    
    func completeDeletion(with error: NSError, at index: Int = 0) {
        deletionCompletion[index](.failure(error))
    }
    
    func completeDeletionSuccessfully(at index: Int = 0) {
        deletionCompletion[index](.success(()))
    }
    
    func insert(_ feed: [LocalFeedImage], timestamp: Date, completion: @escaping InsertionCompletionTypealias) {
        insertionCompletion.append(completion)
        receivedMessages.append(.Insert(feed, timestamp))
    }
    
    func completeInsertion(with error: NSError, at index: Int = 0) {
        insertionCompletion[index](.failure(error))
    }
    
    func completeInsertionSuccesfully(at index: Int = 0) {
        insertionCompletion[index](.success(()))
    }
    
    func retrieve(completion: @escaping RetrievalCompletionTypealias) {
        retrievalCompletion.append(completion)
        receivedMessages.append(.retrieve)
    }
    
    func completeRetrieval(with error: NSError, at index: Int = 0) {
        retrievalCompletion[index](.failure(error))
    }
    
    func completeRetrievalWithEmptyCache(at index: Int = 0) {
        retrievalCompletion[index](.success(.none))
    }
    
    func completeRetrieval(with feed: [LocalFeedImage], timestamp: Date, at index: Int = 0) {
        retrievalCompletion[index](.success(.some(CachedFeed(feed: feed, timestamp: timestamp))))
    }
}
