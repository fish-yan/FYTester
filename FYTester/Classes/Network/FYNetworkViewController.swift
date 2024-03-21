//
//  FYNetworkViewController.swift
//  FYTester
//
//  Created by 薛焱 on 2022/4/12.
//

import UIKit

class FYNetworkViewController: UIViewController {
    private lazy var tableView: UITableView = {
        let tableView = UITableView(frame: view.bounds)
        tableView.dataSource = self
        tableView.delegate = self
        tableView.tableFooterView = UIView()
        tableView.register(FYNetworkCell.self, forCellReuseIdentifier: "FYNetworkCell")
        return tableView
    }()
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "网络"
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Clean", style: .plain, target: self, action: #selector(cleanAction))
        view.backgroundColor = .white
        view.addSubview(tableView)
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        tableView.frame = view.bounds
    }

    @objc func cleanAction() {
        FYTester.share.network.networks = []
        tableView.reloadData()
    }
}

extension FYNetworkViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return FYTester.share.network.networks.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "FYNetworkCell", for: indexPath) as! FYNetworkCell
        let net = FYTester.share.network.networks[indexPath.row]
        cell.updateUI(net)
        return cell
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 139
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let vc = FYNetworkResponseViewController()
        let net = FYTester.share.network.networks[indexPath.row]
        vc.response = net.response
        FYTester.share.tool.nav?.pushViewController(vc, animated: true)
    }
}
