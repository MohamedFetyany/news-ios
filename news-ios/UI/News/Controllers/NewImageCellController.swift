//
//  NewImageCellController.swift
//  news-ios
//
//  Created by Mohamed Ibrahim on 02/10/2024.
//

import UIKit

protocol NewImageCellControllerDelegate {
    func didRequestImage()
    func didCancelImageRequest()
}

final class NewImageCellController: NewsImageView {
    
    private var cell: NewsImageCell?
    
    private let delegate: NewImageCellControllerDelegate
    
    init(delegate: NewImageCellControllerDelegate) {
        self.delegate = delegate
    }
    
    func view(in tableView: UITableView) -> UITableViewCell {
        cell = tableView.dequeueReusableCell()
        delegate.didRequestImage()
        return cell!
    }
    
    func preloadImage() {
        delegate.didRequestImage()
    }
    
    func cancelLoad() {
        releaseCellForReuse()
        delegate.didCancelImageRequest()
    }
    
    func display(_ viewModel: NewsImageViewModel<UIImage>) {
        cell?.titleLabel.text = viewModel.title
        cell?.dateLabel.text = viewModel.date
        cell?.channelLabel.text = viewModel.channel
        cell?.newsImageView.setImageAnimated(viewModel.image)
        cell?.newsImageContainer.isShimmering = viewModel.isLoading
        cell?.newsRetryButton.isHidden = !viewModel.shouldRetry
        cell?.onRetry = delegate.didRequestImage
    }
    
    private func releaseCellForReuse() {
        cell = nil
    }
}

