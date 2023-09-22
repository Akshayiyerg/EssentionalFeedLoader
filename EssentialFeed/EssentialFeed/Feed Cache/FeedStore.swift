//
//  FeedStore.swift
//  EssentialFeed
//
//  Created by Akshay  on 2023-07-26.
//

import Foundation

public enum CachedFeed {
    case empty
    case found(feed: [LocalFeedImage], timestamp: Date)
}

public protocol FeedStore {
    typealias DeletionCompletionTypealias = (Error?) -> Void
    typealias InsertionCompletionTypealias = (Error?) -> Void
    typealias Result = Swift.Result<CachedFeed, Error>
    typealias RetrievalCompletionTypealias = (Result) -> Void
    
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
