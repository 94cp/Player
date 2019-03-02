//
//  PlayerPictureInPictureController.swift
//  Player
//
//  Created by chenp on 2018/11/10.
//  Copyright © 2018年 chenp. All rights reserved.
//

import UIKit

public enum PictureInPicturePosition {
    case topLeft
    case middleLeft
    case bottomLeft
    case topRight
    case middleRight
    case bottomRight
}

public enum PlayerPictureInPictureControllerError: Error {
    case unknown
    case noWindow
    case noPlayerViewController
    case noPlayback
    case noVisibleViewController
}

public protocol PlayerPictureInPictureControllerDelegate: class {
    func pictureInPictureControllerWillStartPictureInPicture(_ pictureInPictureController: PlayerPictureInPictureController)
    func pictureInPictureControllerDidStartPictureInPicture(_ pictureInPictureController: PlayerPictureInPictureController)
    func pictureInPictureControllerWillStopPictureInPicture(_ pictureInPictureController: PlayerPictureInPictureController)
    func pictureInPictureControllerDidStopPictureInPicture(_ pictureInPictureController: PlayerPictureInPictureController)
    func pictureInPictureController(_ pictureInPictureController: PlayerPictureInPictureController, failedToStartPictureInPictureWithError error: PlayerPictureInPictureControllerError)
    func pictureInPictureController(_ pictureInPictureController: PlayerPictureInPictureController, failedToStopPictureInPictureWithError error: PlayerPictureInPictureControllerError)
}

open class PlayerPictureInPictureController {
    
    open weak var playerViewController: PlayerViewController?
    
    public init(playerViewController: PlayerViewController) {
        self.playerViewController = playerViewController
    }
    
    deinit {
        clear()
    }
    
    open weak var delegate: PlayerPictureInPictureControllerDelegate?
    
    open lazy var pictureInPictureView = PlayerPictureInPictureView()
    
    /// 16:9
    open var pictureInPictureSize: CGSize = CGSize(width: UIScreen.main.minHalfWidth, height: UIScreen.main.minHalfWidth / 16 * 9)
    
    /// 画中画位置
    open var pictureInPicturePosition: PictureInPicturePosition = .bottomRight {
        didSet {
            guard oldValue != pictureInPicturePosition else { return }
            guard isPictureInPictureActive else { return }
            layoutPictureInPicture()
        }
    }

    /// 是否激活画中画
    open private(set) var isPictureInPictureActive = false
    
    /// 启动 画中画 时，是否返回到上一层 控制器
    open var isBackToPrevViewController = true
    
    open var duration: TimeInterval = 0.25
    
    open var visibleViewController: UIViewController?
    open var presentingViewController: UIViewController?
    open var navigationController: UINavigationController?
    
    private var _isAnimating = false

    open func startPictureInPicture(animated: Bool) {
        if isPictureInPictureActive || _isAnimating { return }
        
        guard let window = UIApplication.shared.delegate?.window ?? nil else {
            delegate?.pictureInPictureController(self, failedToStartPictureInPictureWithError: .noWindow)
            return
        }
        guard let playerViewController = playerViewController else {
            delegate?.pictureInPictureController(self, failedToStartPictureInPictureWithError: .noPlayerViewController)
            return
        }
        guard let playback = playerViewController.playback else {
            delegate?.pictureInPictureController(self, failedToStartPictureInPictureWithError: .noPlayback)
            return
        }
        
        delegate?.pictureInPictureControllerWillStartPictureInPicture(self)
        
        addDeviceOrientationObserver()
        
        // 返回上一控制器时，保留原控制器的一些属性，供停止画中画时恢复原来样式
        if isBackToPrevViewController {
            window.playerViewController = playerViewController
            visibleViewController = playerViewController.visibleViewController
            presentingViewController = playerViewController.visibleViewController.presentingViewController
            if let nav = playerViewController.visibleViewController as? UINavigationController {
                navigationController = nav
            } else {
                navigationController = playerViewController.visibleViewController.navigationController
            }
        }
        
        pictureInPictureView.addSubview(playback.view)
        playback.view.frame = pictureInPictureView.bounds
        playback.view.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        
        if let controlsView = playerViewController.controlsView {
            pictureInPictureView.addSubview(controlsView)
            controlsView.frame = pictureInPictureView.bounds
            controlsView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        }
    
        window.addSubview(pictureInPictureView)
        
        _isAnimating = true
        UIView.animate(withDuration: animated ? duration : 0, animations: {
            self.layoutPictureInPicture()
        }, completion: { _ in
            func startPIPFinish() {
                self._isAnimating = false
                self.isPictureInPictureActive = true
                if !window.bounds.contains(self.pictureInPictureView.frame) {
                    self.layoutPictureInPicture()
                }
                self.delegate?.pictureInPictureControllerDidStartPictureInPicture(self)
            }
            
            if self.presentingViewController != nil {
                playerViewController.visibleViewController.dismiss(animated: false, completion: nil)
            } else if let navigationController = self.navigationController {
                navigationController.popViewController(animated: false)
            }
            startPIPFinish()
        })
    }
    
    open func stopPictureInPicture(animated: Bool) {
        if !isPictureInPictureActive || _isAnimating { return }
    
        guard let playerViewController = playerViewController else {
            delegate?.pictureInPictureController(self, failedToStopPictureInPictureWithError: .noPlayerViewController)
            return
        }
        guard let playback = playerViewController.playback else {
            delegate?.pictureInPictureController(self, failedToStopPictureInPictureWithError: .noPlayerViewController)
            return
        }
        
        delegate?.pictureInPictureControllerWillStopPictureInPicture(self)
        
        removeDeviceOrientationObserver()
        
        pictureInPictureView.removeFromSuperview()
        
        playerViewController.view.addSubview(playback.view)
        playback.view.frame = playerViewController.view.bounds
        playback.view.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        
        if let controlsView = playerViewController.controlsView {
            playerViewController.view.addSubview(controlsView)
            controlsView.frame = playerViewController.view.bounds
            controlsView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        }
        
        _isAnimating = true
        func stopPIPFinish() {
            _isAnimating = false
            isPictureInPictureActive = false
            clear()
            delegate?.pictureInPictureControllerDidStopPictureInPicture(self)
        }
        
        if let visibleViewController = visibleViewController {
            if let presentingViewController = presentingViewController {
                presentingViewController.present(visibleViewController, animated: animated) {
                    stopPIPFinish()
                }
            } else if let navigationController = navigationController {
                navigationController.pushViewController(visibleViewController, animated: animated)
            }
            stopPIPFinish()
        }
    }
    
    open func clear() {
        visibleViewController = nil
        presentingViewController = nil
        navigationController = nil
        let window = UIApplication.shared.delegate?.window
        window??.playerViewController = nil
        removeDeviceOrientationObserver()
    }
    
    /// 添加设备方向变化观察者
    private func addDeviceOrientationObserver() {
        if !UIDevice.current.isGeneratingDeviceOrientationNotifications {
            UIDevice.current.beginGeneratingDeviceOrientationNotifications()
        }
        NotificationCenter.default.addObserver(self, selector: #selector(orientationDidChange(_:)), name: UIDevice.orientationDidChangeNotification, object: nil)
    }
    
    /// 移除设备方向变化观察者
    private func removeDeviceOrientationObserver() {
        if !UIDevice.current.isGeneratingDeviceOrientationNotifications {
            UIDevice.current.endGeneratingDeviceOrientationNotifications()
        }
        NotificationCenter.default.removeObserver(self, name: UIDevice.orientationDidChangeNotification, object: nil)
    }
    
    /// 设备方向变化通知处理方法
    @objc
    private func orientationDidChange(_ notification: Notification) {
        guard UIDevice.current.orientation.isValidInterfaceOrientation, isPictureInPictureActive else { return }
        guard let window = UIApplication.shared.delegate?.window ?? nil else { return }
        
        if !window.bounds.contains(pictureInPictureView.frame) {
            layoutPictureInPicture()
        }
    }
    
    open func layoutPictureInPicture() {
        guard let window = UIApplication.shared.delegate?.window ?? nil else { return }
        
        var origin = CGPoint.zero
        
        var safeAreaInsets = UIEdgeInsets.zero
        if #available(iOS 11.0, *) {
            safeAreaInsets = window.safeAreaInsets
        }
        
        switch pictureInPicturePosition {
        case .topLeft:
            origin.x = safeAreaInsets.left
            origin.y = safeAreaInsets.top
        case .middleLeft:
            origin.x = safeAreaInsets.left
            let vh = (window.frame.height - (safeAreaInsets.top + safeAreaInsets.bottom)) / 3.0
            origin.y = safeAreaInsets.top + (vh * 2.0) - ((vh + pictureInPictureSize.height) / 2.0)
        case .bottomLeft:
            origin.x = safeAreaInsets.left
            origin.y = window.frame.height - safeAreaInsets.bottom - pictureInPictureSize.height
        case .topRight:
            origin.x = window.frame.width - safeAreaInsets.right - pictureInPictureSize.width
            origin.y = safeAreaInsets.top
        case .middleRight:
            origin.x = window.frame.width - safeAreaInsets.right - pictureInPictureSize.width
            let vh = (window.frame.height - (safeAreaInsets.top + safeAreaInsets.bottom)) / 3.0
            origin.y = safeAreaInsets.top + (vh * 2.0) - ((vh + pictureInPictureSize.height) / 2.0)
        case .bottomRight:
            origin.x = window.frame.width - safeAreaInsets.right - pictureInPictureSize.width
            origin.y = window.frame.height - safeAreaInsets.bottom - pictureInPictureSize.height
        }
        
        pictureInPictureView.frame = CGRect(origin: origin, size: pictureInPictureSize)
    }
}

extension UIScreen {
    fileprivate var minHalfWidth: CGFloat {
        return min(UIScreen.main.bounds.width, UIScreen.main.bounds.height) / 2
    }
}

extension UIWindow {
    
    private struct AssociatedKeys {
        static var playerViewController: UInt8 = 0
    }
    
    public var playerViewController: PlayerViewController? {
        get { return objc_getAssociatedObject(self, &AssociatedKeys.playerViewController) as? PlayerViewController }
        set { objc_setAssociatedObject(self, &AssociatedKeys.playerViewController, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC) }
    }
}

extension PlayerPictureInPictureControllerDelegate {
    public func pictureInPictureControllerWillStartPictureInPicture(_ pictureInPictureController: PlayerPictureInPictureController) {}
    public func pictureInPictureControllerDidStartPictureInPicture(_ pictureInPictureController: PlayerPictureInPictureController) {}
    public func pictureInPictureControllerWillStopPictureInPicture(_ pictureInPictureController: PlayerPictureInPictureController) {}
    public func pictureInPictureControllerDidStopPictureInPicture(_ pictureInPictureController: PlayerPictureInPictureController) {}
    public func pictureInPictureController(_ pictureInPictureController: PlayerPictureInPictureController, failedToStartPictureInPictureWithError error: PlayerPictureInPictureControllerError) {}
    public func pictureInPictureController(_ pictureInPictureController: PlayerPictureInPictureController, failedToStopPictureInPictureWithError error: PlayerPictureInPictureControllerError) {}
}
