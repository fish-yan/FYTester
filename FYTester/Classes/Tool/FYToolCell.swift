//
//  ToolCell.swift
//  FYTester
//
//  Created by 薛焱 on 2022/4/8.
//

import UIKit

class FYToolCell: UICollectionViewCell {
    lazy var titleLabel: UILabel = {
        let lab = UILabel(frame: bounds)
        lab.font = UIFont.systemFont(ofSize: 14)
        lab.textColor = UIColor(white: 0.2, alpha: 1)
        lab.numberOfLines = 5
        lab.textAlignment = .center
        return lab
    }()
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        titleLabel.frame = bounds
    }
}

private extension FYToolCell {
    func setupUI() {
        backgroundColor = .white
        contentView.addSubview(titleLabel)
    }
}
