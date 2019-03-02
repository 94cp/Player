//
//  PlayerViewController.swift
//  Player
//
//  Created by chenp on 2018/9/16.
//  Copyright © 2018年 chenp. All rights reserved.
//

import UIKit

open class PlayerViewController: UIViewController {
    
    // MARK: - 🔥Life Cycle🔥
    
    public override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
        initialize()
    }
    
    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        initialize()
    }
    
    private func initialize() {
        guard let window = UIApplication.shared.delegate?.window ?? nil else { return }
        window.playerViewController?.close(animated: false)
        window.playerViewController?.pictureInPictureController.clear()
    }
    
    deinit {
        playback?.stop()
        playback?.view.removeFromSuperview()
        
        controlsView?.removeFromSuperview()
        
        rotateManager.removeDeviceOrientationObserver()
        
        pictureInPictureController.clear()
        
        Log.info("deinit")
    }
    
    open override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: animated)
    }
    
    open override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        navigationController?.setNavigationBarHidden(false, animated: animated)
    }
    
    open override var shouldAutorotate: Bool {
        return true
    }
    
    open override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        return .allButUpsideDown
    }
    
    open override var preferredInterfaceOrientationForPresentation: UIInterfaceOrientation {
        return .landscapeRight
    }

    open override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    open override var prefersStatusBarHidden: Bool {
        return isStatusBarHidden
    }
    
    // MARK: - 🔥播放器 控制器🔥
  
    /// 媒体播放器
    open var playback: PlayerPlayback? {
        didSet {
            guard var playback = playback else { return }
            
            // 清理旧播放器
            if let oldPlayback = oldValue {
                if oldPlayback.view == playback.view { return }
                
                oldPlayback.stop()
                oldPlayback.view.removeFromSuperview()
                rotateManager.removeDeviceOrientationObserver()
            }
            
            // 添加新播放器
            if let control = controlsView {
                view.insertSubview(playback.view, belowSubview: control)
            } else {
                view.addSubview(playback.view)
            }
            playback.view.frame = view.bounds
            playback.view.autoresizingMask = [.flexibleWidth, .flexibleHeight]
            playback.delegate = self
            
            rotateManager.addDeviceOrientationObserver()
        }
    }
    
    /// 媒体控制器
    open var controlsView: (UIView & PlayerControlsable)? {
        didSet {
            guard var controlsView = controlsView else { return }
            
            // 清理旧控制器
            if let oldControlsView = oldValue {
                if oldControlsView == controlsView { return }
                gestureManager.removeGestures()
                oldControlsView.removeFromSuperview()
            }
            
            // 添加新控制器
            if let playback = playback {
                view.insertSubview(controlsView, aboveSubview: playback.view)
            } else {
                view.addSubview(controlsView)
            }
            controlsView.frame = view.bounds
            controlsView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
            controlsView.delegate = self
            controlsView.playerViewController = self
            
            gestureManager.addGestures(to: controlsView)
        }
    }
    
    open weak var delegate: PlayerViewControllerDelegate?
    
    // MARK: - 🔥System Volume Brightness🔥
    
    /// 系统音量Kit
    open lazy var volumeKit: VolumeKit = {
        let volumeKit = VolumeKit()
        volumeKit.delegate = self
        return volumeKit
    }()
    
    /// 记录静音前音量，用于恢复音量
    private var _muteBeforeVolume: CGFloat = 0
    
    /// 系统亮度
    open var brightness: CGFloat {
        get { return UIScreen.main.brightness }
        set { UIScreen.main.brightness = min(max(0, newValue), 1) }
    }
    
    /// 系统静音
    open var isMated: Bool {
        get { return volume == 0 }
        set {
            if newValue {
                _muteBeforeVolume = volume
                volume = 0
            } else {
                if _muteBeforeVolume == 0 {
                    _muteBeforeVolume = volume
                }
                volume = _muteBeforeVolume
            }
        }
    }
    
    /// 系统音量
    open var volume: CGFloat {
        get { return volumeKit.volume }
        set { volumeKit.volume = newValue }
    }
    
    // MARK: - 🔥Rotate🔥
    
    open lazy var rotateManager: PlayerRotateManager = {
        let rotateManager = PlayerRotateManager()
        rotateManager.forceTargetView = view
        rotateManager.delegate = self
        return rotateManager
    }()
    
    open var currentOrientation: UIInterfaceOrientation {
        guard !rotateManager.shouldForceAutorotate else { return rotateManager.currentForceOrientation }
        
        let deviceOrientation = UIDevice.current.orientation
        if deviceOrientation.isValidInterfaceOrientation {
            return deviceOrientation.interfaceOrientation
        }
        
        return UIApplication.shared.statusBarOrientation
    }
    
    open var isPortrait: Bool {
        if rotateManager.shouldForceAutorotate {
            return rotateManager.currentForceOrientation.isPortrait
        } else {
            return UIApplication.shared.statusBarOrientation.isPortrait
        }
    }
    
    open var isLandscape: Bool {
        if rotateManager.shouldForceAutorotate {
            return rotateManager.currentForceOrientation.isLandscape
        } else {
            return UIApplication.shared.statusBarOrientation.isLandscape
        }
    }
    
    /// 设置屏幕方向，横屏设备方向与屏幕方向相反
    open func setOrientation(_ orientation: UIInterfaceOrientation) {
        if rotateManager.shouldForceAutorotate {
            rotateManager.forceRotate(orientation, animated: true)
        } else {
            rotateManager.setOrientation(orientation)
        }
    }
    
    // MARK: - 🔥Gesture🔥
    open lazy var gestureManager: PlayerGestureManager = {
        let gestureManager = PlayerGestureManager()
        gestureManager.delegate = self
        return gestureManager
    }()
    
    // MARK: - 🔥Picture In Picture🔥
    open lazy var pictureInPictureController: PlayerPictureInPictureController = {
        let pictureInPictureController = PlayerPictureInPictureController(playerViewController: self)
        pictureInPictureController.delegate = self
        return pictureInPictureController
    }()
    
    // MARK: - 🔥StatusBar🔥
    open private(set) var isStatusBarHidden = false
    
    /// 设置状态栏 显示/隐藏
    open func setStatusBarHidden(_ hidden: Bool) {
        let statusBarH = UIApplication.shared.statusBarFrame.height
        let isHiddenSB = statusBarH <= 0
        
        if hidden == isHiddenSB { return }
        
        isStatusBarHidden = hidden
        visibleViewController.setNeedsStatusBarAppearanceUpdate()
    }
    
    // MARK: - 🔥Public Method🔥
    
    /// 是否支持横屏返回到竖屏
    open var isBackToPortrait = true
    
    /// 如果支持横屏返回到竖屏，在横屏将会旋转到竖屏方向，否则关闭播放器页面
    open func back(animated: Bool) {
        if isLandscape && isBackToPortrait {
            if rotateManager.shouldForceAutorotate {
                rotateManager.forceRotate(.portrait, animated: animated)
            } else {
                setOrientation(.portrait)
            }
        } else {
            close(animated: animated)
        }
    }
    
    /// 关闭播放器页面
    open func close(animated: Bool) {
        pictureInPictureController.clear()
        if let nav = visibleViewController as? UINavigationController {
            nav.popViewController(animated: animated)
        } else if let nav = visibleViewController.navigationController {
            nav.popViewController(animated: animated)
        } else {
            visibleViewController.dismiss(animated: animated, completion: nil)
        }
    }
    
    // MARK: - 🔥辅助属性🔥
    
    /// 播放器实际所属 视图控制器。
    /// 如果是 addChild 方式添加 PlayerViewController，实际控制器就是 PlayerViewController 的 parent控制器，其它方式就是它本身
    open var visibleViewController: UIViewController {
        if let parent = parent {
            return parent // addChild
        } else {
            return self   // present or push
        }
    }
}
