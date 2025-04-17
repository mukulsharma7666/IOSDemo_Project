//
//  ProductCell.swift
//  IOSDemo
//
//  Created by Mukul Sharma on 17/04/25.
//

import Foundation
import UIKit

class ProductCell: UITableViewCell {
    static let identifier = "ProductCell"

    let productImageView = UIImageView()
    let nameLabel = UILabel()
    let priceLabel = UILabel()
    let favoriteButton = UIButton(type: .system)
    let cartButton = UIButton(type: .system)

    var onFavoriteToggle: (() -> Void)?
    var onAddToCartTapped: (() -> Void)?

    private var isInCart = false

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupViews()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupViews()
    }

    private func setupViews() {
        productImageView.translatesAutoresizingMaskIntoConstraints = false
        nameLabel.translatesAutoresizingMaskIntoConstraints = false
        priceLabel.translatesAutoresizingMaskIntoConstraints = false
        favoriteButton.translatesAutoresizingMaskIntoConstraints = false
        cartButton.translatesAutoresizingMaskIntoConstraints = false

        nameLabel.numberOfLines = 4
        priceLabel.textColor = .systemGreen
        priceLabel.font = UIFont.boldSystemFont(ofSize: 16)

        productImageView.contentMode = .scaleAspectFit
        productImageView.layer.cornerRadius = 16
        productImageView.clipsToBounds = true

        cartButton.setTitle("Add to Cart", for: .normal)
        cartButton.setTitleColor(.white, for: .normal)
        cartButton.backgroundColor = .systemBlue
        cartButton.layer.cornerRadius = 6
        cartButton.titleLabel?.font = UIFont.systemFont(ofSize: 14, weight: .medium)

        contentView.addSubview(productImageView)
        contentView.addSubview(nameLabel)
        contentView.addSubview(priceLabel)
        contentView.addSubview(favoriteButton)
        contentView.addSubview(cartButton)

        contentView.backgroundColor = UIColor.systemGray6
        selectionStyle = .none
        contentView.layer.cornerRadius = 12
        contentView.layer.masksToBounds = true

        NSLayoutConstraint.activate([
            productImageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            productImageView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 16),
            productImageView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -16),
            productImageView.widthAnchor.constraint(equalToConstant: 150),
            productImageView.heightAnchor.constraint(equalToConstant: 250),

            nameLabel.leadingAnchor.constraint(equalTo: productImageView.trailingAnchor, constant: 16),
            nameLabel.topAnchor.constraint(equalTo: productImageView.topAnchor, constant:  5),
            nameLabel.trailingAnchor.constraint(lessThanOrEqualTo: favoriteButton.leadingAnchor, constant: -8),

            priceLabel.leadingAnchor.constraint(equalTo: nameLabel.leadingAnchor),
            priceLabel.topAnchor.constraint(equalTo: nameLabel.bottomAnchor, constant: 4),
            priceLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),

            favoriteButton.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            favoriteButton.topAnchor.constraint(equalTo: productImageView.topAnchor),
            favoriteButton.widthAnchor.constraint(equalToConstant: 40),
            favoriteButton.heightAnchor.constraint(equalToConstant: 40),

            cartButton.leadingAnchor.constraint(equalTo: nameLabel.leadingAnchor),
            cartButton.topAnchor.constraint(equalTo: priceLabel.bottomAnchor, constant: 16),
            cartButton.trailingAnchor.constraint(lessThanOrEqualTo: contentView.trailingAnchor, constant: -16),
            cartButton.heightAnchor.constraint(equalToConstant: 40),
            cartButton.widthAnchor.constraint(equalToConstant: 120)
        ])

        favoriteButton.addTarget(self, action: #selector(toggleFavorite), for: .touchUpInside)
        cartButton.addTarget(self, action: #selector(handleCartTap), for: .touchUpInside)
    }

    @objc private func toggleFavorite() {
        onFavoriteToggle?()
    }

    @objc private func handleCartTap() {
        isInCart.toggle()
        updateCartButton()
        onAddToCartTapped?()
    }

    private func updateCartButton() {
        let title = isInCart ? "Go to Cart" : "Add to Cart"
        cartButton.setTitle(title, for: .normal)
        cartButton.backgroundColor = isInCart ? .systemGreen : .systemBlue
    }

    func configure(with product: Product, isFavorite: Bool, isInCart: Bool = false) {
        nameLabel.text = product.name
        priceLabel.text = "$"+product.price // You can format this as needed
        productImageView.loadImage(from: product.imageName)
        favoriteButton.setTitle(isFavorite ? "❤️" : "🤍", for: .normal)
        self.isInCart = isInCart
        updateCartButton()
    }
}
