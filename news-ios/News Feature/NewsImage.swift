//
//  NewsImage.swift
//  news-ios
//
//  Created by Mohamed Ibrahim on 17/09/2024.
//

import Foundation

public struct NewsImage: Equatable {
    let id: UUID
    let title: String
    let date: String
    let channel: String
    let url: URL
}
