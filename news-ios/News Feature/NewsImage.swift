//
//  NewsImage.swift
//  news-ios
//
//  Created by Mohamed Ibrahim on 17/09/2024.
//

import Foundation

public struct NewsImage: Equatable {
    public let id: UUID
    public let title: String
    public let date: String
    public let channel: String
    public let url: URL
    
    public init(id: UUID, title: String, date: String, channel: String, url: URL) {
        self.id = id
        self.title = title
        self.date = date
        self.channel = channel
        self.url = url
    }
}
