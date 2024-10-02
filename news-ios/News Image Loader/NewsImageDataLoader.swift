//
//  NewsImageDataLoader.swift
//  news-ios
//
//  Created by Mohamed Ibrahim on 02/10/2024.
//

import Foundation

public protocol NewsImageDataLoaderTask {
    func cancel()
}

public protocol NewsImageDataLoader {
    typealias Result = Swift.Result<Data, Error>
    
    func loadImageData(from url: URL, completion: @escaping ((Result) -> Void)) -> NewsImageDataLoaderTask
}
