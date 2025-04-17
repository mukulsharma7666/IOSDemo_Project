//
//  UIImageView+Extention.swift
//  IOSDemo
//
//  Created by Mukul Sharma on 17/04/25.
//

import Foundation
import UIKit

extension UIImageView {
    func loadImage(from urlString: String, placeholder: UIImage? = nil) {
        self.image = placeholder

        guard let url = URL(string: urlString) else { return }

        // Check if image is cached
        if let cached = ImageCache.shared.image(forKey: urlString) {
            self.image = cached
            return
        }

        // Otherwise download
        URLSession.shared.dataTask(with: url) { data, response, error in
            guard let data = data, let downloaded = UIImage(data: data) else { return }
            ImageCache.shared.setImage(downloaded, forKey: urlString)
            DispatchQueue.main.async {
                self.image = downloaded
            }
        }.resume()
    }
}

class ImageCache {
    static let shared = ImageCache()
    private init() {}

    private let cache = NSCache<NSString, UIImage>()

    func image(forKey key: String) -> UIImage? {
        cache.object(forKey: key as NSString)
    }

    func setImage(_ image: UIImage, forKey key: String) {
        cache.setObject(image, forKey: key as NSString)
    }
}
