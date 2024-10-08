//
//  NewsViewModel.swift
//  news-ios
//
//  Created by Mohamed Ibrahim on 08/10/2024.
//

import Foundation

final class NewsViewModel {
    typealias Observer<T> = (T) -> Void
    
    private let loader: NewsLoader
    
    init(loader: NewsLoader) {
        self.loader = loader
    }
    
    var onLoadingStateChange: Observer<Bool>?
    var onNewsLoad: Observer<[NewsImage]>?
    
    func loadNews() {
        onLoadingStateChange?(true)
        loader.load { [weak self] result in
            if let news = try? result.get() {
                self?.onNewsLoad?(news)
            }
            self?.onLoadingStateChange?(false)
        }
    }
}
