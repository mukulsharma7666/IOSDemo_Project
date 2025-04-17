//
//  ProductViewController.swift
//  IOSDemo
//
//  Created by Mukul Sharma on 17/04/25.
//

import UIKit

class ProductViewController: UIViewController {
    private let tableView = UITableView()
    private let viewModel = ProductViewModel()
    private let shimmerView = UIActivityIndicatorView(style: .large)
    private let emptyStateView = UIView()
    private let refreshControl = UIRefreshControl()
    private var filterState: ProductViewModel.FilterType = .all
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupBindings()
        setupEmptyState()
        
        shimmerView.startAnimating()
        viewModel.loadInitialData()
    }
    
    private func setupUI() {
        title = "Products"
        view.backgroundColor = .white
        
        setupNavigationBar()
        setupTableView()
        setupRefreshControl()
    }
    
    private func setupNavigationBar() {
        navigationController?.navigationBar.prefersLargeTitles = true
        navigationItem.rightBarButtonItem = UIBarButtonItem(
            title: "Filter",
            style: .plain,
            target: self,
            action: #selector(toggleFilter)
        )
    }
    
    private func setupTableView() {
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.register(ProductCell.self, forCellReuseIdentifier: ProductCell.identifier)
        tableView.dataSource = self
        tableView.delegate = self
        tableView.separatorStyle = .none
        tableView.backgroundColor = .white
        tableView.refreshControl = refreshControl
        
        view.addSubview(tableView)
        view.addSubview(shimmerView)
        
        shimmerView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 12),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -12),
            
            shimmerView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            shimmerView.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
    }
    
    private func setupRefreshControl() {
        refreshControl.addTarget(self, action: #selector(refreshData), for: .valueChanged)
    }
    
    private func setupEmptyState() {
        emptyStateView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(emptyStateView)
        emptyStateView.isHidden = true
        
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.spacing = 16
        stackView.alignment = .center
        stackView.translatesAutoresizingMaskIntoConstraints = false
        
        let imageView = UIImageView(image: UIImage(systemName: "doc.text.magnifyingglass"))
        imageView.tintColor = .systemGray
        imageView.contentMode = .scaleAspectFit
        
        let label = UILabel()
        label.text = "No products found"
        label.textColor = .systemGray
        label.font = .systemFont(ofSize: 17, weight: .medium)
        
        stackView.addArrangedSubview(imageView)
        stackView.addArrangedSubview(label)
        emptyStateView.addSubview(stackView)
        
        NSLayoutConstraint.activate([
            emptyStateView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            emptyStateView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            stackView.centerXAnchor.constraint(equalTo: emptyStateView.centerXAnchor),
            stackView.centerYAnchor.constraint(equalTo: emptyStateView.centerYAnchor),
            imageView.heightAnchor.constraint(equalToConstant: 60),
            imageView.widthAnchor.constraint(equalToConstant: 60)
        ])
    }
    
    private func setupBindings() {
        viewModel.onProductsUpdated = { [weak self] in
            DispatchQueue.main.async {
                self?.handleDataUpdate()
            }
        }
    }
    
    private func handleDataUpdate() {
        shimmerView.stopAnimating()
        refreshControl.endRefreshing()
        
        if viewModel.filteredProducts.isEmpty {
            tableView.isHidden = true
            emptyStateView.isHidden = false
        } else {
            tableView.isHidden = false
            emptyStateView.isHidden = true
            tableView.reloadData()
        }
    }
    
    private func showError(_ error: Error) {
        let alert = UIAlertController(
            title: "Error",
            message: error.localizedDescription,
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
    
    @objc private func refreshData() {
        viewModel.loadInitialData()
    }
    
    @objc private func toggleFilter() {
        let alert = UIAlertController(title: "Filter", message: nil, preferredStyle: .actionSheet)
        
        let actions: [(String, ProductViewModel.FilterType)] = [
            ("All", .all),
            ("Favorites", .favorites),
            ("Unfavorites", .unfavorites)
        ]
        
        actions.forEach { title, filterType in
            alert.addAction(UIAlertAction(title: title, style: .default) { [weak self] _ in
                self?.viewModel.applyFilter(filterType)
            })
        }
        
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        present(alert, animated: true)
    }
}

extension ProductViewController: UITableViewDataSource, UITableViewDelegate {
    func numberOfSections(in tableView: UITableView) -> Int {
        return viewModel.filteredProducts.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 200
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 12
    }
    
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
        
        cell.onAddToCartTapped = { [weak self] in
            self?.handleAddToCart(product)
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let product = viewModel.filteredProducts[indexPath.section]
        handleProductSelection(product)
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let offsetY = scrollView.contentOffset.y
        let contentHeight = scrollView.contentSize.height
        let threshold = scrollView.frame.size.height * 1.5
        
        if offsetY > contentHeight - threshold {
            viewModel.paginate()
        }
    }
    
    private func handleAddToCart(_ product: Product) {
        // Show confirmation toast or animation
        let feedback = UINotificationFeedbackGenerator()
        feedback.notificationOccurred(.success)
        
        // You can add your cart logic here
        print("Add to cart tapped for: \(product.name)")
    }
    
    private func handleProductSelection(_ product: Product) {
        // Navigate to product detail
        // let detailVC = ProductDetailViewController(product: product)
        // navigationController?.pushViewController(detailVC, animated: true)
    }
}
