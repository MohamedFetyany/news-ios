//
//  NewsViewController.swift
//  news-ios
//
//  Created by Mohamed Ibrahim on 25/09/2024.
//

import UIKit

public final class NewsViewController: UITableViewController, UITableViewDataSourcePrefetching {
    
    private var tableModel = [NewsImage]() {
        didSet { tableView.reloadData() }
    }
    
    private var cellControllers = [IndexPath: NewImageCellController]()
    
    private var onViewIsAppearing: ((NewsViewController) -> Void)?
    
    private var imageLoader: NewsImageDataLoader?
    
    public var refreshController: NewsRefreshViewController?
    
    public convenience init(newsLoader: NewsLoader, imageLoader: NewsImageDataLoader) {
        self.init()
        self.refreshController = NewsRefreshViewController(newsLoader: newsLoader)
        self.imageLoader = imageLoader
    }
    
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.prefetchDataSource = self
        
        refreshControl = refreshController?.view
        refreshController?.onRefresh = { [weak self] news in
            self?.tableModel = news
        }
        
        onViewIsAppearing = { vc in
            vc.onViewIsAppearing = nil
            vc.refreshController?.load()
        }
    }
    
    public override func viewIsAppearing(_ animated: Bool) {
        super.viewIsAppearing(animated)
        
        onViewIsAppearing?(self)
    }
    
    public override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        tableModel.count
    }
    
    public override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        cellController(forRowAt: indexPath).view()
    }
    
    public override func tableView(_ tableView: UITableView, didEndDisplaying cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        removeCellController(forRowAt: indexPath)
    }
    
    public func tableView(_ tableView: UITableView, prefetchRowsAt indexPaths: [IndexPath]) {
        indexPaths.forEach { indexPath in
            cellController(forRowAt: indexPath).preloadImage()
        }
    }
    
    public func tableView(_ tableView: UITableView, cancelPrefetchingForRowsAt indexPaths: [IndexPath]) {
        indexPaths.forEach(removeCellController)
    }
    
    private func cellController(forRowAt indexPath: IndexPath) -> NewImageCellController {
        let cellModel = tableModel[indexPath.row]
        let controller = NewImageCellController(model: cellModel,imageLoader: imageLoader!)
        cellControllers[indexPath] = controller
        return controller
    }
    
    private func removeCellController(forRowAt indexPath: IndexPath) {
        cellControllers[indexPath] = nil
    }
}
