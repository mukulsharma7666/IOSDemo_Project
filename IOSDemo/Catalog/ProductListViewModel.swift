//
//  ProductListViewModel.swift
//  IOSDemo
//
//  Created by Mukul Sharma on 17/04/25.
//

import Foundation

enum FilterType {
    case all
    case favorites
    case unfavorites
}

class ProductViewModel {
    private(set) var products: [Product] = []
    private(set) var filteredProducts: [Product] = []
    private var currentPage = 0
    private let pageSize = 20
    var isLoading = false

    var onProductsUpdated: (() -> Void)?

    enum FilterType {
        case all, favorites, unfavorites
    }

    private var currentFilter: FilterType = .all

    func loadInitialData() {
        products = (1...100).map {
            Product(id: $0, name: "Men Puma Softfoam Smashic Unisex Sneakers \($0)", imageName: "https://encrypted-tbn1.gstatic.com/shopping?q=tbn:ANd9GcQb0qTbT-R7xXrtv2O73Q3_QoSgEs7udZCNAp6coYvmDsxWMOIWf-Wg9BHvMMym6GEcHwACTlXi2cyIREmlIxXFHjgyxf2sMxTiHUMaE0_WfIflDLLCzz_S", price: "$\($0+5)", isFavorite: false)
        }
        paginate()
    }

    func paginate() {
        guard !isLoading else { return }
        isLoading = true

        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            let start = self.currentPage * self.pageSize
            let end = min(start + self.pageSize, self.products.count)
            guard start < end else { return }

            let newItems = Array(self.products[start..<end])
            if self.currentPage == 0 {
                self.filteredProducts = newItems
            } else {
                self.filteredProducts.append(contentsOf: newItems)
            }
            self.currentPage += 1
            self.isLoading = false
            self.onProductsUpdated?()
        }
    }

    func toggleFavorite(at index: Int) {
        let productId = filteredProducts[index].id
        if let originalIndex = products.firstIndex(where: { $0.id == productId }) {
            products[originalIndex].isFavorite.toggle()
            filteredProducts[index].isFavorite.toggle()
            onProductsUpdated?()
        }
    }

    func applyFilter(_ filter: FilterType) {
        currentPage = 0
        currentFilter = filter
        switch filter {
        case .all:
            filteredProducts = Array(products.prefix(pageSize))
        case .favorites:
            filteredProducts = products.filter { $0.isFavorite }
        case .unfavorites:
            filteredProducts = products.filter { !$0.isFavorite }
        }
        onProductsUpdated?()
    }

    func resetPagination() {
        currentPage = 0
        filteredProducts.removeAll()
        paginate()
    }
}
