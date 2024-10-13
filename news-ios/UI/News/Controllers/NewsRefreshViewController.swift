//
//  NewsRefreshViewController.swift
//  news-ios
//
//  Created by Mohamed Ibrahim on 02/10/2024.
//

import UIKit

protocol NewsRefreshViewControllerDelegate {
    func didRequestNewsRefresh()
}

public final class NewsRefreshViewController: NSObject, NewsLoadingView {
    public lazy var view = loadView()
    
    private let delegate: NewsRefreshViewControllerDelegate
    
    init(delegate: NewsRefreshViewControllerDelegate) {
        self.delegate = delegate
    }
    
    @objc func load() {
        delegate.didRequestNewsRefresh()
    }
    
    func display(_ viewModel: NewsLoadingViewModel) {
        if viewModel.isLoading {
            view.beginRefreshing()
        } else {
            view.endRefreshing()
        }
    }
    
    private func loadView() -> UIRefreshControl {
        let view = UIRefreshControl()
        view.addTarget(self, action: #selector(load), for: .valueChanged)
        return view
    }
}
