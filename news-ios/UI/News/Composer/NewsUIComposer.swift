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
        
        let bundle = Bundle(for: NewsViewController.self)
        let storyboard = UIStoryboard(name: "News", bundle: bundle)
        let newsController = storyboard.instantiateInitialViewController() as! NewsViewController
        newsController.delegate = presentationAdapter
        
        presentationAdapter.presenter = NewsPresenter(
            loadingView: WeakRefVirtualProxy(newsController),
            newsView: NewsViewAdapter(controller: newsController, loader: imageLoader)
        )
            
        return newsController
    }
}

final class WeakRefVirtualProxy<T: AnyObject> {
    weak var object: T?
    
    init(_ object: T) {
        self.object = object
    }
}

extension WeakRefVirtualProxy: NewsLoadingView where T: NewsLoadingView {
    func display(_ viewModel: NewsLoadingViewModel) {
        object?.display(viewModel)
    }
}

extension WeakRefVirtualProxy: NewsImageView where T: NewsImageView , T.Image == UIImage {
    func display(_ viewModel: NewsImageViewModel<UIImage>) {
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
            let adapter = NewsImageDataLoaderPresentationAdapter<WeakRefVirtualProxy<NewImageCellController>, UIImage>(model: model, imageloader: loader)
            let view = NewImageCellController(delegate: adapter)
            adapter.presenter = NewsImagePresenter(view: WeakRefVirtualProxy(view),imageTransformer: UIImage.init)
            return view
        })
    }
}

final class NewsLoaderPresentationAdapter: NewsViewControllerDelegate {
    
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

final class NewsImageDataLoaderPresentationAdapter<View: NewsImageView, Image>: NewImageCellControllerDelegate where View.Image == Image {
    
    var presenter: NewsImagePresenter<View,Image>?
    
    private var task: NewsImageDataLoaderTask?
    
    private let model: NewsImage
    private let imageloader: NewsImageDataLoader
    
    init(model: NewsImage, imageloader: NewsImageDataLoader) {
        self.model = model
        self.imageloader = imageloader
    }
    
    func didRequestImage() {
        presenter?.didStartLoadingImageData(for: model)
        
        task = imageloader.loadImageData(from: model.url) { [weak self, model] result in
            switch result {
            case let .success(data):
                self?.presenter?.didFinishLoadingImageData(with: data, for: model)
                
            case let .failure(error):
                self?.presenter?.didFinishLoadingImageData(with: error, for: model)
            }
        }
    }
    
    func didCancelImageRequest() {
        task?.cancel()
        task = nil
    }
}
