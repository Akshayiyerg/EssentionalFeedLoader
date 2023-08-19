//
//  CoreDataFeedStore.swift
//  EssentialFeed
//
//  Created by Akshay  on 2023-08-19.
//

import Foundation
import CoreData

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

private class ManagedCache: NSManagedObject {
    @NSManaged var timestamp: Date
    @NSManaged var feed: NSOrderedSet
}


private class ManagedFeedImage: NSManagedObject {
    @NSManaged var id: UUID
    @NSManaged var imageDescription: String?
    @NSManaged var location: String?
    @NSManaged var url: URL
    @NSManaged var Cache: ManagedCache
}
