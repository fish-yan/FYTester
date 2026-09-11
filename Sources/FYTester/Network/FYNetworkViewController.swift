//
//  FYNetworkViewController.swift
//  FYTester
//
//  Created by 薛焱 on 2022/4/12.
//

import UIKit

class FYNetworkViewController: UIViewController {
    private lazy var searchBar: UISearchBar = {
        let searchBar = UISearchBar(frame: CGRect(x: 0, y: 0, width: view.bounds.width, height: 56))
        searchBar.delegate = self
        searchBar.placeholder = "搜索 URL"
        searchBar.autocapitalizationType = .none
        searchBar.autocorrectionType = .no
        return searchBar
    }()

    private lazy var tableView: UITableView = {
        let tableView = UITableView(frame: view.bounds)
        tableView.dataSource = self
        tableView.delegate = self
        tableView.tableHeaderView = searchBar
        tableView.tableFooterView = UIView()
        tableView.keyboardDismissMode = .onDrag
        tableView.register(FYNetworkCell.self, forCellReuseIdentifier: "FYNetworkCell")
        return tableView
    }()
    
    private var filteredNetworks = [FYNetwork.NetworkModel]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "网络"
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Clean", style: .plain, target: self, action: #selector(cleanAction))
        view.backgroundColor = .white
        view.addSubview(tableView)
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        filterNetworks()
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        tableView.frame = view.bounds
    }

    @objc func cleanAction() {
        FYTester.share.network.networks = []
        filterNetworks()
    }

    private func filterNetworks() {
        let query = (searchBar.text ?? "").trimmingCharacters(in: .whitespacesAndNewlines)
        let networks = FYTester.share.network.networks
        if query.isEmpty {
            filteredNetworks = networks
        } else {
            filteredNetworks = networks.filter {
                $0.url?.range(of: query, options: .caseInsensitive) != nil
            }
        }
        tableView.reloadData()
    }
}

extension FYNetworkViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return filteredNetworks.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "FYNetworkCell", for: indexPath) as! FYNetworkCell
        let net = filteredNetworks[indexPath.row]
        cell.updateUI(net)
        return cell
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 139
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let vc = FYNetworkResponseViewController()
        let net = filteredNetworks[indexPath.row]
        vc.response = net.response
        FYTester.share.tool.nav?.pushViewController(vc, animated: true)
    }
}

extension FYNetworkViewController: UISearchBarDelegate {
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        filterNetworks()
    }

    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
    }
}
