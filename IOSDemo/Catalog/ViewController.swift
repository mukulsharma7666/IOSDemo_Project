//
//  ViewController.swift
//  IOSDemo
//
//  Created by Mukul Sharma on 17/04/25.
//

import UIKit

class ViewController: UIViewController {
    private let tableView = UITableView()
    private let viewModel = ProductViewModel()
    private let shimmerView = UIActivityIndicatorView(style: .large)
    private var filterState: ProductViewModel.FilterType = .all
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupBindings()
        
        shimmerView.startAnimating()
        viewModel.loadInitialData()
    }
    
    private func setupUI() {
        title = "Products"
        view.backgroundColor = .white
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(
            title: "Filter", style: .plain,
            target: self, action: #selector(toggleFilter)
        )
        
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.register(ProductCell.self, forCellReuseIdentifier: ProductCell.identifier)
        tableView.dataSource = self
        tableView.delegate = self
        tableView.separatorStyle = .none
        tableView.backgroundColor = .white
        
        view.addSubview(tableView)
        view.addSubview(shimmerView)
        
        shimmerView.center = view.center
        
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 12),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -12)
        ])
    }
    
    private func setupBindings() {
        viewModel.onProductsUpdated = { [weak self] in
            DispatchQueue.main.async {
                self?.shimmerView.stopAnimating()
                self?.tableView.reloadData()
            }
        }
    }
    
    
    @objc private func toggleFilter() {
        navigationItem.rightBarButtonItem = UIBarButtonItem(
            title: "Filter",
            style: .plain,
            target: self,
            action: #selector(showFilterOptions)
        )
    }
    
    @objc private func showFilterOptions() {
        let alert = UIAlertController(title: "Filter", message: nil, preferredStyle: .actionSheet)
        alert.addAction(UIAlertAction(title: "All", style: .default) { _ in
            self.viewModel.applyFilter(.all)
        })
        alert.addAction(UIAlertAction(title: "Favorites", style: .default) { _ in
            self.viewModel.applyFilter(.favorites)
        })
        alert.addAction(UIAlertAction(title: "Unfavorites", style: .default) { _ in
            self.viewModel.applyFilter(.unfavorites)
        })
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        present(alert, animated: true)
    }
}

extension ViewController: UITableViewDataSource, UITableViewDelegate {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return viewModel.filteredProducts.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int { return 1 }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat { return 200 }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat { return 12 }
    
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        let view = UIView()
        view.backgroundColor = .clear
        return view
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        guard let cell = tableView.dequeueReusableCell(withIdentifier: ProductCell.identifier, for: indexPath) as? ProductCell else {
            return UITableViewCell()
        }
        
        let product = viewModel.filteredProducts[indexPath.section]
        cell.configure(with: product, isFavorite: product.isFavorite)
        
        cell.onFavoriteToggle = { [weak self] in
            self?.viewModel.toggleFavorite(at: indexPath.section)
        }
        
        cell.onAddToCartTapped = {
            print("Add to cart tapped for: \(product.name)")
        }
        
        return cell
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let offsetY = scrollView.contentOffset.y
        let contentHeight = scrollView.contentSize.height
        
        if offsetY > contentHeight - scrollView.frame.size.height * 1.5 {
            viewModel.paginate()
        }
    }
}
