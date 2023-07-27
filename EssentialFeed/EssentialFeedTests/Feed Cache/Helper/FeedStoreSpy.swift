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
    
    private var deletionCompletion = [deletionCompletionTypealias]()
    private var insertionCompletion = [insertionCompletionTypealias]()
    private var retrievalCompletion = [retrievalCompletionTypealias]()
    
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
    
    func retrieve(completion: @escaping retrievalCompletionTypealias) {
        retrievalCompletion.append(completion)
        receivedMessages.append(.retrieve)
    }
    
    func completeRetrieval(with error: NSError, at index: Int = 0) {
        retrievalCompletion[index](error)
    }
}
