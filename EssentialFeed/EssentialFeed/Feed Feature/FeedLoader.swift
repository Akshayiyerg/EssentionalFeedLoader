//
//  FeedLoader.swift
//  EssentialFeed
//
//  Created by Akshay  on 2023-06-24.
//

import Foundation

public typealias LoadFeedResult = Result<[FeedImage], Error>

public protocol FeedLoader {
    func load(completion: @escaping(LoadFeedResult) -> Void)
}
