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
    
    func deleteCachedFeed(completion: @escaping deletionCompletionTypealias)
    func insert(_ items: [LocalFeedItem], timeStamp: Date, completion: @escaping insertionCompletionTypealias)
}
