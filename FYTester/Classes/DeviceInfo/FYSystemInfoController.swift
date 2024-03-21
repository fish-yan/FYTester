//
//  FYSystemInfoController.swift
//  FYTester
//
//  Created by 薛焱 on 2022/4/4.
//

import UIKit

private class SystemInfoCell: UITableViewCell {
    private lazy var titleLabel: UILabel = {
        let l = UILabel()
        l.font = UIFont.systemFont(ofSize: 12)
        l.textColor = UIColor.black
        l.textAlignment = .left
        return l
    }()
    private lazy var subTitleLabel: UILabel = {
        let l = UILabel()
        l.font = UIFont.systemFont(ofSize: 12)
        l.textColor = UIColor.black
        l.textAlignment = .right
        return l
    }()
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupUI()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupUI() {
        contentView.addSubview(titleLabel)
        contentView.addSubview(subTitleLabel)
        let width = (UIScreen.main.bounds.width - 24) / 3
        titleLabel.frame = CGRect(x: 12, y: 0, width: width, height: bounds.height)
        subTitleLabel.frame = CGRect(x: width + 12, y: 0, width: width * 2, height: bounds.height)
    }

    func updateUI(data: (String, String)?) {
        titleLabel.text = data?.0
        subTitleLabel.text = data?.1
    }

}

class FYSystemInfoController: UIViewController {

    private var datas: [(String, String)] = []

    private lazy var tableView: UITableView = {
        let t = UITableView(frame: view.bounds)
        t.delegate = self
        t.dataSource = self
        t.tableFooterView = UIView()
        t.register(SystemInfoCell.self, forCellReuseIdentifier: "SystemInfoCell")
        return t
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        updateUI()
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        tableView.frame = view.bounds
    }

}


private extension FYSystemInfoController {
    func setupUI() {
        title = "系统信息"
        view.backgroundColor = UIColor.white
        view.addSubview(tableView)
    }

    func updateUI() {
        datas = createData()
        tableView.reloadData()
    }
}

private extension FYSystemInfoController {
    func createData() -> [(String, String)] {
        let datas: [(String, String)] = [
            ("设备名称", FYDeviceInfo.name),
            ("系统名称", FYDeviceInfo.systemName),
            ("系统版本号", FYDeviceInfo.systemVersion),
            ("设备机型标识符", FYDeviceInfo.deviceModel),
            ("CPU架构", FYDeviceInfo.cpuArch),
            ("CPU核数", "\(FYDeviceInfo.countOfCores)"),
            ("GPU种类", FYDeviceInfo.gpuType),
            ("屏幕分辨率", FYDeviceInfo.screenResolution),
            ("内存空间 MB", FYDeviceInfo.memoryTotal.memoryString),
            ("已用内存空间 MB", FYDeviceInfo.memoryUsage.memoryString),
            ("可用内存空间 MB", FYDeviceInfo.memoryFree.memoryString),
            ("磁盘空间", FYDeviceInfo.diskTotal.fileString),
            ("可用磁盘空间", FYDeviceInfo.diskAvailable.fileString),
            ("网络类型", FYDeviceInfo.network),
            ("WIFI下IP地址", FYDeviceInfo.ip),
            ("后摄分辨率", FYDeviceInfo.backCameraResolution),
            ("前摄分辨率", FYDeviceInfo.frontCameraResolution),
            ("生物识别是否可用", FYDeviceInfo.biometryAvailable.string),
            ("3D Touch是否可用", FYDeviceInfo.touch3DAvailable.string),
            ("设备是否越狱", FYDeviceInfo.isDeviceJailbroken.string)
        ]
        return datas
    }
}

extension FYSystemInfoController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return datas.count
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "SystemInfoCell", for: indexPath) as! SystemInfoCell
        cell.updateUI(data: datas[indexPath.row])
        return cell
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
}

