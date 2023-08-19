//
//  CoreDataFeedStore.swift
//  EssentialFeed
//
//  Created by Akshay  on 2023-08-19.
//

import Foundation

public final class CoreDataFeedStore: FeedStore {
    
    public init() {}
    
    public func deleteCachedFeed(completion: @escaping DeletionCompletionTypealias) {
        
    }
    
    public func insert(_ feed: [LocalFeedImage], timestamp: Date, completion: @escaping InsertionCompletionTypealias) {
        
    }
    
    public func retrieve(completion: @escaping RetrievalCompletionTypealias) {
        completion(.empty)
    }
}
