//
//  RemoteFeedItem.swift
//  EssentialFeed
//
//  Created by Akshay  on 2023-07-26.
//

import Foundation

internal struct RemoteFeedItem: Decodable {
    internal let id: UUID
    internal let description: String?
    internal let location: String?
    internal let image: URL
}
