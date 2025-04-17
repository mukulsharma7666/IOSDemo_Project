//
//  FavoritesManager.swift
//  IOSDemo
//
//  Created by Mukul Sharma on 17/04/25.
//

import Foundation

class FavoritesManager {
    private let key = "favoriteProductIDs"
    
    static let shared = FavoritesManager()
    
    private init() {}
    
    func isFavorite(id: Int) -> Bool {
        return getFavorites().contains(id)
    }
    
    func toggleFavorite(id: Int) {
        var favorites = getFavorites()
        if let index = favorites.firstIndex(of: id) {
            favorites.remove(at: index)
        } else {
            favorites.append(id)
        }
        UserDefaults.standard.set(favorites, forKey: key)
    }
    
    func getFavorites() -> [Int] {
        return UserDefaults.standard.array(forKey: key) as? [Int] ?? []
    }
}
