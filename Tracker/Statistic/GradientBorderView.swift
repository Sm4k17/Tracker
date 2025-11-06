//
//  GradientBorderView.swift
//  Tracker
//
//  Created by Рустам Ханахмедов on 06.11.2025.
//

import UIKit

final class GradientBorderView: UIView {

    private let gradientLayer = CAGradientLayer()
    private let borderMask = CAShapeLayer()

    var gradientColors: [UIColor] = [.ypCellColorRed,.ypCellColorMint, .ypCellColorBlue] {
        didSet {
            updateGradientColors()
        }
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupGradientBorder()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupGradientBorder()
    }

    private func setupGradientBorder() {
        gradientLayer.startPoint = CGPoint(x: 0, y: 0.5)
        gradientLayer.endPoint = CGPoint(x: 1, y: 0.5)
        gradientLayer.cornerRadius = layer.cornerRadius
        gradientLayer.mask = borderMask
        layer.addSublayer(gradientLayer)
        updateGradientColors()
    }

    override func layoutSubviews() {
        super.layoutSubviews()

        gradientLayer.frame = bounds

        let path = UIBezierPath(roundedRect: bounds.insetBy(dx: 1, dy: 1), cornerRadius: layer.cornerRadius)
        borderMask.path = path.cgPath
        borderMask.lineWidth = 2
        borderMask.strokeColor = UIColor.black.cgColor
        borderMask.fillColor = nil
        borderMask.frame = bounds
    }

    private func updateGradientColors() {
        gradientLayer.colors = gradientColors.map { $0.cgColor }
    }
 }
