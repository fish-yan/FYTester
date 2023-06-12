//
//  FYNetworkCell.swift
//  FYTester
//
//  Created by 薛焱 on 2022/4/12.
//

import UIKit

class FYNetworkCell: UITableViewCell {
    private lazy var methodLab: UILabel = {
        let lab = UILabel()
        lab.font = UIFont.systemFont(ofSize: 12)
        lab.textColor = UIColor(white: 0.2, alpha: 1)
        return lab
    }()
    private lazy var pathLab: UITextView = {
        let tv = UITextView()
        tv.font = UIFont.systemFont(ofSize: 12)
        tv.textColor = UIColor(white: 0.2, alpha: 1)
        tv.isScrollEnabled  = false
        tv.isEditable = false
        tv.isUserInteractionEnabled = false
        tv.textContainerInset = .zero
        tv.textContainer.lineFragmentPadding = 0
        tv.dataDetectorTypes = .link
        tv.backgroundColor = .clear
        return tv
    }()
    private lazy var timeLab: UILabel = {
        let lab = UILabel()
        lab.font = UIFont.systemFont(ofSize: 12)
        lab.textColor = UIColor(white: 0.2, alpha: 1)
        return lab
    }()
    private lazy var copyBtn: UIButton = {
        let btn = UIButton(type: .system)
        btn.titleLabel?.font = UIFont.systemFont(ofSize: 14)
        btn.setTitle("copy curl", for: .normal)
        btn.addTarget(self, action: #selector(copyCurl), for: .touchUpInside)
        return btn
    }()

    private lazy var model = FYNetwork.NetworkModel()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupUI()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func setupUI() {
        accessoryType = .disclosureIndicator
        contentView.addSubview(methodLab)
        contentView.addSubview(pathLab)
        contentView.addSubview(timeLab)
        contentView.addSubview(copyBtn)
        methodLab.frame = CGRect(x: 12, y: 12, width: UIScreen.main.bounds.width - 24, height: 20)
        pathLab.frame = CGRect(x: 12, y: 37, width: UIScreen.main.bounds.width - 24, height: 40)
        timeLab.frame = CGRect(x: 12, y: 82, width: UIScreen.main.bounds.width - 24, height: 20)
        copyBtn.frame = CGRect(x: 12, y: 107, width: 60, height: 20)
    }

    func updateUI(_ network: FYNetwork.NetworkModel) {
        model = network
        methodLab.text = "Method： \(network.method ?? "")"
        pathLab.text = "Path： \(network.url ?? "")"
        timeLab.text = "Duration： \(network.duration)ms"
    }

    @objc func copyCurl() {
        UIPasteboard.general.string = model.curl
    }

}
