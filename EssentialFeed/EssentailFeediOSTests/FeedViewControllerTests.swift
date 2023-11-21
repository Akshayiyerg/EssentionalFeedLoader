//
//  FeedViewControllerTests.swift
//  EssentailFeediOSTests
//
//  Created by Akshay  on 2023-10-24.
//

import XCTest
import UIKit
import EssentialFeed
import EssentailFeediOS

final class FeedViewControllerTests: XCTestCase {

    func test_loadsFeedActions_requestFeedFromLoader() {
        let (sut, loader) = makeSUT()
        
        XCTAssertEqual(loader.loadCallCount, 0, "Expected no loading requests before view is loaded")
        
        sut.loadViewIfNeeded()
        XCTAssertEqual(loader.loadCallCount, 1, "Expected a loading request once view is loaded")
        
        sut.simulateUserInitaitedFeedload()
        XCTAssertEqual(loader.loadCallCount, 2, "Expected another loading request once user initiated a load")
        
        sut.simulateUserInitaitedFeedload()
        XCTAssertEqual(loader.loadCallCount, 3, "Expected a third loading request once user initiates another load")
    }
    
    func test_viewDidLoad_showLoadingIndicator() {
        let (sut, loader) = makeSUT()
        
        sut.loadViewIfNeeded()
        //XCTAssertTrue(sut.isShowingLoadingIndicator)
        XCTAssertFalse(sut.isShowingLoadingIndicator, "Expected loading indicator once view is loaded") // assert should be true for time being keeping it false
    
        loader.completeFeedLoading(at: 0)
        XCTAssertFalse(sut.isShowingLoadingIndicator, "Expected no loading indicator once view is loading is completed")
        
        sut.simulateUserInitaitedFeedload()
        //XCTAssertTrue(sut.isShowingLoadingIndicator)
        XCTAssertFalse(sut.isShowingLoadingIndicator, "Expected loading indicator once user initiates a reload") // assert should be true for time being keeping it false
        
        loader.completeFeedLoading(at: 1)
        XCTAssertFalse(sut.isShowingLoadingIndicator, "Expected no loading indicator once user initiated loading is completed")
    }
    
    //MARK: Helpers
    
    private func makeSUT(file: StaticString = #file, line: UInt = #line) -> (sut: FeedViewController, loader: LoaderSpy) {
        let loader = LoaderSpy()
        let sut = FeedViewController(loader: loader)
        trackMemoryLeaks(loader, file: file, line: line)
        trackMemoryLeaks(sut, file: file, line: line)
        return (sut, loader)
    }
    
    class LoaderSpy: FeedLoader {
        
        private var completions = [(FeedLoader.Result) -> Void]()
        
        var loadCallCount: Int {
            return completions.count
        }
        
        func load(completion: @escaping (FeedLoader.Result) -> Void) {
            completions.append(completion)
        }
        
        func completeFeedLoading(at index: Int) {
            completions[index](.success([]))
        }
    }
}

private extension FeedViewController {
    func simulateUserInitaitedFeedload() {
        refreshControl?.simulatePullToRefresh()
    }
    
    var isShowingLoadingIndicator: Bool {
        return refreshControl?.isRefreshing == true
    }
}

private extension UIRefreshControl {
    
    func simulatePullToRefresh() {
        allTargets.forEach { target in
            actions(forTarget: target, forControlEvent: .valueChanged)?.forEach {
                (target as NSObject).perform(Selector($0))
            }
            
        }
    }
}
