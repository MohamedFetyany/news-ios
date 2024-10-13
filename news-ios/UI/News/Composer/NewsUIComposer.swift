//
//  NewsUIComposer.swift
//  news-ios
//
//  Created by Mohamed Ibrahim on 02/10/2024.
//

import Foundation
import UIKit

public final class NewsUIComposer {
    
    private init() {}
    
    public static func composeWith(newsLoader: NewsLoader, imageLoader: NewsImageDataLoader) -> NewsViewController {
        let presentationAdapter = NewsLoaderPresentationAdapter(loader: newsLoader)
        let refreshController = NewsRefreshViewController(delegate: presentationAdapter)
        let newsController = NewsViewController(refreshController: refreshController)
        
        presentationAdapter.presenter = NewsPresenter(
            loadingView: WeakRefVirtualProxy(object: refreshController),
            newsView: NewsViewAdapter(controller: newsController, loader: imageLoader)
        )
            
        return newsController
    }
}

final class WeakRefVirtualProxy<T: AnyObject> {
    weak var object: T?
    
    init(object: T) {
        self.object = object
    }
}

extension WeakRefVirtualProxy: NewsLoadingView where T: NewsLoadingView {
    func display(_ viewModel: NewsLoadingViewModel) {
        object?.display(viewModel)
    }
}

final class NewsViewAdapter: NewsView {
    
    weak var controller: NewsViewController?
    let loader: NewsImageDataLoader
    
    init(controller: NewsViewController, loader: NewsImageDataLoader) {
        self.controller = controller
        self.loader = loader
    }
    
    func display(_ viewModel: NewsViewModel) {
        controller?.tableModel = viewModel.news.map({ model in
            NewImageCellController(viewModel: NewsImageViewModel(model: model, imageLoader: loader,imageTransformer: UIImage.init))
        })
    }
}

final class NewsLoaderPresentationAdapter: NewsRefreshViewControllerDelegate {
    
    var presenter: NewsPresenter?
    
    private let loader: NewsLoader
    
    init(loader: NewsLoader) {
        self.loader = loader
    }
    
    func didRequestNewsRefresh() {
        presenter?.didStartLoadingNews()
        
        loader.load { [weak self] result in
            switch result {
            case let .success(news):
                self?.presenter?.didFinishLoadingNews(with: news)
                
            case let .failure(error):
                self?.presenter?.didFinishLoadingWith(with: error)
            }
        }
    }
}
