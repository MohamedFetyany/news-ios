//
//  NewsImageViewModel.swift
//  news-ios
//
//  Created by Mohamed Ibrahim on 08/10/2024.
//

import Foundation

final class NewsImageViewModel<Image> {
    typealias Observer<T> = (T) -> Void
    private var task: NewsImageDataLoaderTask?
    
    private let model: NewsImage
    private let imageLoader: NewsImageDataLoader
    private let imageTransformer: ((Data) -> Image?)
    
    init(model: NewsImage, imageLoader: NewsImageDataLoader,imageTransformer: @escaping((Data) -> Image?)) {
        self.model = model
        self.imageLoader = imageLoader
        self.imageTransformer = imageTransformer
    }
    
    var title: String {
        model.title
    }
    
    var date: String {
        model.date
    }
    
    var channel: String {
        model.channel
    }
    
    var onImageLoad: Observer<Image>?
    var onLoadImageStateChange: Observer<Bool>?
    var onShouldRetryImageLoadStateChange: Observer<Bool>?
    
    func loadImageData() {
        onLoadImageStateChange?(true)
        onShouldRetryImageLoadStateChange?(false)
        task = imageLoader.loadImageData(from: model.url) { [weak self] result in
            self?.handle(result)
        }
    }
    
    func cancelImageDataLoad() {
        task?.cancel()
        task = nil
    }
    
    private func handle(_ result: Result<Data, Error>) {
        if let image = (try? result.get()).flatMap(imageTransformer) {
            onImageLoad?(image)
        } else {
            onShouldRetryImageLoadStateChange?(true)
        }
        onLoadImageStateChange?(false)
    }
}
