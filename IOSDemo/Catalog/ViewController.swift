//
//  ViewController.swift
//  IOSDemo
//
//  Created by Mukul Sharma on 17/04/25.
//

import UIKit

//class ViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
//    private let tableView = UITableView()
//    private let viewModel = ProductListViewModel()
//    private var shimmerView: ShimmerView?
//
//    override func viewDidLoad() {
//        super.viewDidLoad()
//        title = "Products"
//        view.backgroundColor = .white
//        setupTableView()
//        setupFilterButton()
//
//        shimmerView = ShimmerView(frame: view.bounds)
//        view.addSubview(shimmerView!)
//
//        viewModel.onDataUpdate = { [weak self] in
//            self?.shimmerView?.removeFromSuperview()
//            self?.shimmerView = nil
//            self?.tableView.reloadData()
//        }
//    }
//
//    private func setupTableView() {
//        view.addSubview(tableView)
//        tableView.translatesAutoresizingMaskIntoConstraints = false
//        tableView.register(ProductCell.self, forCellReuseIdentifier: ProductCell.identifier)
//        tableView.dataSource = self
//        tableView.delegate = self
//        tableView.rowHeight = 232
//        tableView.backgroundColor = .white
//        tableView.separatorStyle = .none
//        NSLayoutConstraint.activate([
//            tableView.topAnchor.constraint(equalTo: view.topAnchor),
//            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
//            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant:  20),
//            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant:  -20)
//        ])
//    }
//
//    private func setupFilterButton() {
//        navigationItem.rightBarButtonItem = UIBarButtonItem(
//            title: "Filter",
//            style: .plain,
//            target: self,
//            action: #selector(showFilterOptions)
//        )
//    }
//
//    @objc private func showFilterOptions() {
//        let alert = UIAlertController(title: "Filter", message: nil, preferredStyle: .actionSheet)
//        alert.addAction(UIAlertAction(title: "All", style: .default) { _ in
//            self.viewModel.applyFilter(.all)
//        })
//        alert.addAction(UIAlertAction(title: "Favorites", style: .default) { _ in
//            self.viewModel.applyFilter(.favorites)
//        })
//        alert.addAction(UIAlertAction(title: "Unfavorites", style: .default) { _ in
//            self.viewModel.applyFilter(.unfavorites)
//        })
//        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
//        present(alert, animated: true)
//    }
//    
//    func numberOfSections(in tableView: UITableView) -> Int {
//        viewModel.filteredProducts.count
//    }
//
//    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
//        1
//    }
//
//    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
//        guard let cell = tableView.dequeueReusableCell(withIdentifier: ProductCell.identifier, for: indexPath) as? ProductCell else {
//            return UITableViewCell()
//        }
//
//        let product = viewModel.filteredProducts[indexPath.row]
//        cell.configure(with: product, isFavorite: viewModel.isFavorite(product: product))
//        cell.onFavoriteToggle = { [weak self] in
//            self?.viewModel.toggleFavorite(product: product)
//        }
//        return cell
//    }
//
////    func scrollViewDidScroll(_ scrollView: UIScrollView) {
////        let position = scrollView.contentOffset.y
////        let threshold = scrollView.contentSize.height - scrollView.frame.size.height - 100
////
//////        if position > threshold {
//////            viewModel.loadMoreProducts()
//////        }
////    }
//    
//    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
//        return 12 // Space between cells
//    }
//
//    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
//        let spacer = UIView()
//        spacer.backgroundColor = .clear
//        return spacer
//    }
//}

class ViewController: UIViewController {
    
    private let tableView = UITableView()
    private let shimmerView = ShimmerView()
    private let viewModel = ProductListViewModel()

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Catalog"
        view.backgroundColor = .white
        setupViews()
        setupShimmer()

        tableView.dataSource = self
        tableView.delegate = self
        tableView.register(ProductCell.self, forCellReuseIdentifier: ProductCell.identifier)

        viewModel.onDataUpdate = { [weak self] in
            self?.shimmerView.isHidden = true
            self?.tableView.isHidden = false
            self?.tableView.reloadData()
            self?.updateFilterTitle()
        }

        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "All", style: .plain, target: self, action: #selector(toggleFilter))
    }

    private func setupViews() {
        shimmerView.translatesAutoresizingMaskIntoConstraints = false
        shimmerView.startAnimating()
        view.addSubview(shimmerView)

        tableView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(tableView)
        tableView.isHidden = true

        NSLayoutConstraint.activate([
            shimmerView.topAnchor.constraint(equalTo: view.topAnchor),
            shimmerView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            shimmerView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            shimmerView.trailingAnchor.constraint(equalTo: view.trailingAnchor),

            tableView.topAnchor.constraint(equalTo: view.topAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor,constant: -20),
        ])
    }

    private func setupShimmer() {
        shimmerView.isHidden = false
    }

    @objc private func toggleFilter() {
        switch viewModel.currentFilter {
        case .all:
            viewModel.applyFilter(.favorites)
        case .favorites:
            viewModel.applyFilter(.unfavorites)
        case .unfavorites:
            viewModel.applyFilter(.all)
        }
        updateFilterTitle()
    }

    private func updateFilterTitle() {
        let title: String
        switch viewModel.currentFilter {
        case .all: title = "All"
        case .favorites: title = "❤️"
        case .unfavorites: title = "🤍"
        }
        navigationItem.rightBarButtonItem?.title = title
    }
}

extension ViewController: UITableViewDataSource, UITableViewDelegate {
    func numberOfSections(in tableView: UITableView) -> Int {
        viewModel.filteredProducts.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let product = viewModel.filteredProducts[indexPath.row]
        let cell = tableView.dequeueReusableCell(withIdentifier: ProductCell.identifier, for: indexPath) as! ProductCell
        cell.configure(with: product, isFavorite: viewModel.isFavorite(product: product))
        cell.onFavoriteToggle = { [weak self] in
            self?.viewModel.toggleFavorite(product: product)
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 12 // Space between cells
    }
    
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        let spacer = UIView()
        spacer.backgroundColor = .clear
        return spacer
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        200
    }
}
