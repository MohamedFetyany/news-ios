//
//  NewImageCellController.swift
//  news-ios
//
//  Created by Mohamed Ibrahim on 02/10/2024.
//

import UIKit

final class NewImageCellController {
    
    private var task: NewsImageDataLoaderTask?
    
    private let model: NewsImage
    private let imageLoader: NewsImageDataLoader
    
    init(model: NewsImage, imageLoader: NewsImageDataLoader) {
        self.model = model
        self.imageLoader = imageLoader
    }
    
    func view() -> UITableViewCell {
        let cell = NewsImageCell()
        cell.titleLabel.text = model.title
        cell.dateLabel.text = model.date
        cell.channelLabel.text = model.channel
        cell.newsImageView.image = nil
        cell.newsRetryButton.isHidden = true
        cell.newsImageContainer.startShimmering()
        
        let loadImage = { [weak cell, weak self] in
            guard let self else { return }
            
            task = imageLoader.loadImageData(from: model.url) { [weak cell] result in
                let data = try? result.get()
                let image = data.map(UIImage.init) ?? nil
                cell?.newsImageView.image = image
                cell?.newsRetryButton.isHidden = image != nil
                cell?.newsImageContainer.stopShimmering()
            }
        }
        cell.onRetry = loadImage
        loadImage()
        return cell
    }
    
    func preloadImage() {
        task = imageLoader.loadImageData(from: model.url) { _ in }
    }
    
    deinit {
        task?.cancel()
        task = nil
    }
}

