//
//  FYWindow.swift
//  FYTester
//
//  Created by 薛焱 on 2022/4/2.
//

import Foundation

class FYTesterView: UIView {
    private lazy var vcLab: UILabel = {
        let lab = UILabel()
        lab.textColor = UIColor.white
        lab.font = .systemFont(ofSize: 8)
        lab.isUserInteractionEnabled = true
        lab.numberOfLines = 2
        let tap = UITapGestureRecognizer(target: self, action: #selector(copyTapAction))
        lab.addGestureRecognizer(tap)
        lab.isHidden = true
        return lab
    }()
    private lazy var cpuLab: UILabel = {
        let lab = UILabel()
        lab.font = UIFont.systemFont(ofSize: 10)
        lab.textColor = UIColor.white
        lab.text = "CPU：0%"
        return lab
    }()
    private lazy var memoryLab: UILabel = {
        let lab = UILabel()
        lab.font = UIFont.systemFont(ofSize: 10)
        lab.textColor = UIColor.white
        lab.text = "内存：0M"
        return lab
    }()
    private lazy var fpsLab: UILabel = {
        let lab = UILabel()
        lab.font = UIFont.systemFont(ofSize: 10)
        lab.textColor = UIColor.white
        lab.text = "FPS：0"
        return lab
    }()
    private lazy var netLab: UILabel = {
        let lab = UILabel()
        lab.font = UIFont.systemFont(ofSize: 10)
        lab.textColor = UIColor.white
        lab.text = "网络：--"
        return lab
    }()
    private lazy var contentView: UIStackView = {
        let views: [UIView] = [vcLab, cpuLab, memoryLab, fpsLab, netLab]
        let stackView = UIStackView(arrangedSubviews: views)
        stackView.axis = .vertical
        stackView.spacing = 1
        stackView.distribution = .equalSpacing
        return stackView
    }()
    private lazy var toolWindow: UIWindow = {
        let w = UIWindow(frame: UIScreen.main.bounds)
        w.windowLevel = .alert + 101
        w.rootViewController = UIViewController()
        return w
    }()
    private var edgeInset: CGFloat = 2

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupUI() {
        addSubview(contentView)
        layer.cornerRadius = 4
        let width = bounds.width - edgeInset * 2
        let height = bounds.height - edgeInset * 2
        contentView.frame = CGRect(x: edgeInset, y: edgeInset, width: width, height: height)
        let tap = UITapGestureRecognizer(target: self, action: #selector(tapAction))
        tap.numberOfTapsRequired = 2
        addGestureRecognizer(tap)
    }

    @objc func tapAction() {
        if toolWindow.isHidden {
            toolWindow.isHidden = false
            let vc = FYToolViewController()
            let nav = UINavigationController(rootViewController: vc)
            nav.modalPresentationStyle = .fullScreen
            nav.view.backgroundColor = .white
            nav.navigationBar.isTranslucent = false
            toolWindow.rootViewController?.present(nav, animated: true)
            FYTester.share.tool.nav = nav
        } else {
            toolWindow.rootViewController?.dismiss(animated: true)
            toolWindow.isHidden = true
        }
    }

    func updateUI(_ cpu: CGFloat, memory: UInt64, fps: Int, net: String) {
        if #available(iOS 13.0, *) {
            let windwoSceen: UIWindowScene = UIApplication.shared.connectedScenes.first as! UIWindowScene
            let keyWindow = windwoSceen.windows.first(where: {$0.isKeyWindow})
            if let vc = keyWindow?.topViewController() {
                let vcStr = type(of: vc)
                vcLab.text = "\(vcStr)"
                vcLab.isHidden = false
            } else {
                vcLab.isHidden = true
            }
            
        } else {
            // Fallback on earlier versions
        }
        
        self.cpuLab.text = "CPU：\(Int(cpu * 100))%"
        self.memoryLab.text = "内存：\(memory.memoryString)"
        self.fpsLab.text = "FPS：\(fps)"
        self.netLab.text = "网络：\(net)"
        backgroundColor = FYTester.share.tool.env.color.withAlphaComponent(0.8)
    }
    
    @objc private func copyTapAction() {
        UIPasteboard.general.string = self.vcLab.text
    }
}

private extension UIWindow {
    func topViewController() -> UIViewController? {
        var top = self.rootViewController
        while true {
            if let presented = top?.presentedViewController {
                top = presented
            } else if let nav = top as? UINavigationController {
                top = nav.visibleViewController
            } else if let tab = top as? UITabBarController {
                top = tab.selectedViewController
            } else {
                break
            }
        }
        return top
    }
}
