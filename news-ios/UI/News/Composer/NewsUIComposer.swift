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
        let refreshController = NewsRefreshViewController(newsLoader: newsLoader)
        let newsController = NewsViewController(refreshController: refreshController)
        
        refreshController.onRefresh = adaptNewsToCellControllers(forwardingTo: newsController, loader: imageLoader)
        
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
