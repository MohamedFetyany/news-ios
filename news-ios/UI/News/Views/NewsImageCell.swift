//
//  NewsImageCell.swift
//  news-ios
//
//  Created by Mohamed Ibrahim on 25/09/2024.
//

import UIKit

public final class NewsImageCell: UITableViewCell {
    
    public let titleLabel = UILabel()
    public let dateLabel = UILabel()
    public let channelLabel = UILabel()
    public let newsImageContainer = UIView()
    public let newsImageView = UIImageView()
    private(set) public lazy var newsRetryButton: UIButton = {
        let button = UIButton()
        button.addTarget(self, action: #selector(retryButtonTapped), for: .touchUpInside)
        return button
    }()
    
    var onRetry: (() -> Void)?
    
    @objc private func retryButtonTapped() {
        onRetry?()
    }
}
