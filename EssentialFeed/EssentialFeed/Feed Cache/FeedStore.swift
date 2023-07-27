//
//  FeedStore.swift
//  EssentialFeed
//
//  Created by Akshay  on 2023-07-26.
//

import Foundation

public protocol FeedStore {
    typealias deletionCompletionTypealias = (Error?) -> Void
    typealias insertionCompletionTypealias = (Error?) -> Void
    typealias retrievalCompletionTypealias = (Error?) -> Void
    
    func deleteCachedFeed(completion: @escaping deletionCompletionTypealias)
    func insert(_ feed: [LocalFeedImage], timeStamp: Date, completion: @escaping insertionCompletionTypealias)
    func retrieve(completion: @escaping retrievalCompletionTypealias)
}
