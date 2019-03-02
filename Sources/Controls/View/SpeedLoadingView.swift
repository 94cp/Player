//
//  SpeedLoadingView.swift
//  Player
//
//  Created by chenp on 2018/9/20.
//  Copyright © 2018年 chenp. All rights reserved.
//

import UIKit
import PlayerCore

open class SpeedLoadingView: UIView, NetFlowMonitorDelegate {

    open lazy var loadingView: NVActivityIndicatorView = {
        let loadingView = NVActivityIndicatorView(frame: CGRect(x: 0, y: 0, width: 44, height: 44))
        return loadingView
    }()
    
    open lazy var speedLabel: UILabel = {
        let lbl = UILabel()
        lbl.font = UIFont.systemFont(ofSize: 12)
        lbl.textColor = .white
        lbl.textAlignment = .center
        return lbl
    }()
    
    open lazy var flowMonitor: NetFlowMonitor = {
        let flowMonitor = NetFlowMonitor()
        flowMonitor.delegate = self
        return flowMonitor
    }()
    
    open var minDisplaySpeed: UInt32 = 100 * 1024 // 100 kb/s
    
    /// width: 80, height: 80
    public override init(frame: CGRect) {
        super.init(frame: frame)
        initialize()
    }
    
    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        initialize()
    }
    
    deinit {
        flowMonitor.stop()
    }
    
    private func initialize() {
        isUserInteractionEnabled = false
        
        addSubview(loadingView)
        addSubview(speedLabel)
        
        // 开始监控网络
        flowMonitor.start()
    }
    
    open override func layoutSubviews() {
        super.layoutSubviews()
        
        loadingView.frame = CGRect(x: (width - 44) / 2, y: (height - 44) / 2 - 10, width: 44, height: 44)
        speedLabel.frame = CGRect(x: 0, y: loadingView.bottom + 5, width: width, height: 20)
    }

    open func startAnimating() {
        guard isHidden else { return }
        
        loadingView.startAnimating()
        isHidden = false
    }
    
    open func stopAnimating() {
        guard !isHidden else { return }
        
        loadingView.stopAnimating()
        isHidden = true
    }
    
    // MARK: - 🔥NetFlowMonitorDelegate🔥
    open func netFlow(_ monitor: NetFlowMonitor, speed: NetFlow) {
        speedLabel.text = (speed.received >= minDisplaySpeed ? speed.received.formatSpeed : nil)
    }
}
