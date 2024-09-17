//
//  NewsLoader.swift
//  news-ios
//
//  Created by Mohamed Ibrahim on 17/09/2024.
//

import Foundation

public protocol NewsLoader {
    typealias Result = Swift.Result<[NewsImage], Error>

    func load(completion: @escaping (Result) -> Void)
}
