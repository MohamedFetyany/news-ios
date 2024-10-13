//
//  NewsPresenter.swift
//  news-ios
//
//  Created by Mohamed Ibrahim on 10/10/2024.
//

import Foundation

protocol NewsLoadingView {
    func display(_ viewModel: NewsLoadingViewModel)
}

protocol NewsView {
    func display(_ viewModel: NewsViewModel)
}

final class NewsPresenter {
    
    let loadingView: NewsLoadingView
    let newsView: NewsView
    
    init(loadingView: NewsLoadingView, newsView: NewsView) {
        self.loadingView = loadingView
        self.newsView = newsView
    }
    
    func didStartLoadingNews() {
        loadingView.display(NewsLoadingViewModel(isLoading: true))
    }
    
    func didFinishLoadingNews(with news: [NewsImage]){
        newsView.display(NewsViewModel(news: news))
        loadingView.display(NewsLoadingViewModel(isLoading: false))
    }
    
    func didFinishLoadingWith(with error: Error) {
        loadingView.display(NewsLoadingViewModel(isLoading: false))
    }
}
