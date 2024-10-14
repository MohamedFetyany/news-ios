//
//  NewsViewController.swift
//  news-ios
//
//  Created by Mohamed Ibrahim on 25/09/2024.
//

import UIKit

protocol NewsViewControllerDelegate {
    func didRequestNewsRefresh()
}

public final class NewsViewController: UITableViewController, UITableViewDataSourcePrefetching, NewsLoadingView {
    
    var tableModel = [NewImageCellController]() {
        didSet { tableView.reloadData() }
    }
    
    private var onViewIsAppearing: ((NewsViewController) -> Void)?
        
    var delegate: NewsViewControllerDelegate?
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        
        onViewIsAppearing = { vc in
            vc.onViewIsAppearing = nil
            vc.load()
        }
    }
    
    public override func viewIsAppearing(_ animated: Bool) {
        super.viewIsAppearing(animated)
        
        onViewIsAppearing?(self)
    }
    
    @IBAction private func load() {
        delegate?.didRequestNewsRefresh()
    }
    
    func display(_ viewModel: NewsLoadingViewModel) {
        if viewModel.isLoading {
            refreshControl?.beginRefreshing()
        } else {
            refreshControl?.endRefreshing()
        }
    }
    
    public override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        tableModel.count
    }
    
    public override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        cellController(forRowAt: indexPath).view(in: tableView)
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
        return tableModel[indexPath.row]
    }
    
    private func removeCellController(forRowAt indexPath: IndexPath) {
        tableModel[indexPath.row].cancelLoad()
    }
}
