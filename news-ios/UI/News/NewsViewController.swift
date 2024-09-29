//
//  NewsViewController.swift
//  news-ios
//
//  Created by Mohamed Ibrahim on 25/09/2024.
//

import UIKit

public protocol NewsImageDataLoader {
    func loadImageData(from url: URL)
}

public final class NewsViewController: UITableViewController {
    
    private var tableModel = [NewsImage]()
    
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
        imageLoader?.loadImageData(from: cellModel.url)
        return cell
    }
}

