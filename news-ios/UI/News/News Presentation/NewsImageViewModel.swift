//
//  NewsImageViewModel.swift
//  news-ios
//
//  Created by Mohamed Ibrahim on 13/10/2024.
//

import Foundation

struct NewsImageViewModel<Image> {
    let title: String
    let date: String
    let channel: String
    let image: Image?
    let isLoading: Bool
    let shouldRetry: Bool
}
