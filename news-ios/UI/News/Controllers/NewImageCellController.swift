//
//  NewImageCellController.swift
//  news-ios
//
//  Created by Mohamed Ibrahim on 02/10/2024.
//

import UIKit

final class NewImageCellController {
    
    private let viewModel: NewsImageViewModel<UIImage>
    
    init(viewModel: NewsImageViewModel<UIImage>) {
        self.viewModel = viewModel
    }
    
    func view() -> UITableViewCell {
        let cell = binded(NewsImageCell())
        viewModel.loadImageData()
        return cell
    }
    
    func preloadImage() {
        viewModel.loadImageData()
    }
    
    func cancelLoad() {
        viewModel.cancelImageDataLoad()
    }
    
    private func binded(_ cell: NewsImageCell) -> NewsImageCell {
        cell.titleLabel.text = viewModel.title
        cell.dateLabel.text = viewModel.date
        cell.channelLabel.text = viewModel.channel
        cell.onRetry = viewModel.loadImageData
        
        viewModel.onImageLoad = { [weak cell] image in
            cell?.newsImageView.image = image
        }
        
        viewModel.onLoadImageStateChange = { [weak cell] isLoading in
            cell?.newsImageContainer.isShimmering = isLoading
        }
        
        viewModel.onShouldRetryImageLoadStateChange = { [weak cell] isShouldRetry in
            cell?.newsRetryButton.isHidden = !isShouldRetry
        }
        
        return cell
    }
}

