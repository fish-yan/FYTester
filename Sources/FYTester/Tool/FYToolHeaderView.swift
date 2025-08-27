//
//  FYToolHeaderView.swift
//  FYTester
//
//  Created by 薛焱 on 2022/4/12.
//

import UIKit

class FYToolHeaderView: UICollectionReusableView {
    lazy var titleLabel: UILabel = {
        let lab = UILabel(frame: CGRect(x: 12, y: 0, width: bounds.width - 24, height: bounds.height))
        lab.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        lab.textColor = UIColor(white: 0.2, alpha: 1)
        return lab
    }()
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

private extension FYToolHeaderView {
    func setupUI() {
        backgroundColor = .white
        addSubview(titleLabel)
    }
}
