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
    typealias deletionCompletionTypealias = (Error?) -> Void
    typealias insertionCompletionTypealias = (Error?) -> Void
    typealias retrievalCompletionTypealias = (RetrievalCachedFeedResult) -> Void
    
    func deleteCachedFeed(completion: @escaping deletionCompletionTypealias)
    func insert(_ feed: [LocalFeedImage], timestamp: Date, completion: @escaping insertionCompletionTypealias)
    func retrieve(completion: @escaping retrievalCompletionTypealias)
}
