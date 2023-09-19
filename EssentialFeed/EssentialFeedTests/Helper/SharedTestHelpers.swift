//
//  SharedTestHelpers.swift
//  EssentialFeedTests
//
//  Created by Akshay  on 2023-08-01.
//

import Foundation


func anyNSError() -> NSError {
    return NSError(domain: "any Error", code: 1)
}

func anyURL() -> URL {
    return URL(string: "https://any-url.com")!
}

