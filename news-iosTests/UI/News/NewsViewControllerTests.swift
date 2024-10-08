//
//  NewsViewControllerTests.swift
//  news-iosTests
//
//  Created by Mohamed Ibrahim on 17/09/2024.
//

import XCTest
import UIKit
import news_ios

class NewsViewControllerTests: XCTestCase {
    
    func test_loadNewsActions_requestsNewsFromLoader() {
        let (sut, loader) = makeSUT()
        XCTAssertEqual(loader.loadCallCount, 0, "Expected no loading requests before view appears")
        
        sut.simulateAppearance()
        XCTAssertEqual(loader.loadCallCount, 1, "Expected a loading request once view appears")
        
        sut.simulateUserInitiatedReload()
        XCTAssertEqual(loader.loadCallCount, 2, "Expected anthor loading request once user initiates a reload")
        
        sut.simulateUserInitiatedReload()
        XCTAssertEqual(loader.loadCallCount, 3, "Expected yet anthor loading request once user initiates anthor reload")
    }
    
    func test_loadingNewsIndicator_isVisibleWhileLoadingNews() {
        let (sut, loader) = makeSUT()
        
        sut.simulateAppearance()
        XCTAssertTrue(sut.isShowingLoadingIndicator, "Expected loading indicator once view appears")
   
        loader.completeNewsLoading(at: 0)
        XCTAssertFalse(sut.isShowingLoadingIndicator, "Expected no loading indicator once loading is completes successfully")
        
        sut.simulateUserInitiatedReload()
        XCTAssertTrue(sut.isShowingLoadingIndicator, "Expected loading indicator once user initiates a reload")
    
        loader.completeNewsLoadingWithError(at: 1)
        XCTAssertFalse(sut.isShowingLoadingIndicator, "Expected no loading indicator once user initiated loading is completes with error")
    }
    
    func test_loadNewsCompletion_rendersSuccessfullyLoadedNews() {
        let image0 = makeImage(title: "a title",date: "a date",channel: "a channerl")
        let image1 = makeImage(title: "another title",date: "another date",channel: "another channerl")
        let (sut, loader) = makeSUT()
        
        sut.simulateAppearance()
        assertThat(sut,isRendering: [])
        
        loader.completeNewsLoading(with: [image0], at: 0)
        assertThat(sut,isRendering: [image0])
        
        sut.simulateUserInitiatedReload()
        loader.completeNewsLoading(with: [image0, image1], at: 1)
        assertThat(sut,isRendering: [image0, image1])
    }
    
    func test_loadNewsCompletion_doesNotAlertCurrentRenderingStateOnError() {
        let image0 = makeImage()
        let (sut, loader) = makeSUT()
        
        sut.simulateAppearance()
        loader.completeNewsLoading(with: [image0], at: 0)
        assertThat(sut,isRendering: [image0])
        
        sut.simulateUserInitiatedReload()
        loader.completeNewsLoadingWithError(at: 1)
        assertThat(sut,isRendering: [image0])
    }
    
    func test_newsImageView_loadsImageURLWhenVisible() {
        let image0 = makeImage(url: URL(string: "https://image-0.com")!)
        let image1 = makeImage(url: URL(string: "https://image-1.com")!)
        let (sut, loader) = makeSUT()
        sut.simulateAppearance()
        
        XCTAssertEqual(loader.loadedImageURLs, [], "Expected no image URL requests until views become visible")
        loader.completeNewsLoading(with: [image0, image1], at: 0)
        
        sut.simulateNewsImageViewVisible(at: 0)
        XCTAssertEqual(loader.loadedImageURLs, [image0.url], "Expected first image URL request once first view becomes visible")
        
        sut.simulateNewsImageViewVisible(at: 1)
        XCTAssertEqual(loader.loadedImageURLs, [image0.url, image1.url], "Expected second image URL request once second also becomes visible")
    }
    
    func test_newsImageView_cancelsImageLoadingWhenNotVisibleAnyMore() {
        let image0 = makeImage(url: URL(string: "https://image-0.com")!)
        let image1 = makeImage(url: URL(string: "https://image-1.com")!)
        let (sut, loader) = makeSUT()
        
        sut.simulateAppearance()
        loader.completeNewsLoading(with: [image0, image1], at: 0)
        XCTAssertEqual(loader.cancelledImageURLs, [], "Expected no cancelled image URL requests until views is not visible")
        
        sut.simulateNewsImageViewNotVisibile(at: 0)
        XCTAssertEqual(loader.cancelledImageURLs, [image0.url], "Expected once cancelled image URL request once first image is not visible anymore")
        
        sut.simulateNewsImageViewNotVisibile(at: 1)
        XCTAssertEqual(loader.cancelledImageURLs, [image0.url, image1.url], "Expected second cancelled image URL request once second image is also not visible anymore")
    }
    
    func test_newsImageView_showsImageLoadingIndicatorWhenLoading() {
        let (sut, loader) = makeSUT()
        
        sut.simulateAppearance()
        loader.completeNewsLoading(with: [makeImage(),makeImage()], at: 0)
        
        let view0 = sut.simulateNewsImageViewVisible(at: 0)
        let view1 = sut.simulateNewsImageViewVisible(at: 1)
        XCTAssertEqual(view0?.isShowingImageLoadingIndicator, true, "Expected loading indicator for first view while loading first image")
        XCTAssertEqual(view1?.isShowingImageLoadingIndicator, true ,"Expected loading indicator for second view while loading second image")
        
        loader.completeImageLoading(at: 0)
        XCTAssertEqual(view0?.isShowingImageLoadingIndicator, false, "Expected no loading indicator for first view once first loading completes successfully")
        XCTAssertEqual(view1?.isShowingImageLoadingIndicator, true, "Expected no loading indicator state change for second view once first image loading completes successfully")
        
        loader.completeImageLoadingWithError(at: 1)
        XCTAssertEqual(view0?.isShowingImageLoadingIndicator, false, "Expected no loading indicator state change for first view once second image loading completes with error")
        XCTAssertEqual(view1?.isShowingImageLoadingIndicator, false, "Expected no loading indicator for second view once second image competes with error")
    }
    
    func test_newsImageView_rendersImageLoadedFromURL() {
        let (sut, loader) = makeSUT()
        
        sut.simulateAppearance()
        loader.completeNewsLoading(with: [makeImage(), makeImage()], at: 0)
        
        let view0 = sut.simulateNewsImageViewVisible(at: 0)
        let view1 = sut.simulateNewsImageViewVisible(at: 1)
        XCTAssertEqual(view0?.renderedImage, .none, "Expected no image for first view while loading first image")
        XCTAssertEqual(view1?.renderedImage, .none, "Expected no image for second view while loading second image")
        
        let imageData0 = UIImage.make(withColor: .red).pngData()!
        loader.completeImageLoading(with: imageData0, at: 0)
        XCTAssertEqual(view0?.renderedImage, imageData0, "Expected image for first view once first image loading completes successfully")
        XCTAssertEqual(view1?.renderedImage, .none, "Expected no image state change for second view once first image loading completes successfully")
        
        let imageData1 = UIImage.make(withColor: .green).pngData()!
        loader.completeImageLoading(with: imageData1, at: 1)
        XCTAssertEqual(view0?.renderedImage, imageData0, "Expected no image state change for first view once second image loading completes successfully")
        XCTAssertEqual(view1?.renderedImage, imageData1, "Expected image for second view once second image loading completes successfully")
    }
    
    func test_newsImageViewRetryButton_isVisibleOnImageLoadURLLoadError() {
        let (sut, loader) = makeSUT()
        
        sut.simulateAppearance()
        loader.completeNewsLoading(with: [makeImage(), makeImage()], at: 0)
        
        let view0 = sut.simulateNewsImageViewVisible(at: 0)
        let view1 = sut.simulateNewsImageViewVisible(at: 1)
        XCTAssertEqual(view0?.isShowingRetryButton, false, "Expected no retry action for first view while loading first image")
        XCTAssertEqual(view1?.isShowingRetryButton, false, "Expected no retry action for second view while loading second image")
        
        let imageData0 = UIImage.make(withColor: .red).pngData()!
        loader.completeImageLoading(with: imageData0, at: 0)
        XCTAssertEqual(view0?.isShowingRetryButton, false, "Expected no retry action for first view once first image loading completes successfully")
        XCTAssertEqual(view1?.isShowingRetryButton, false, "Expected no retry action state change for second view once first image loading completes successfully")
        
        loader.completeImageLoadingWithError(at: 1)
        XCTAssertEqual(view0?.isShowingRetryButton, false, "Expected no retry action state change for second view once image loading completes with error")
        XCTAssertEqual(view1?.isShowingRetryButton, true, "Expected retry action for second view once second image loading completes with error")
    }
    
    func test_newsImageViewRetryButton_isVisibleOnInvalidImageData() {
        let (sut, loader) = makeSUT()
        
        sut.simulateAppearance()
        loader.completeNewsLoading(with: [makeImage()], at: 0)
        
        let view = sut.simulateNewsImageViewVisible(at: 0)
        XCTAssertEqual(view?.isShowingRetryButton, false, "Expected no retry action while loading image")
        
        let invalidImageData = Data("Invalid image data".utf8)
        loader.completeImageLoading(with: invalidImageData, at: 0)
        XCTAssertEqual(view?.isShowingRetryButton, true, "Expected retry action once image loading completes with invalid image data")
    }
    
    func test_newsImageViewRetryButton_retriesImageLoad() {
        let image0 = makeImage(url: URL(string: "https://image-0.com")!)
        let image1 = makeImage(url: URL(string: "https://image-1.com")!)
        let (sut, loader) = makeSUT()
        
        sut.simulateAppearance()
        loader.completeNewsLoading(with: [image0, image1], at: 0)
        
        let view0 = sut.simulateNewsImageViewVisible(at: 0)
        let view1 = sut.simulateNewsImageViewVisible(at: 1)
        XCTAssertEqual(loader.loadedImageURLs, [image0.url, image1.url], "Expected two image URL request for the two visible views")
        
        loader.completeImageLoadingWithError(at: 0)
        loader.completeImageLoadingWithError(at: 1)
        XCTAssertEqual(loader.loadedImageURLs, [image0.url, image1.url], "Expected only two image URL requests before retry action")
        
        view0?.simulateRetryAction()
        XCTAssertEqual(loader.loadedImageURLs, [image0.url, image1.url, image0.url], "Expected third imageURL request after first view retry action")
        
        view1?.simulateRetryAction()
        XCTAssertEqual(loader.loadedImageURLs, [image0.url, image1.url, image0.url, image1.url], "Expected fourth imageURL request after second view retry action")
    }
    
    func test_newsImageView_preloadsImageURLWhenNearVisible() {
        let image0 = makeImage(url: URL(string: "https://image-0.com")!)
        let image1 = makeImage(url: URL(string: "https://image-1.com")!)
        let (sut, loader) = makeSUT()
        
        sut.simulateAppearance()
        loader.completeNewsLoading(with: [image0, image1], at: 0)
        XCTAssertEqual(loader.loadedImageURLs, [], "Expected no image URL requests until image is near visible")

        sut.simulateNewsImageViewNearVisible(at: 0)
        XCTAssertEqual(loader.loadedImageURLs, [image0.url], "Expected first image URL request once first image is near visible")
        
        sut.simulateNewsImageViewNearVisible(at: 1)
        XCTAssertEqual(loader.loadedImageURLs, [image0.url, image1.url], "Expected second image URL request once second image is near visible")
    }
    
    func test_newsImageView_cancelsImageURLPreloadWhenNotNearVisibleAnyMore() {
        let image0 = makeImage(url: URL(string: "https://image-0.com")!)
        let image1 = makeImage(url: URL(string: "https://image-1.com")!)
        let (sut, loader) = makeSUT()
        
        sut.simulateAppearance()
        loader.completeNewsLoading(with: [image0, image1], at: 0)
        XCTAssertEqual(loader.cancelledImageURLs, [], "Expected no cancelled image URL requests until image is not near visible")
        
        sut.simulateNewsImageViewNotNearVisible(at: 0)
        XCTAssertEqual(loader.cancelledImageURLs, [image0.url], "Expected first cancelled image URL request once first image is no near visible anymore")
        
        sut.simulateNewsImageViewNotNearVisible(at: 1)
        XCTAssertEqual(loader.cancelledImageURLs, [image0.url, image1.url], "Expected second cancelled image URL request once second image is not near visible anymore")
    }
    
    // MARK:  Helpers
    
    private func makeSUT(
        file: StaticString = #filePath,
        line: UInt = #line
    ) -> (sut: NewsViewController, loader: LoaderSpy) {
        let loader = LoaderSpy()
        let sut = NewsUIComposer.composeWith(newsLoader: loader, imageLoader: loader)
        
        trackForMemoryLeaks(loader, file: file, line: line)
        trackForMemoryLeaks(sut, file: file, line: line)
        
        return (sut, loader)
    }
    
    private func makeImage(
        title: String = "a title",
        date: String = "a date",
        channel: String = "a channel",
        url: URL =  URL(string: "https://a-url.com")!
    ) -> NewsImage {
        NewsImage(
            id: UUID(),
            title: title,
            date: date,
            channel: channel,
            url: url
        )
    }
}
