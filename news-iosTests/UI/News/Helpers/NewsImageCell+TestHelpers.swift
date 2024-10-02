//
//  NewsImageCell+TestHelpers.swift
//  news-iosTests
//
//  Created by Mohamed Ibrahim on 02/10/2024.
//

import Foundation
import news_ios

extension NewsImageCell {
    var titleText: String? {
        titleLabel.text
    }
    
    var dateText: String? {
        dateLabel.text
    }
    
    var channelText: String? {
        channelLabel.text
    }
    
    var isShowingImageLoadingIndicator: Bool {
        newsImageContainer.isShimmering
    }
    
    var renderedImage: Data? {
        newsImageView.image?.pngData()
    }
    
    var isShowingRetryButton: Bool {
        newsRetryButton.isHidden == false
    }
    
    func simulateRetryAction() {
        newsRetryButton.simulateTap()
    }
}
