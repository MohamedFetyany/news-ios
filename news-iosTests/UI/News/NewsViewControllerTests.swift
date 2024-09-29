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
        
        sut.simulateUserInitiatedFeedReload()
        XCTAssertEqual(loader.loadCallCount, 2, "Expected anthor loading request once user initiates a reload")
        
        sut.simulateUserInitiatedFeedReload()
        XCTAssertEqual(loader.loadCallCount, 3, "Expected yet anthor loading request once user initiates anthor reload")
    }
    
    func test_loadingNewsIndicator_isVisibleWhileLoadingNews() {
        let (sut, loader) = makeSUT()
        
        sut.simulateAppearance()
        XCTAssertTrue(sut.isShowingLoadingIndicator, "Expected loading indicator once view appears")
   
        loader.completeNewsLoading(at: 0)
        XCTAssertFalse(sut.isShowingLoadingIndicator, "Expected no loading indicator once loading is completes successfully")
        
        sut.simulateUserInitiatedFeedReload()
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
        
        sut.simulateUserInitiatedFeedReload()
        loader.completeNewsLoading(with: [image0, image1], at: 1)
        assertThat(sut,isRendering: [image0, image1])
    }
    
    func test_loadNewsCompletion_doesNotAlertCurrentRenderingStateOnError() {
        let image0 = makeImage()
        let (sut, loader) = makeSUT()
        
        sut.simulateAppearance()
        loader.completeNewsLoading(with: [image0], at: 0)
        assertThat(sut,isRendering: [image0])
        
        sut.simulateUserInitiatedFeedReload()
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
    
    func test_feedImageRetryButton_isVisibleOnInvalidImageData() {
        let (sut, loader) = makeSUT()
        
        sut.simulateAppearance()
        loader.completeNewsLoading(with: [makeImage()], at: 0)
        
        let view = sut.simulateNewsImageViewVisible(at: 0)
        XCTAssertEqual(view?.isShowingRetryButton, false, "Expected no retry action while loading image")
        
        let invalidImageData = Data("Invalid image data".utf8)
        loader.completeImageLoading(with: invalidImageData, at: 0)
        XCTAssertEqual(view?.isShowingRetryButton, true, "Expected retry action once image loading completes with invalid image data")
    }
    
    // MARK:  Helpers
    
    private func makeSUT(
        file: StaticString = #filePath,
        line: UInt = #line
    ) -> (sut: NewsViewController, loader: NewsLoaderSpy) {
        let loader = NewsLoaderSpy()
        let sut = NewsViewController(newsLoader: loader, imageLoader: loader)
        
        trackForMemoryLeaks(loader, file: file, line: line)
        trackForMemoryLeaks(sut, file: file, line: line)
        
        return (sut, loader)
    }
    
    private func assertThat(
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
    
    private func assertThat(
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
    
    private class NewsLoaderSpy: NewsLoader, NewsImageDataLoader {
        
        private var completions = [(NewsLoader.Result) -> Void]()
        
        var loadCallCount: Int {
            completions.count
        }
        
        func load(completion: @escaping (NewsLoader.Result) -> Void) {
            completions.append(completion)
        }
        
        func completeNewsLoading(with news: [NewsImage] = [], at index: Int) {
            completions[index](.success(news))
        }
        
        func completeNewsLoadingWithError(at index: Int) {
            let error = NSError(domain: "any error", code: 0)
            completions[index](.failure(error))
        }
        
        // MARK:  NewsImageDataLoader
        
        private(set) var imageRequests = [(url: URL, completion: (NewsImageDataLoader.Result) -> Void)]()
        
        var loadedImageURLs: [URL] {
            imageRequests.map { $0.url }
        }
        private(set) var cancelledImageURLs = [URL]()
        
        func loadImageData(from url: URL,completion: @escaping ((NewsImageDataLoader.Result) -> Void)) -> NewsImageDataLoaderTask {
            imageRequests.append((url, completion))
            return TaskSpy { [weak self] in
                self?.cancelledImageURLs.append(url)
            }
        }
        
        func completeImageLoading(with data: Data = Data(), at index: Int) {
            imageRequests[index].completion(.success(data))
        }
        
        func completeImageLoadingWithError(at index: Int) {
            let error = NSError(domain: "any error", code: 0)
            imageRequests[index].completion(.failure(error))
        }
        
        private struct TaskSpy: NewsImageDataLoaderTask {
            let cancelCallback: () -> Void
            
            func cancel() {
                cancelCallback()
            }
        }
    }
}

private extension UIRefreshControl {
    
    func simulatePullToRefresh() {
        allTargets.forEach({ target in
            actions(forTarget: target, forControlEvent: .valueChanged)?.forEach({
                (target as NSObject).perform(Selector($0))
            })
        })
    }
}

private extension NewsImageCell {
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
}

private extension NewsViewController {
    func simulateUserInitiatedFeedReload() {
        refreshControl?.simulatePullToRefresh()
    }
    
    var isShowingLoadingIndicator: Bool {
        refreshControl?.isRefreshing == true
    }
    
    func simulateNewsImageViewNotVisibile(at row: Int) {
        let view = simulateNewsImageViewVisible(at: row)
        let dl = tableView.delegate
        let index = IndexPath(row: row, section: newsSection)
        dl?.tableView?(tableView, didEndDisplaying: view!, forRowAt: index)
    }
    
    @discardableResult
    func simulateNewsImageViewVisible(at row: Int) -> NewsImageCell? {
        return newsImageView(at: row) as? NewsImageCell
    }
    
    func newsImageView(at row: Int) -> UITableViewCell? {
        let ds = tableView.dataSource
        let index = IndexPath(row: row, section: newsSection)
        return ds?.tableView(tableView, cellForRowAt: index)
    }

    func numberOfRenderedNewsImageViews() -> Int {
        tableView.numberOfRows(inSection: newsSection)
    }
    
    private var newsSection: Int { 0 }
}

private extension NewsViewController {
    
    func simulateAppearance() {
        if !isViewLoaded {
            loadViewIfNeeded()
            prepareForFirstAppearance()
        }
        
        beginAppearanceTransition(true, animated: false)
        endAppearanceTransition()
    }
    
    private func prepareForFirstAppearance() {
        setSmallFrameToPreventRenderingCells()
        replaceRefreshControlWithFakeForiOS17PlusSupport()
    }
    
    private func setSmallFrameToPreventRenderingCells() {
        tableView.frame = .init(x: 0, y: 0, width: 390, height: 1)
    }
    
    private func replaceRefreshControlWithFakeForiOS17PlusSupport() {
        let fakeRefreshControl = FakeRefreshControl()
        
        refreshControl?.allTargets.forEach({ target in
            refreshControl?.actions(forTarget: target, forControlEvent: .valueChanged)?.forEach({ action in
                fakeRefreshControl.addTarget(target, action: Selector(action), for: .valueChanged)
            })
        })
        
        refreshControl = fakeRefreshControl
    }
    
    private class FakeRefreshControl: UIRefreshControl {
        private var _isRefreshing = false
        
        override var isRefreshing: Bool { _isRefreshing }
        
        override func beginRefreshing() {
            _isRefreshing = true
        }
        
        override func endRefreshing() {
            _isRefreshing = false
        }
    }
}

extension UIImage {
    static func make(withColor color: UIColor) -> UIImage {
        let rect = CGRect(x: 0, y: 0, width: 1, height: 1)
        let format = UIGraphicsImageRendererFormat()
        format.scale = 1
        
        return UIGraphicsImageRenderer(size: rect.size, format: format).image { rendererContext in
            color.setFill()
            rendererContext.fill(rect)
        }
    }
}

