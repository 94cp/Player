//
//  NetFlowMonitor.swift
//  Player
//
//  Created by chenp on 2018/9/17.
//  Copyright © 2018年 chenp. All rights reserved.
//

import Foundation

public protocol NetFlowMonitorDelegate: class {
    /// 当前网速信息
    func netFlow(_ monitor: NetFlowMonitor, speed: NetFlow)
}

open class NetFlowMonitor {
    
    open weak var delegate: NetFlowMonitorDelegate?
    
    private var lastflow: NetFlow
    private var timer: DispatchSourceTimer?
    
    public init() {
        lastflow = NetFlow()
    }
    
    deinit {
        stop()
    }
    
    // 开始监听网速
    open func start() {
        if timer == nil {
            let timer = DispatchSource.makeTimerSource()
            timer.schedule(deadline: .now(), repeating: 1) // 时间间隔1s
            timer.setEventHandler(handler: { [weak self] in
                guard let self = self else { return }

                DispatchQueue.main.async {
                    let flow = Net.flow()
                    self.delegate?.netFlow(self, speed: flow - self.lastflow)
                    self.lastflow = flow
                }
            })
            self.timer = timer
        }
        
        timer?.resume()
    }
    
    // 停止监听网速
    open func stop() {
        timer?.cancel()
        timer = nil
    }
}

extension NetFlow {
    
    public static func - (lhs: NetFlow, rhs: NetFlow) -> NetFlow {
        let result = NetFlow()
        
        result.received = lhs.received > rhs.received ? lhs.received - rhs.received : 0
        result.send = lhs.send > rhs.send ? lhs.send - rhs.send : 0
        
        result.wifiReceived = lhs.wifiReceived > rhs.wifiReceived ? lhs.wifiReceived - rhs.wifiReceived : 0
        result.wifiSend = lhs.wifiSend > rhs.wifiSend ? lhs.wifiSend - rhs.wifiSend : 0
        
        result.wwanReceived = lhs.wwanReceived > rhs.wwanReceived ? lhs.wwanReceived - rhs.wwanReceived : 0
        result.wwanSend = lhs.wwanSend > rhs.wwanSend ? lhs.wwanSend - rhs.wwanSend : 0
        
        return result
    }
}
