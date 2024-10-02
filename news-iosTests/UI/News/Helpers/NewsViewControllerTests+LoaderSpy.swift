//
//  NewsViewControllerTests+LoaderSpy.swift
//  news-iosTests
//
//  Created by Mohamed Ibrahim on 02/10/2024.
//

import Foundation
import news_ios

extension NewsViewControllerTests {
    
    class LoaderSpy: NewsLoader, NewsImageDataLoader {
        
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
