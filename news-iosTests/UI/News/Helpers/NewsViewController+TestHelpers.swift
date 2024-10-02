//
//  NewsViewController+TestHelpers.swift
//  news-iosTests
//
//  Created by Mohamed Ibrahim on 02/10/2024.
//

import UIKit
import news_ios

extension NewsViewController {
    func simulateUserInitiatedReload() {
        refreshControl?.simulatePullToRefresh()
    }
    
    var isShowingLoadingIndicator: Bool {
        refreshControl?.isRefreshing == true
    }
    
    func simulateNewsImageViewNotNearVisible(at row: Int) {
        simulateNewsImageViewNearVisible(at: row)
        
        let pds = tableView.prefetchDataSource
        let index = IndexPath(row: row, section: newsSection)
        pds?.tableView?(tableView, cancelPrefetchingForRowsAt: [index])
    }
    
    func simulateNewsImageViewNearVisible(at row: Int) {
        let pds = tableView.prefetchDataSource
        let index = IndexPath(row: row, section: newsSection)
        pds?.tableView(tableView, prefetchRowsAt: [index])
    }
    
    func simulateNewsImageViewNotVisibile(at row: Int) {
        let view = simulateNewsImageViewVisible(at: row)
        let dl = tableView.delegate
        let index = IndexPath(row: row, section: newsSection)
        dl?.tableView?(tableView, didEndDisplaying: view!, forRowAt: index)
    }
    
    @discardableResult
    func simulateNewsImageViewVisible(at row: Int) -> NewsImageCell? {
        return newsImageView(at: row) as? NewsImageCell
    }
    
    func newsImageView(at row: Int) -> UITableViewCell? {
        let ds = tableView.dataSource
        let index = IndexPath(row: row, section: newsSection)
        return ds?.tableView(tableView, cellForRowAt: index)
    }

    func numberOfRenderedNewsImageViews() -> Int {
        tableView.numberOfRows(inSection: newsSection)
    }
    
    private var newsSection: Int { 0 }
}

extension NewsViewController {
    
    func simulateAppearance() {
        if !isViewLoaded {
            loadViewIfNeeded()
            prepareForFirstAppearance()
        }
        
        beginAppearanceTransition(true, animated: false)
        endAppearanceTransition()
    }
    
    private func prepareForFirstAppearance() {
        setSmallFrameToPreventRenderingCells()
        replaceRefreshControlWithFakeForiOS17PlusSupport()
    }
    
    private func setSmallFrameToPreventRenderingCells() {
        tableView.frame = .init(x: 0, y: 0, width: 390, height: 1)
    }
    
    private func replaceRefreshControlWithFakeForiOS17PlusSupport() {
        let fakeRefreshControl = FakeRefreshControl()
        
        refreshControl?.allTargets.forEach({ target in
            refreshControl?.actions(forTarget: target, forControlEvent: .valueChanged)?.forEach({ action in
                fakeRefreshControl.addTarget(target, action: Selector(action), for: .valueChanged)
            })
        })
        
        refreshControl = fakeRefreshControl
        refreshController?.view = fakeRefreshControl
    }
    
    private class FakeRefreshControl: UIRefreshControl {
        private var _isRefreshing = false
        
        override var isRefreshing: Bool { _isRefreshing }
        
        override func beginRefreshing() {
            _isRefreshing = true
        }
        
        override func endRefreshing() {
            _isRefreshing = false
        }
    }
}
