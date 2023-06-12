//
//  FYTesterToolViewController.swift
//  FYTester
//
//  Created by 薛焱 on 2022/4/3.
//

import UIKit
public protocol FYToolDelegate: NSObjectProtocol {
    func toolDidSelected(_ indexPath: IndexPath, title: String)
}

extension FYToolDelegate {
    func toolDidSelected(_ indexPath: IndexPath, title: String) { }
}

class FYToolViewController: UIViewController {

    private lazy var colletionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        let colletionView = UICollectionView(frame: view.bounds, collectionViewLayout: layout)
        colletionView.backgroundColor = UIColor(white: 0.9, alpha: 1)
        colletionView.delegate = self
        colletionView.dataSource = self
        colletionView.register(FYToolCell.self, forCellWithReuseIdentifier: "ToolCell")
        colletionView.register(FYToolHeaderView.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: "ToolHeaderView")
        colletionView.layer.borderWidth = 1
        colletionView.layer.borderColor = UIColor(white: 0.9, alpha: 1).cgColor
        return colletionView
    }()

    private var data: [FYToolSection] {
        return [
            FYToolSection(title: "环境配置", items: FYTester.share.tool.envs.map({$0.rawValue})),
            FYToolSection(title: "常用功能", items: FYTester.share.tool.commons),
            FYToolSection(title: "插件功能", items: FYTester.share.tool.plugins),
            FYToolSection(title: "其他功能", items: FYTester.share.tool.others),
        ]
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "工具箱"
        view.backgroundColor = .white
        let left = UIBarButtonItem(title: "关闭", style: .plain, target: self, action: #selector(backAction))
        left.tintColor = UIColor.darkText
        navigationItem.leftBarButtonItem = left
        view.addSubview(colletionView)
        colletionView.frame = view.bounds
    }
    
    @objc func backAction() {
        FYTester.share.tool.dismiss()
    }
}

extension FYToolViewController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {

    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return data.count
    }

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        let sectionModel = data[section]
        return sectionModel.items.count
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width = (UIScreen.main.bounds.size.width - 5) / 4
        var height = width
        if data[indexPath.section].title == "环境配置" {
            height = 40
        }
        return CGSize(width: width, height: height)
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 1, left: 1, bottom: 1, right: 1)
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 1
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 1
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ToolCell", for: indexPath) as! FYToolCell
        let sectionModel = data[indexPath.section]
        if sectionModel.title == "环境配置",
           let env = Env(rawValue: sectionModel.items[indexPath.row]),
           env == FYTester.share.tool.env {
            cell.titleLabel.backgroundColor = FYTester.share.tool.env.color
            cell.titleLabel.textColor = .white
        } else {
            cell.titleLabel.backgroundColor = .white
            cell.titleLabel.textColor = UIColor(white: 0.2, alpha: 1)
        }
        cell.titleLabel.text = sectionModel.items[indexPath.row]
        return cell
    }

    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        let headerView = collectionView.dequeueReusableSupplementaryView(ofKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: "ToolHeaderView", for: indexPath) as! FYToolHeaderView
        headerView.titleLabel.text = data[indexPath.section].title
        return headerView
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        return CGSize(width: UIScreen.main.bounds.width, height: 50)
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let sectionModel = data[indexPath.section]
        let title = sectionModel.items[indexPath.row]
        if sectionModel.title == "环境配置" {
            if let env = Env(rawValue: title),
               env != FYTester.share.tool.env {
                FYTester.share.tool.env = env
                collectionView.reloadData()
                FYTester.share.tool.delegate?.toolDidSelected(indexPath, title: title)
            }
        } else {
            switch title {
            case "系统信息":
                FYTester.share.tool.nav?.pushViewController(FYSystemInfoController(), animated: true)
            case "网络监控":
                FYTester.share.tool.nav?.pushViewController(FYNetworkViewController(), animated: true)
            default: break
            }
            FYTester.share.tool.delegate?.toolDidSelected(indexPath, title: title)
        }
    }
}


private struct FYToolSection {
    var title = ""
    var items = [String]()
}
