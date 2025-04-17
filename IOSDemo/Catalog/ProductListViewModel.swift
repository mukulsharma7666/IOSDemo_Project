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

class ProductListViewModel {
    private(set) var allProducts: [Product] = []
    private(set) var filteredProducts: [Product] = []
    private(set) var currentFilter: FilterType = .all
    var onDataUpdate: (() -> Void)?

    init() {
        // Simulate loading delay
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            self.loadMockProducts()
        }
    }

    func loadMockProducts() {
        allProducts = (1...120).map {
            Product(id: $0, name: "Men Campus Mike lace-up Running Shoes \($0)", imageName: "https://encrypted-tbn1.gstatic.com/shopping?q=tbn:ANd9GcQb0qTbT-R7xXrtv2O73Q3_QoSgEs7udZCNAp6coYvmDsxWMOIWf-Wg9BHvMMym6GEcHwACTlXi2cyIREmlIxXFHjgyxf2sMxTiHUMaE0_WfIflDLLCzz_S", price: "\($0+5)")
        }
        applyFilter(.all)
    }

    func applyFilter(_ type: FilterType) {
        currentFilter = type
        let favs = FavoritesManager.shared.getFavorites()

        switch type {
        case .all:
            filteredProducts = allProducts
        case .favorites:
            filteredProducts = allProducts.filter { favs.contains($0.id) }
        case .unfavorites:
            filteredProducts = allProducts.filter { !favs.contains($0.id) }
        }

        onDataUpdate?()
    }

    func toggleFavorite(product: Product) {
        FavoritesManager.shared.toggleFavorite(id: product.id)
        applyFilter(currentFilter)
    }

    func isFavorite(product: Product) -> Bool {
        FavoritesManager.shared.isFavorite(id: product.id)
    }
}
