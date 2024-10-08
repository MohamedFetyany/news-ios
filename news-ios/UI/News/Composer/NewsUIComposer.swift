//
//  NewsUIComposer.swift
//  news-ios
//
//  Created by Mohamed Ibrahim on 02/10/2024.
//

import Foundation

public final class NewsUIComposer {
    
    private init() {}
    
    public static func composeWith(newsLoader: NewsLoader, imageLoader: NewsImageDataLoader) -> NewsViewController {
        let newsViewModel = NewsViewModel(loader: newsLoader)
        let refreshController = NewsRefreshViewController(viewModel: newsViewModel)
        let newsController = NewsViewController(refreshController: refreshController)
        
        newsViewModel.onNewsLoad = adaptNewsToCellControllers(forwardingTo: newsController, loader: imageLoader)
        
        return newsController
    }
    
    private static func adaptNewsToCellControllers(forwardingTo controller: NewsViewController, loader: NewsImageDataLoader) -> ([NewsImage]) -> Void {
        return { [weak controller] news in
            controller?.tableModel = news.map({ news in
                NewImageCellController(model: news, imageLoader: loader)
            })
        }
    }
}
