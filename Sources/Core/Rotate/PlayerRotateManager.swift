//
//  PlayerRotateManager.swift
//  Player
//
//  Created by chenp on 2018/9/23.
//  Copyright © 2018年 chenp. All rights reserved.
//

import UIKit

public protocol PlayerRotateManagerDelegate: class {
    /// 设备方向改变
    func rotateManager(_ rotateManager: PlayerRotateManager, deviceOrientationChange orientation: UIInterfaceOrientation)
    
    /// 将要手动强制旋转
    func rotateManager(_ rotateManager: PlayerRotateManager, willForceRotate orientation: UIInterfaceOrientation)
    /// 完成手动强制旋转
    func rotateManager(_ rotateManager: PlayerRotateManager, didForceRotate orientation: UIInterfaceOrientation)
}

open class PlayerRotateManager {
    
    open weak var delegate: PlayerRotateManagerDelegate?

    /// 添加设备方向变化观察者
    open func addDeviceOrientationObserver() {
        if !UIDevice.current.isGeneratingDeviceOrientationNotifications {
            UIDevice.current.beginGeneratingDeviceOrientationNotifications()
        }
        NotificationCenter.default.addObserver(self, selector: #selector(orientationDidChange(_:)), name: UIDevice.orientationDidChangeNotification, object: nil)
    }
    
    /// 移除设备方向变化观察者
    open func removeDeviceOrientationObserver() {
        if !UIDevice.current.isGeneratingDeviceOrientationNotifications {
            UIDevice.current.endGeneratingDeviceOrientationNotifications()
        }
        NotificationCenter.default.removeObserver(self, name: UIDevice.orientationDidChangeNotification, object: nil)
    }
    
    /// 设备方向变化通知处理方法
    @objc
    private func orientationDidChange(_ notification: Notification) {
        guard UIDevice.current.orientation.isValidInterfaceOrientation else { return }
        
        // 状态栏方向和设备方向一致，界面旋转方向和设备方向相反
        let orientation = UIDevice.current.orientation.interfaceOrientation
        
        // 强制自动旋转
        if shouldForceAutorotate {
            if orientation != currentForceOrientation && supportedForceInterfaceOrientations.contains(orientation.interfaceOrientationMask) {
                forceRotate(orientation, animated: true)
            }
        }
        
        delegate?.rotateManager(self, deviceOrientationChange: orientation)
    }
    
    private var _shouldForceAutorotate = false
    /// 是否强制自动旋转，默认 false
    open var shouldForceAutorotate: Bool {
        get { return _shouldForceAutorotate }
        set { _shouldForceAutorotate = newValue }
    }
    
    /// 支持的强制旋转方向，默认 .allButUpsideDown
    private var _supportedForceInterfaceOrientations = UIInterfaceOrientationMask.allButUpsideDown
    open var supportedForceInterfaceOrientations: UIInterfaceOrientationMask {
        get { return _supportedForceInterfaceOrientations }
        set { _supportedForceInterfaceOrientations = newValue }
    }
    
    private var _preferredForceInterfaceOrientationForPresentation = UIInterfaceOrientation.portrait // swiftlint:disable:this identifier_name
    /// 优先强制屏幕方向，默认 .portrait
    open var preferredForceInterfaceOrientationForPresentation: UIInterfaceOrientation { // swiftlint:disable:this identifier_name
        get { return _preferredForceInterfaceOrientationForPresentation }
        set {
            currentForceOrientation = newValue
            _preferredForceInterfaceOrientationForPresentation = newValue
        }
    }
    
    /// 当前强制屏幕方向
    open private(set) var currentForceOrientation = UIInterfaceOrientation.portrait

    /// 强制旋转动画时间，默认=状态栏旋转动画时间
    open var forceRotateDuration: TimeInterval = UIApplication.shared.statusBarOrientationAnimationDuration

    /// 强制自动旋转所需的原始父控件
    open var forceFatherView: UIView?
    
    /// 被强制自动旋转的控件
    open var forceTargetView: UIView?
    
    /// 手动旋转view
    open func forceRotate(_ orientation: UIInterfaceOrientation, animated: Bool) {
        guard let targetView = forceTargetView, let window = UIApplication.shared.delegate?.window ?? nil else { return }
        
        delegate?.rotateManager(self, willForceRotate: orientation)
        
        var fatherView: UIView = window
        if let forceFatherView = forceFatherView {
            fatherView = forceFatherView
        }
        
        // 设置屏幕方向
        setOrientation(orientation)
        // 设置屏幕状态栏方向
        setStatusBarOrientation(orientation)
        
        let screenSize = UIScreen.main.bounds.width * UIScreen.main.bounds.height
        let fatherSize = fatherView.frame.width * fatherView.frame.height
        
        var superview: UIView = fatherView
        if fatherSize != screenSize {
            // 横屏全屏
            superview = orientation.isLandscape ? window : fatherView
        }
      
        var transFrame = superview.bounds
        
        if preferredForceInterfaceOrientationForPresentation.isPortrait {
            // 初始方向为 竖屏
            if orientation.isLandscape {
                superview.addSubview(targetView)
                targetView.frame = targetView.convert(targetView.frame, to: superview)
            } else {
                transFrame = superview.convert(superview.bounds, to: targetView.superview)
            }
        } else {
            // 初始方向为 横屏
            if orientation.isPortrait {
                superview.addSubview(targetView)
                targetView.frame = superview.convert(superview.bounds, from: targetView.superview)
            } else {
                transFrame = targetView.convert(targetView.bounds, to: superview)
            }
        }
        
        // 旋转view
        UIView.animate(withDuration: animated ? forceRotateDuration : 0, animations: {
            targetView.transform = self.getTransformRotationAngle(orientation)
            
            UIView.animate(withDuration: animated ? self.forceRotateDuration : 0, animations: {
                targetView.frame = transFrame
                targetView.layoutIfNeeded()
            })
            
        }, completion: { _ in
            superview.addSubview(targetView)
            targetView.frame = superview.bounds
            targetView.layoutIfNeeded()
            
            self.currentForceOrientation = orientation
            // 完成旋转
            self.delegate?.rotateManager(self, didForceRotate: orientation)
        })
    }
    
    /// 旋转角度
    open func getTransformRotationAngle(_ interfaceorientation: UIInterfaceOrientation) -> CGAffineTransform {
        switch interfaceorientation {
        case .landscapeLeft:
            return CGAffineTransform(rotationAngle: -.pi / 2)
        case .landscapeRight:
            return CGAffineTransform(rotationAngle: .pi / 2)
        default:
            return .identity
        }
    }
    
    /// 设置屏幕方向，横屏设备方向与屏幕方向相反
    open func setOrientation(_ orientation: UIInterfaceOrientation) {
        if !shouldForceAutorotate {
            UIDevice.current.setValue(UIDeviceOrientation.unknown.rawValue, forKey: "orientation")
        }
        UIDevice.current.setValue(orientation.deviceOrientation.rawValue, forKey: "orientation")
    }
    
    /// 设置屏幕状态栏方向，状态栏方向和设备方向一致
    open func setStatusBarOrientation(_ orientation: UIInterfaceOrientation) {
        UIApplication.shared.setValue(orientation.deviceOrientation.rawValue, forKey: "statusBarOrientation")
    }
}

extension PlayerRotateManagerDelegate {
    public func rotateManager(_ rotateManager: PlayerRotateManager, deviceOrientationChange orientation: UIInterfaceOrientation) {}
    public func rotateManager(_ rotateManager: PlayerRotateManager, willForceRotate orientation: UIInterfaceOrientation) {}
    public func rotateManager(_ rotateManager: PlayerRotateManager, didForceRotate orientation: UIInterfaceOrientation) {}
}
