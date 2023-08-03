//
//  FeedStore.swift
//  EssentialFeed
//
//  Created by Akshay  on 2023-07-26.
//

import Foundation

public enum RetrievalCachedFeedResult {
    case empty
    case found(feed: [LocalFeedImage], timestamp: Date)
    case failure(Error)
}

public protocol FeedStore {
    typealias DeletionCompletionTypealias = (Error?) -> Void
    typealias InsertionCompletionTypealias = (Error?) -> Void
    typealias RetrievalCompletionTypealias = (RetrievalCachedFeedResult) -> Void
    
    func deleteCachedFeed(completion: @escaping DeletionCompletionTypealias)
    func insert(_ feed: [LocalFeedImage], timestamp: Date, completion: @escaping InsertionCompletionTypealias)
    func retrieve(completion: @escaping RetrievalCompletionTypealias)
}
