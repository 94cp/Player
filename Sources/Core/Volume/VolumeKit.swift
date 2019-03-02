//
//  VolumeKit.swift
//  Player
//
//  Created by chenp on 2018/10/16.
//  Copyright © 2018年 chenp. All rights reserved.
//

import UIKit
import AVFoundation.AVFAudio.AVAudioSession
import MediaPlayer.MPVolumeView

public protocol VolumeKitDelegate: class {
    func volumeKit(_ volumeKit: VolumeKit, systemVolumeDidChange value: CGFloat)
}

extension VolumeKitDelegate {
    public func volumeKit(_ volumeKit: VolumeKit, systemVolumeDidChange value: CGFloat) { }
}

open class VolumeKit {
    
    open weak var delegate: VolumeKitDelegate?

    /// 系统音量进度条
    private lazy var _volumeSlider: UISlider? = {
        guard let clazz = NSClassFromString("MPVolumeSlider") else { return nil }
        let volumeView = MPVolumeView()
        for view in volumeView.subviews where view.isKind(of: clazz) {
            return view as? UISlider
        }
        return nil
    }()
    
    private lazy var _volumeView = MPVolumeView(frame: CGRect(x: -1000, y: -1000, width: 100, height: 100))
    
    /// 系统音量
    open var volume: CGFloat {
        get {
            var volume = CGFloat(_volumeSlider?.value ?? 0)
            if volume == 0 {
                volume = CGFloat(AVAudioSession.sharedInstance().outputVolume)
            }
            return volume
        }
        set {
            _volumeSlider?.value = Float(min(max(0, newValue), 1))
        }
    }

    public init() {
        NotificationCenter.default.addObserver(self, selector: #selector(systemVolumeDidChange(_:)), name: .systemVolumeDidChange, object: nil)
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self, name: .systemVolumeDidChange, object: nil)
    }
    
    @objc
    private func systemVolumeDidChange(_ notification: Notification) {
        let volume = (notification.userInfo?[String.systemAudioVolumeNotificationKey] as? CGFloat) ?? 0
        delegate?.volumeKit(self, systemVolumeDidChange: volume)
    }
    
    /// 添加系统音量控件
    open func addSystemVolumeView() {
        _volumeView.removeFromSuperview()
    }
    
    /// 移除系统音量控件
    open func removeSystemVolumeView() {
        UIApplication.shared.delegate?.window??.addSubview(_volumeView)
    }
}

extension NSNotification.Name {
    public static let systemVolumeDidChange = NSNotification.Name(rawValue: "AVSystemController_SystemVolumeDidChangeNotification")
}

extension String {
    public static let systemAudioVolumeNotificationKey = "AVSystemController_AudioVolumeNotificationParameter"
}
