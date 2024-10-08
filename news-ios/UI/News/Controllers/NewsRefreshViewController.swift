//
//  NewsRefreshViewController.swift
//  news-ios
//
//  Created by Mohamed Ibrahim on 02/10/2024.
//

import UIKit

public final class NewsRefreshViewController: NSObject {
    public lazy var view = binded(UIRefreshControl())
    
    private let viewModel: NewsViewModel
    
    init(viewModel: NewsViewModel) {
        self.viewModel = viewModel
    }
        
    @objc func load() {
        viewModel.loadNews()
    }
    
    private func binded(_ view: UIRefreshControl) -> UIRefreshControl {
        viewModel.onLoadingStateChange = { [weak self] isLoading in
            if isLoading {
                self?.view.beginRefreshing()
            } else {
                self?.view.endRefreshing()
            }
        }
        
        view.addTarget(self, action: #selector(load), for: .valueChanged)
        
        return view
    }
}

