//
//  NewsViewController.swift
//  news-ios
//
//  Created by Mohamed Ibrahim on 25/09/2024.
//

import UIKit

public protocol NewsImageDataLoaderTask {
    func cancel()
}

public protocol NewsImageDataLoader {
    typealias Result = Swift.Result<Data, Error>
    
    func loadImageData(from url: URL, completion: @escaping ((Result) -> Void)) -> NewsImageDataLoaderTask
}

public final class NewsViewController: UITableViewController, UITableViewDataSourcePrefetching {
    
    private var tableModel = [NewsImage]()
    private var tasks = [IndexPath: NewsImageDataLoaderTask]()
    
    private var onViewIsAppearing: ((NewsViewController) -> Void)?
    
    private var newsLoader: NewsLoader?
    private var imageLoader: NewsImageDataLoader?
    
    public convenience init(newsLoader: NewsLoader, imageLoader: NewsImageDataLoader) {
        self.init()
        self.newsLoader = newsLoader
        self.imageLoader = imageLoader
    }
    
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.prefetchDataSource = self
        refreshControl = UIRefreshControl()
        refreshControl?.addTarget(self, action: #selector(load), for: .valueChanged)
        
        onViewIsAppearing = { vc in
            vc.onViewIsAppearing = nil
            vc.load()
        }
    }
    
    public override func viewIsAppearing(_ animated: Bool) {
        super.viewIsAppearing(animated)
        
        onViewIsAppearing?(self)
    }
    
    @objc private func load() {
        refreshControl?.beginRefreshing()
        newsLoader?.load { [weak self] result in
            if let news = try? result.get() {
                self?.tableModel = news
                self?.tableView.reloadData()
            }
            self?.refreshControl?.endRefreshing()
        }
    }
    
    public override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        tableModel.count
    }
    
    public override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cellModel = tableModel[indexPath.row]
        let cell = NewsImageCell()
        cell.titleLabel.text = cellModel.title
        cell.dateLabel.text = cellModel.date
        cell.channelLabel.text = cellModel.channel
        cell.newsImageView.image = nil
        cell.newsRetryButton.isHidden = true
        cell.newsImageContainer.startShimmering()
        
        let loadImage = { [weak cell, weak self] in
            guard let self else { return }
            
            self.tasks[indexPath] = self.imageLoader?.loadImageData(from: cellModel.url) { [weak cell] result in
                let data = try? result.get()
                let image = data.map(UIImage.init) ?? nil
                cell?.newsImageView.image = image
                cell?.newsRetryButton.isHidden = image != nil
                cell?.newsImageContainer.stopShimmering()
            }
        }
        cell.onRetry = loadImage
        loadImage()
        return cell
    }
    
    public override func tableView(_ tableView: UITableView, didEndDisplaying cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        cancelTask(forRowAt: indexPath)
    }
    
    public func tableView(_ tableView: UITableView, prefetchRowsAt indexPaths: [IndexPath]) {
        indexPaths.forEach { indexPath in
            let cellModel = tableModel[indexPath.row]
            tasks[indexPath] = imageLoader?.loadImageData(from: cellModel.url) { _ in }
        }
    }
    
    public func tableView(_ tableView: UITableView, cancelPrefetchingForRowsAt indexPaths: [IndexPath]) {
        indexPaths.forEach(cancelTask)
    }
    
    private func cancelTask(forRowAt indexPath: IndexPath) {
        tasks[indexPath]?.cancel()
        tasks[indexPath] = nil
    }
}

