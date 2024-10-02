//
//  NewsViewControllerTests+Assertions.swift
//  news-iosTests
//
//  Created by Mohamed Ibrahim on 02/10/2024.
//

import Foundation
import news_ios
import XCTest

extension NewsViewControllerTests {
    func assertThat(
        _ sut: NewsViewController,
        isRendering news: [NewsImage],
        file: StaticString = #filePath,
        line: UInt = #line
    ) {
        guard sut.numberOfRenderedNewsImageViews() == news.count else {
            return XCTFail("Expected \(news.count) images, got \(sut.numberOfRenderedNewsImageViews()) instead", file: file, line: line)
        }
        
        news.enumerated().forEach { index, image in
            assertThat(sut, hasViewConfiguredFor: image, at: index, file: file, line: line)
        }
    }
    
    func assertThat(
        _ sut: NewsViewController,
        hasViewConfiguredFor image: NewsImage,
        at index: Int,
        file: StaticString = #filePath,
        line: UInt = #line
    ) {
        
        let view = sut.newsImageView(at: index)
        
        guard let cell = view as? NewsImageCell else {
            return XCTFail("Expected \(NewsImageCell.self) instance, got \(String(describing: view)) instead", file: file, line: line)
        }
        
        XCTAssertEqual(cell.titleText, image.title, "Expected title text to be \(String(describing: image.title)) for image view at index (\(index))", file: file, line: line)
        
        XCTAssertEqual(cell.dateText, image.date, "Expected date text to be \(String(describing: image.date)) for image view at index (\(index)", file: file, line: line)
        
        XCTAssertEqual(cell.channelText, image.channel, "Expected channel text to be \(String(describing: image.channel)) for image view at index (\(index))", file: file, line: line)
    }
}
