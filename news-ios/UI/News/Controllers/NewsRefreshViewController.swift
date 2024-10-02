//
//  NewsRefreshViewController.swift
//  news-ios
//
//  Created by Mohamed Ibrahim on 02/10/2024.
//

import UIKit

public final class NewsRefreshViewController: NSObject {
    public lazy var view: UIRefreshControl = {
        let view = UIRefreshControl()
        view.addTarget(self, action: #selector(load), for: .valueChanged)
        return view
    }()
    
    private let newsLoader: NewsLoader
    
    init(newsLoader: NewsLoader) {
        self.newsLoader = newsLoader
    }
    
    var onRefresh: (([NewsImage]) -> Void)?
    
    @objc func load() {
        view.beginRefreshing()
        newsLoader.load { [weak self] result in
            if let news = try? result.get() {
                self?.onRefresh?(news)
            }
            self?.view.endRefreshing()
        }
    }
}

