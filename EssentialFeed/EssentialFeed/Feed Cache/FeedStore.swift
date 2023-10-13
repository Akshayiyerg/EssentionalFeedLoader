//
//  FeedStore.swift
//  EssentialFeed
//
//  Created by Akshay  on 2023-07-26.
//

import Foundation

public typealias CachedFeed = (feed: [LocalFeedImage], timestamp: Date)
    
public protocol FeedStore {
    
    typealias DeletionResult = Result<Void, Error>
    typealias DeletionCompletionTypealias = (DeletionResult) -> Void
    
    typealias InsertionResult = Result<Void, Error>
    typealias InsertionCompletionTypealias = (InsertionResult) -> Void
    
    typealias RetrievalResult = Swift.Result<CachedFeed?, Error>
    typealias RetrievalCompletionTypealias = (RetrievalResult) -> Void
    
    /// The completion handler can be invoked in any thread.
    /// Clients are responsible to dispatch to appropriate threads, if needed.
    func deleteCachedFeed(completion: @escaping DeletionCompletionTypealias)
    
    /// The completion handler can be invoked in any thread.
    /// Clients are responsible to dispatch to appropriate threads, if needed.
    func insert(_ feed: [LocalFeedImage], timestamp: Date, completion: @escaping InsertionCompletionTypealias)
    
    /// The completion handler can be invoked in any thread.
    /// Clients are responsible to dispatch to appropriate threads, if needed.
    func retrieve(completion: @escaping RetrievalCompletionTypealias)
}
