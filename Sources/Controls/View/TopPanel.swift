//
//  TopPanel.swift
//  Player
//
//  Created by chenp on 2018/9/20.
//  Copyright © 2018年 chenp. All rights reserved.
//

import UIKit

open class TopPanel: UIView {

    /// 顶部工具栏的背景图片
    open lazy var topBackgroundImageView: UIImageView = {
        let iv = UIImageView()
        iv.image = UIImage(inBundle: "player_bg_shadow_top")
        return iv
    }()
    /// 返回按钮
    open lazy var backButton: UIButton = {
        let btn = UIButton(type: .custom)
        btn.setImage(UIImage(inBundle: "player_btn_back"), for: .normal)
        btn.addTarget(self, action: #selector(backAction(_:)), for: .touchUpInside)
        return btn
    }()
    /// 视频标题
    open lazy var titleLabel: UILabel = {
        let lbl = UILabel()
        lbl.textColor = .white
        lbl.font = .systemFont(ofSize: 17)
        return lbl
    }()
    /// 分享按钮
    open lazy var shareButton: UIButton = {
        let btn = UIButton(type: .custom)
        btn.setImage(UIImage(inBundle: "player_btn_share"), for: .normal)
        btn.addTarget(self, action: #selector(shareAction(_:)), for: .touchUpInside)
        return btn
    }()
    /// 画中画按钮
    open lazy var startPIPButton: UIButton = {
        let btn = UIButton(type: .custom)
        btn.setImage(UIImage(inBundle: "player_btn_pip"), for: .normal)
        btn.addTarget(self, action: #selector(startPIPAction(_:)), for: .touchUpInside)
        return btn
    }()
    /// 更多按钮
    open lazy var moreButton: UIButton = {
        let btn = UIButton(type: .custom)
        btn.setImage(UIImage(inBundle: "player_btn_more"), for: .normal)
        btn.addTarget(self, action: #selector(moreAction(_:)), for: .touchUpInside)
        return btn
    }()

    public override init(frame: CGRect) {
        super.init(frame: frame)
        initialize()
    }
    
    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        initialize()
    }
    
    private func initialize() {
        addSubviews()
    }
    
    private func addSubviews() {
        addSubview(topBackgroundImageView)
        addSubview(backButton)
        addSubview(titleLabel)
        addSubview(shareButton)
        addSubview(startPIPButton)
        addSubview(moreButton)
    }
    
    var safeArea: UIEdgeInsets {
        var safeArea = UIEdgeInsets.zero
        if #available(iOS 11.0, *) {
            safeArea = safeAreaInsets
        }
        
        // 适配foreRotate()横屏时，安全区域仍然是竖屏的问题
        if UIApplication.shared.statusBarOrientation.isLandscape {
            if let window = UIApplication.shared.delegate?.window ?? nil {
                if #available(iOS 11.0, *) {
                    safeArea = window.safeAreaInsets
                }
            }
        }
        
        return safeArea
    }
    
    open override func layoutSubviews() {
        super.layoutSubviews()
        
        let topPanelH = bounds.height - safeArea.top
    
        topBackgroundImageView.frame = bounds
        backButton.frame = CGRect(x: safeArea.left, y: safeArea.top, width: topPanelH, height: topPanelH)
        
        moreButton.frame = CGRect(x: width - safeArea.right - topPanelH, y: safeArea.top, width: topPanelH, height: topPanelH)
        startPIPButton.frame = CGRect(x: moreButton.left - topPanelH, y: safeArea.top, width: topPanelH, height: topPanelH)
        
        if isHiddenMore {
            moreButton.frame = .zero
            startPIPButton.frame = CGRect(x: width - safeArea.right - topPanelH, y: safeArea.top, width: topPanelH, height: topPanelH)
        } else {
            moreButton.frame = CGRect(x: width - safeArea.right - topPanelH, y: safeArea.top, width: topPanelH, height: topPanelH)
            startPIPButton.frame = CGRect(x: moreButton.left - topPanelH, y: safeArea.top, width: topPanelH, height: topPanelH)
        }
        
        shareButton.frame = CGRect(x: startPIPButton.left - topPanelH, y: safeArea.top, width: topPanelH, height: topPanelH)
        titleLabel.frame = CGRect(x: backButton.right, y: safeArea.top, width: shareButton.left - backButton.right, height: topPanelH)
    }
    
    open var isHiddenMore: Bool = true {
        didSet {
            moreButton.isHidden = isHiddenMore
            layoutIfNeeded()
            setNeedsLayout()
        }
    }
    
    open weak var delegate: TopPanelDelegate?
    
    // MARK: - 🔥Action🔥
    @objc
    open func backAction(_ sender: UIButton) {
        delegate?.topPanel(self, backAction: sender)
    }
    
    @objc
    open func shareAction(_ sender: UIButton) {
        delegate?.topPanel(self, shareAction: sender)
    }
    
    @objc
    open func startPIPAction(_ sender: UIButton) {
        delegate?.topPanel(self, startPIPAction: sender)
    }
    
    @objc
    open func moreAction(_ sender: UIButton) {
        delegate?.topPanel(self, moreAction: sender)
    }
}

public protocol TopPanelDelegate: class {
    func topPanel(_ topPanel: TopPanel, backAction sender: UIButton)
    func topPanel(_ topPanel: TopPanel, shareAction sender: UIButton)
    func topPanel(_ topPanel: TopPanel, startPIPAction sender: UIButton)
    func topPanel(_ topPanel: TopPanel, moreAction sender: UIButton)
}

extension TopPanelDelegate {
    public func topPanel(_ topPanel: TopPanel, backAction sender: UIButton) {}
    public func topPanel(_ topPanel: TopPanel, shareAction sender: UIButton) {}
    public func topPanel(_ topPanel: TopPanel, startPIPAction sender: UIButton) {}
    public func topPanel(_ topPanel: TopPanel, moreAction sender: UIButton) {}
}
