//
//  CoreDataFeedStore.swift
//  EssentialFeed
//
//  Created by Akshay  on 2023-08-19.
//

import Foundation
import CoreData

public final class CoreDataFeedStore: FeedStore {
    
    private let container: NSPersistentContainer
    private let context: NSManagedObjectContext
    
    public init(storeURL: URL, bundle: Bundle = .main) throws {
        container = try NSPersistentContainer.load(modelName: "FeedStore", url: storeURL, in: bundle)
        context = container.newBackgroundContext()
    }
    
    public func deleteCachedFeed(completion: @escaping DeletionCompletionTypealias) {
        perform { context in
            completion(Result(catching: {
                try ManagedCache.find(in: context).map(context.delete).map(context.save)
            }))
        }
    }
    
    public func insert(_ feed: [LocalFeedImage], timestamp: Date, completion: @escaping InsertionCompletionTypealias) {
        
        perform { context in
            completion(Result(catching: {
                let managedCache = try ManagedCache.newUniqueInstance(in: context)
                managedCache.timestamp = timestamp
                managedCache.feed = ManagedFeedImage.images(from: feed, in: context)
                
                try context.save()
            }))
        }
    }
    
    public func retrieve(completion: @escaping RetrievalCompletionTypealias) {
        perform { context in
            completion(Result(catching: {
                try ManagedCache.find(in: context).map {
                    return CachedFeed(feed: $0.localFeed, timestamp: $0.timestamp)
                }
            }))
        }
    }
    
    private func perform(_ action: @escaping (NSManagedObjectContext) -> Void) {
        let context = self.context
        context.perform { action(context) }
    }
}
