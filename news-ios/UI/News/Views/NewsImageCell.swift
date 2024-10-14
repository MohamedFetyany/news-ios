//
//  NewsImageCell.swift
//  news-ios
//
//  Created by Mohamed Ibrahim on 25/09/2024.
//

import UIKit

public final class NewsImageCell: UITableViewCell {
    @IBOutlet private(set) public var titleLabel: UILabel!
    @IBOutlet private(set) public var dateLabel: UILabel!
    @IBOutlet private(set) public var channelLabel: UILabel!
    @IBOutlet private(set) public var newsImageContainer: UIView!
    @IBOutlet private(set) public var newsImageView: UIImageView!
    @IBOutlet private(set) public var newsRetryButton: UIButton!
    
    var onRetry: (() -> Void)?
    
    @IBAction private func retryButtonTapped() {
        onRetry?()
    }
}
