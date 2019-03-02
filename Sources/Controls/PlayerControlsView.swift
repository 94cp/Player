//
//  PlayerControlsView.swift
//  Player
//
//  Created by chenp on 2018/9/20.
//  Copyright © 2018年 chenp. All rights reserved.
//

import UIKit
import PlayerCore

open class PlayerControlsView: UIView, PlayerControlsable, TopPanelDelegate, BottomPanelDelegate, MoreContentViewDelegate {
   
    /// 封面图
    open lazy var coverImageView: UIImageView = {
        let coverImageView = UIImageView()
        coverImageView.contentMode = .scaleAspectFit
        return coverImageView
    }()
    
    /// 顶部工具栏
    open lazy var topPanel: TopPanel = {
        let topPanel = TopPanel()
        topPanel.delegate = self
        return topPanel
    }()
    
    /// 底部工具栏
    open lazy var bottomPanel: BottomPanel  = {
        let bottomPanel = BottomPanel()
        bottomPanel.delegate = self
        return bottomPanel
    }()
    
    // 底部播放进度
    open lazy var bottomProgressSlider: BufferSlider = {
        let slider = BufferSlider()
        slider.minimumValueImage = UIImage(inBundle: "player_bg_progress_min")
        slider.bufferTrackTintColor = .gray
        slider.maximumTrackTintColor = UIColor.black.withAlphaComponent(0.6)
        slider.sliderButton.isHidden = true
        slider.sliderHeight = 2
        return slider
    }()
    
    /// 播放或暂停按钮
    open lazy var centerPlayOrPauseButton: AnimatablePlayOrPauseButton = {
        let btn = AnimatablePlayOrPauseButton(frame: CGRect(origin: .zero, size: CGSize(width: 44, height: 44)), type: .play)
        btn.contentEdgeInsets = UIEdgeInsets(top: 7, left: 7, bottom: 7, right: 7)
        btn.addTarget(self, action: #selector(centerPlayOrPauseAction(_:)), for: .touchUpInside)
        return btn
    }()
    
    /// 锁屏或解锁按钮
    open lazy var lockOrUnlockButton: UIButton = {
        let btn = UIButton(type: .custom)
        btn.setImage(UIImage(inBundle: "player_btn_unlock"), for: .normal)
        btn.setImage(UIImage(inBundle: "player_btn_lock"), for: .selected)
        btn.addTarget(self, action: #selector(lockOrUnlockAction(_:)), for: .touchUpInside)
        return btn
    }()
    
    /// 截屏按钮
    open lazy var snapshotButton: UIButton = {
        let btn = UIButton(type: .custom)
        btn.setImage(UIImage(inBundle: "player_btn_snapshot"), for: .normal)
        btn.addTarget(self, action: #selector(snapshotAction(_:)), for: .touchUpInside)
        return btn
    }()
    
    /// 录制按钮
    open lazy var recordButton: UIButton = {
        let btn = UIButton(type: .custom)
        btn.setImage(UIImage(inBundle: "player_btn_record"), for: .normal)
        btn.addTarget(self, action: #selector(recordAction(_:)), for: .touchUpInside)
        return btn
    }()
    
    /// 失败重新加载按钮
    open lazy var failButton: UIButton = {
        let btn = UIButton(type: .custom)
        btn.setTitle("加载失败，点击重试", for: .normal)
        btn.setTitleColor(.white, for: .normal)
        btn.titleLabel?.font = .systemFont(ofSize: 14)
        btn.backgroundColor = UIColor.black.withAlphaComponent(0.7)
        btn.layer.masksToBounds = true
        btn.addTarget(self, action: #selector(failAction(_:)), for: .touchUpInside)
        return btn
    }()
    
    /// 重播按钮
    open lazy var replayButton: UIButton = {
        let btn = UIButton(type: .custom)
        btn.setImage(UIImage(inBundle: "player_btn_replay"), for: .normal)
        btn.addTarget(self, action: #selector(replayAction(_:)), for: .touchUpInside)
        return btn
    }()
    
    /// 更多内容view
    open lazy var moreContentView: MoreContentView = {
        let moreContentView = MoreContentView()
        moreContentView.delegate = self
        return moreContentView
    }()
    
    /// 加载loading
    open lazy var speedLoading = SpeedLoadingView()
    
    /// 快进、快退view
    open lazy var fastView = FastView()
    
    /// 音量 or 亮度 调节控件
    open lazy var volumeBrightnessView = VolumeBrightnessView()
    
    // MARK: - 🔥Life Cycle🔥
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        initialize()
    }
    
    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        initialize()
    }
    
    deinit {
        cancelAutoHide()
        Log.info("deinit")
    }
    
    private func initialize() {
        addSubviews()
        reset()
    }
    
    private func addSubviews() {
        addSubview(coverImageView)
        
        addSubview(topPanel)
        addSubview(bottomPanel)
        
        addSubview(bottomProgressSlider)
        
        addSubview(moreContentView)
        
        addSubview(centerPlayOrPauseButton)
        
        addSubview(lockOrUnlockButton)
        
        addSubview(snapshotButton)
        addSubview(recordButton)
        
        addSubview(failButton)
        addSubview(replayButton)
        
        addSubview(speedLoading)
        addSubview(fastView)
        addSubview(volumeBrightnessView)
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
        
        let topPanelH: CGFloat = 44 + safeArea.top
        let bottomPanelH: CGFloat = 44 + safeArea.bottom
        let centerButtonH: CGFloat = 44
        
        let topPanelY = isControlsAnimating ? topPanel.y : 0
        let bottomPanelY = isControlsAnimating ? bottomPanel.y : (height - safeArea.bottom - bottomPanelH)
        
        let lockOrUnlockBtnX = isControlsAnimating ? lockOrUnlockButton.x : safeArea.left
        let snapshotBtnX = isControlsAnimating ? snapshotButton.x : width - safeArea.right - centerButtonH
        let recordBtnX = snapshotBtnX
        
        coverImageView.frame = bounds

        topPanel.frame = CGRect(x: 0, y: topPanelY, width: width, height: topPanelH)
        bottomPanel.frame = CGRect(x: 0, y: bottomPanelY, width: width, height: bottomPanelH)
    
        bottomProgressSlider.frame = CGRect(x: safeArea.left, y: height - 2, width: width - safeArea.left - safeArea.right, height: 2)
        
        moreContentView.frame = CGRect(x: width - 330 - safeArea.right, y: 0, width: 330 + safeArea.right, height: height)
        
        centerPlayOrPauseButton.frame = CGRect(x: (width - centerButtonH) / 2, y: (height - centerButtonH) / 2, width: centerButtonH, height: centerButtonH)
        
        lockOrUnlockButton.frame = CGRect(x: lockOrUnlockBtnX, y: (height - centerButtonH) / 2, width: centerButtonH, height: centerButtonH)
        
        if isHiddenRecord {
            snapshotButton.frame = CGRect(x: snapshotBtnX, y: (height - centerButtonH) / 2, width: centerButtonH, height: centerButtonH)
            recordButton.frame = .zero
        } else {
            snapshotButton.frame = CGRect(x: snapshotBtnX, y: centerY - centerButtonH - 10, width: centerButtonH, height: centerButtonH)
            recordButton.frame = CGRect(x: recordBtnX, y: centerY + 10, width: centerButtonH, height: centerButtonH)
        }
        
        failButton.frame = CGRect(x: (width - 140) / 2, y: (height - centerButtonH) / 2, width: 140, height: centerButtonH)
        failButton.layer.cornerRadius = centerButtonH / 2
        
        replayButton.frame = CGRect(x: (width - centerButtonH * 1.5) / 2, y: (height - centerButtonH * 1.5) / 2, width: centerButtonH * 1.5, height: centerButtonH * 1.5)
        
        speedLoading.frame = CGRect(x: (width - 80) / 2, y: (height - 80) / 2, width: 80, height: 80)
        
        fastView.frame = CGRect(x: (width - 160) / 2, y: (height - 130) / 2, width: 160, height: 130)
        
        volumeBrightnessView.frame = CGRect(x: (width - 155) / 2, y: (height - 155) / 2, width: 155, height: 155)
    }
    
    // MARK: - 🔥PlayerControlsable🔥
    
    open weak var delegate: PlayerControlsDelegate?
    
    open weak var playerViewController: PlayerViewController?
    
    // MARK: - 🔥ControlsView Display Helper Props🔥
    
    /// 竖屏是否隐藏返回按钮，默认显示
    open var isHiddenBackForPortrait = false
    
    /// 是否异常录制按钮
    open var isHiddenRecord: Bool = false {
        didSet {
            recordButton.isHidden = isHiddenRecord
            layoutIfNeeded()
            setNeedsLayout()
        }
    }
    
    /// 是否隐藏下一集按钮
    open var isHiddenNext: Bool = true {
        didSet {
            bottomPanel.isHiddenNext = isHiddenNext
        }
    }
    
    /// 是否隐藏 moreContentView
    open var isHiddenMoreContent: Bool {
        get { return moreContentView.isHidden }
        set {
            moreContentView.isHidden = newValue
            if !newValue {
                let volume = playerViewController?.volume ?? 0
                let brightness = playerViewController?.brightness ?? 0
                let rate = playerViewController?.playback?.playbackRate ?? 0
                moreContentView.update(volume: volume, brightness: brightness, rate: rate)
            }
        }
    }
    
    open var isLockScreen: Bool {
        return lockOrUnlockButton.isSelected
    }
    
    /// 控制面板是否显示
    open var isControlsAppeared: Bool = true
    
    /// 是否控制面板正在动画中
    open private(set) var isControlsAnimating = false
    
    /// 是否正在seek
    open private(set) var isSeeking = false
    
    /// 控制层自动隐藏动画时长
    open var autoHideTimeInterval: TimeInterval = 2.5
    
    /// 控制层显示、隐藏动画时长
    open var autoFadeTimeInterval: TimeInterval = 0.25
    
    /// 隐藏控制层任务
    private var _hideControlDispatchWorkItem: DispatchWorkItem?
    
    // MARK: - 🔥ControlsView Display Method🔥
    
    /// 显示控制层
    open func show(animated: Bool) {
        guard !isControlsAppeared else {
            showControls()
            refreshLeftRightButtons()
            refreshStatusBar(false)
            return
        }
        
        delegate?.controls(self, willAppear: animated)
        
        refreshStatusBar(false)
        
        isControlsAnimating = true
        UIView.animate(withDuration: animated ? autoFadeTimeInterval : 0, animations: {
            self.showControls()
        }, completion: { _ in
            self.isControlsAppeared = true
            self.isControlsAnimating = false
            
            self.refreshLeftRightButtons()
            
            self.autoHide()
            
            self.delegate?.controls(self, didAppear: animated)
        })
    }
    
    /// 隐藏控制层
    open func hide(animated: Bool) {
        guard isControlsAppeared else {
            hideControls()
            refreshLeftRightButtons()
            refreshStatusBar(true)
            return
        }
        delegate?.controls(self, willDisAppear: animated)
        
        refreshStatusBar(true)
        isControlsAnimating = true
        UIView.animate(withDuration: animated ? autoFadeTimeInterval : 0, animations: {
            self.hideControls()
        }, completion: { _ in
            self.isControlsAppeared = false
            self.isControlsAnimating = false
            
            self.refreshLeftRightButtons()
            
            self.delegate?.controls(self, didDisAppear: animated)
        })
    }
    
    /// 自动隐藏控制层
    open func autoHide() {
        isControlsAppeared = true
        // 先取消自动隐藏控制层任务
        cancelAutoHide()
        // 再创建自动隐藏控制层任务
        _hideControlDispatchWorkItem = DispatchWorkItem(block: { [weak self] in
            self?.hide(animated: true)
        })
        DispatchQueue.main.asyncAfter(deadline: .seconds(autoHideTimeInterval), execute: _hideControlDispatchWorkItem!)
    }
    
    /// 取消自动隐藏控制层任务
    open func cancelAutoHide() {
        _hideControlDispatchWorkItem?.cancel()
        _hideControlDispatchWorkItem = nil
    }
    
    /// 重置控制层
    open func reset() {
        topPanel.titleLabel.text = ""
        
        bottomPanel.currentTimeLabel.text = "00:00"
        bottomPanel.progressSlider.value = 0
        bottomPanel.progressSlider.bufferValue = 0
        bottomPanel.totalTimeLabel.text = "00:00"
        
        bottomProgressSlider.value = 0
        bottomProgressSlider.bufferValue = 0
        
        centerPlayOrPauseButton.isHidden = false
        
        coverImageView.isHidden = false
    
        failButton.isHidden = true
        replayButton.isHidden = true
        
        moreContentView.isHidden = true
        
        speedLoading.isHidden = true
        fastView.isHidden = true
        
        volumeBrightnessView.isHidden = true
        
        bottomProgressSlider.isHidden = isControlsAppeared
        
        isControlsAppeared ? show(animated: false) : hide(animated: false)
    }
    
    open func showControls() {
        topPanel.subviews.forEach { $0.alpha = 1 }
        
        bottomProgressSlider.isHidden = isLockScreen ? false : true
        
        lockOrUnlockButton.alpha = 1
        lockOrUnlockButton.x = safeArea.left
        
        refreshPortraitLandscapeStyle()
        refreshPlayOrPauseButtonType()
        refreshLockScreenStyle()
    }
    
    open func hideControls() {
        let isPortrait = playerViewController?.isPortrait ?? true
        
        if isPortrait && !isHiddenBackForPortrait {
            topPanel.alpha = 1
            topPanel.subviews.forEach { $0.alpha = ($0 == topPanel.backButton ? 1 : 0) }
        } else {
            topPanel.alpha = 0
            topPanel.y = -topPanel.height
        }
        
        bottomPanel.alpha = 0
        bottomPanel.y = height
        
        lockOrUnlockButton.alpha = 0
        lockOrUnlockButton.x = -lockOrUnlockButton.right
        snapshotButton.alpha = 0
        snapshotButton.x = width
        recordButton.alpha = 0
        recordButton.x = width
        
        isHiddenMoreContent = isPortrait ? true : isHiddenMoreContent
        
        bottomProgressSlider.isHidden = false
    }
    
    /// 刷新锁屏样式
    open func refreshLockScreenStyle() {
        if isLockScreen {
            topPanel.alpha = 0
            topPanel.y = -topPanel.height
            
            bottomPanel.alpha = 0
            bottomPanel.y = height
            
            snapshotButton.alpha = 0
            snapshotButton.x = width
            recordButton.alpha = 0
            recordButton.x = width
        } else {
            topPanel.alpha = 1
            topPanel.y = 0
            
            bottomPanel.alpha = 1
            bottomPanel.y = height - bottomPanel.height
            
            snapshotButton.alpha = 1
            recordButton.alpha = 1
            snapshotButton.x = width - safeArea.right - snapshotButton.width
            recordButton.x = width - safeArea.right - recordButton.width
        }
    }
    
    /// 刷新 锁屏、截屏、录屏按钮
    open func refreshLeftRightButtons() {
        let isPortrait = playerViewController?.isPortrait ?? true
        
        if isLockScreen {
            lockOrUnlockButton.isHidden = !isControlsAppeared
            snapshotButton.isHidden = true
            recordButton.isHidden = true
        } else {
            lockOrUnlockButton.isHidden = isPortrait
            snapshotButton.isHidden = isPortrait
            recordButton.isHidden = isPortrait
        }
    }
    
    /// 刷新状态栏
    open func refreshStatusBar(_ isHidden: Bool) {
        let isPortrait = playerViewController?.isPortrait ?? true
        
        var isStatusBarHidden = isHidden
        if isPortrait {
            isStatusBarHidden = false
        } else {
            if !moreContentView.isHidden {
                isStatusBarHidden = false
            }
        }
        playerViewController?.setStatusBarHidden(isStatusBarHidden)
    }
    
    /// 刷新横竖屏样式
    open func refreshPortraitLandscapeStyle() {
        let isPortrait = playerViewController?.isPortrait ?? true
        
        // 竖屏隐藏 更多相关控件
        topPanel.isHiddenMore = isPortrait
        isHiddenMoreContent = isPortrait ? true : isHiddenMoreContent
        
        // 竖屏使用系统 音量 控件，横屏使用自定义 音量/亮度 控件
        isPortrait ? playerViewController?.volumeKit.addSystemVolumeView() : playerViewController?.volumeKit.removeSystemVolumeView()
        
        // 切换缩放按钮样式
        bottomPanel.fullOrSmallScreenButton.isSelected = !isPortrait
        
        // 竖屏隐藏 下一集按钮
        bottomPanel.isHiddenNext = isPortrait ? true : isHiddenNext
    }
    
    /// 切换播放按钮样式
    open func refreshPlayOrPauseButtonType() {
        let isPlaying = playerViewController?.playback?.isPlaying ?? false
        bottomPanel.playOrPauseButton.type = isPlaying ? .pause : .play
        centerPlayOrPauseButton.type = isPlaying ? .pause : .play
    }
    
    /// 隐藏 播放结束 相关按钮
    open func hideFinishButtons() {
        failButton.isHidden = true
        replayButton.isHidden = true
    }
    
    // MARK: - 🔥Seek🔥
    
    open func showFast(_ isForward: Bool) {
        guard let playback = playerViewController?.playback else { return }
        
        isSeeking = true
        
        show(animated: false)
        cancelAutoHide()
        
        var progress: Float = 0
        var bufferProgress: Float = 0
        if playback.duration > 0 {
            progress = Float(_sumTime / playback.duration)
            bufferProgress = Float(playback.playableDuration / playback.duration)
        }
        
        let currentTime = floor(_sumTime + 0.5).formatTime
        let totalTme = floor(playback.duration + 0.5).formatTime
        
        bottomPanel.progressSlider.value = progress
        bottomProgressSlider.value = progress
        
        bottomPanel.currentTimeLabel.text = currentTime
        
        let text = "\(currentTime) / \(totalTme)"
        
        fastView.show(progress: progress, bufferProgress: bufferProgress, time: text, isForward: isForward)
        UIView.animate(withDuration: fastView.animateDuration) {
            self.bottomPanel.progressSlider.sliderButton.transform = CGAffineTransform(scaleX: 1.5, y: 1.5)
        }
    }
    
    open func hideFast(seekTime: TimeInterval) {
        autoHide()
        
        fastView.hide()
        UIView.animate(withDuration: fastView.animateDuration) {
            self.bottomPanel.progressSlider.sliderButton.transform = .identity
        }
        
        play()
        playerViewController?.playback?.currentPlaybackTime = seekTime
        _sumTime = 0
        
        isSeeking = false
    }
    
    // MARK: - 🔥Play Pause🔥
    
    open func play() {
        guard let playback = playerViewController?.playback else { return }
        
        if playback.isPlayFinishEnded || playback.isPlayFinishError {
            bottomPanel.playOrPauseButton.type = .play
            centerPlayOrPauseButton.type = .play
        } else {
            bottomPanel.playOrPauseButton.type = .pause
            centerPlayOrPauseButton.type = .pause
        }
        
        speedLoading.startAnimating()
        
        playback.play()
    }
    
    open func pause() {
        bottomPanel.playOrPauseButton.type = .play
        centerPlayOrPauseButton.type = .play
        
        speedLoading.stopAnimating()
        
        playerViewController?.playback?.pause()
    }
    
    // MARK: - 🔥Action🔥
    
    @objc
    open func centerPlayOrPauseAction(_ sender: AnimatablePlayOrPauseButton) {
        failButton.isHidden = true
        replayButton.isHidden = true
        centerPlayOrPauseButton.isHidden = true
        
        // 防止快速切换 播放暂停 按钮，造成其显示样式混乱
        guard !bottomPanel.playOrPauseButton.isAnimating && !centerPlayOrPauseButton.isAnimating else { return }
        
        switch sender.type {
        case .pause:
            pause()
            delegate?.controls(self, pauseAction: sender)
        case .play:
            play()
            delegate?.controls(self, playAction: sender)
        }
    }
    
    @objc
    open func lockOrUnlockAction(_ sender: UIButton) {
        sender.isSelected = !sender.isSelected
        show(animated: true)
        if isLockScreen {
            delegate?.controls(self, lockAction: sender)
        } else {
            delegate?.controls(self, unlockAction: sender)
        }
    }
    
    @objc
    open func snapshotAction(_ sender: UIButton) {
       delegate?.controls(self, snapshotAction: sender)
    }
    
    @objc
    open func recordAction(_ sender: UIButton) {
        delegate?.controls(self, recordAction: sender)
    }
    
    @objc
    open func failAction(_ sender: UIButton) {
        play()
        delegate?.controls(self, failAction: sender)
    }
    
    @objc
    open func replayAction(_ sender: UIButton) {
        play()
        delegate?.controls(self, replayAction: sender)
    }
    
    // MARK: - 🔥TopPanelDelegate🔥
    
    open func topPanel(_ topPanel: TopPanel, backAction sender: UIButton) {
        playerViewController?.back(animated: true)
        delegate?.controls(self, backAction: sender)
    }
    
    open func topPanel(_ topPanel: TopPanel, shareAction sender: UIButton) {
        delegate?.controls(self, shareAction: sender)
    }
    
    open func topPanel(_ topPanel: TopPanel, startPIPAction sender: UIButton) {
        playerViewController?.pictureInPictureController.startPictureInPicture(animated: true)
        delegate?.controls(self, startPictureInPictureAction: sender)
    }
    
    open func topPanel(_ topPanel: TopPanel, moreAction sender: UIButton) {
        isHiddenMoreContent = !isHiddenMoreContent
        hide(animated: false)
        playerViewController?.setStatusBarHidden(false)
        delegate?.controls(self, moreAction: sender)
    }
    
    // MARK: - 🔥BottomPanelDelegate🔥
    
    open func bottomPanel(_ bottomPanel: BottomPanel, playOrPauseAction sender: AnimatablePlayOrPauseButton) {
        failButton.isHidden = true
        replayButton.isHidden = true
        centerPlayOrPauseButton.isHidden = true
        
        // 防止快速切换 播放暂停 按钮，造成其显示样式混乱
        guard !bottomPanel.playOrPauseButton.isAnimating && !centerPlayOrPauseButton.isAnimating else { return }
        
        switch sender.type {
        case .pause:
            pause()
            delegate?.controls(self, pauseAction: sender)
        case .play:
            play()
            delegate?.controls(self, playAction: sender)
        }
    }
    
    open func bottomPanel(_ bottomPanel: BottomPanel, fullOrSmallScreenAction sender: UIButton) {
        guard let playerViewController = playerViewController else { return }
        
        let flag = sender.isSelected
        
        if flag {
            playerViewController.setOrientation(.portrait)
            delegate?.controls(self, smallScreenAction: sender)
        } else {
            playerViewController.setOrientation(.landscapeRight)
            delegate?.controls(self, fullScreenAction: sender)
        }
    }
    
    open func bottomPanel(_ bottomPanel: BottomPanel, nextAction sender: UIButton) {
        delegate?.controls(self, nextAction: sender)
    }
    
    open func bottomPanel(_ bottomPanel: BottomPanel, sliderTouchBegin slider: BufferSlider, value: Float) {
        delegate?.controls(self, sliderBegin: slider, progress: value)
    }
    
    open func bottomPanel(_ bottomPanel: BottomPanel, sliderValueChanged slider: BufferSlider, value: Float) {
        guard let playback = playerViewController?.playback else { return }
        if playback.duration == 0 { return }
        
        _sumTime = Double(value) * playback.duration
        
        showFast(slider.isForward)
        
        delegate?.controls(self, sliderChanged: slider, progress: value, isForword: slider.isForward)
    }
    
    open func bottomPanel(_ bottomPanel: BottomPanel, sliderTouchEnd slider: BufferSlider, value: Float) {
        guard let playback = playerViewController?.playback else { return }
        if playback.duration == 0 { return }
        
        hideFast(seekTime: _sumTime)
        
        delegate?.controls(self, sliderEnd: slider, progress: value)
    }
    
    open func bottomPanel(_ bottomPanel: BottomPanel, sliderTouchClicked slider: BufferSlider, value: Float) {
        guard let playback = playerViewController?.playback else { return }
        if playback.duration == 0 { return }
        
        hideFast(seekTime: Double(value) * playback.duration)
        
        delegate?.controls(self, sliderClicked: slider, progress: value)
    }
   
    // MARK: - 🔥MoreContentViewDelegate🔥
    
    open func moreContentView(_ moreContentView: MoreContentView, volumeDidChange volume: CGFloat) {
        playerViewController?.volume = volume
    }
    
    open func moreContentView(_ moreContentView: MoreContentView, brightnessDidChange brightness: CGFloat) {
        playerViewController?.brightness = brightness
    }
    
    open func moreContentView(_ moreContentView: MoreContentView, playRateDidChange rate: Float) {
        playerViewController?.playback?.playbackRate = rate
    }
    
    // MARK: - 🔥PlayerVolumeable🔥
    
    open func playerViewController(_ playerViewController: PlayerViewController, systemVolumeDidChange value: CGFloat) {
        if !isHiddenMoreContent {
            playerViewController.volumeKit.removeSystemVolumeView()
            moreContentView.update(volume: value, brightness: playerViewController.brightness, rate: playerViewController.playback?.playbackRate ?? 0)
        } else {
            if playerViewController.isLandscape {
                volumeBrightnessView.update(.volume, value: value)
                playerViewController.volumeKit.removeSystemVolumeView()
            } else {
                playerViewController.volumeKit.addSystemVolumeView()
            }
        }
    }
    
    // MARK: - 🔥PlayerRotateable🔥
    
    open func playerViewController(_ playerViewController: PlayerViewController, deviceOrientationChange orientation: UIInterfaceOrientation) {
        if playerViewController.visibleViewController.shouldAutorotate {
            if isControlsAppeared {
                hide(animated: false)
                // 防止旋转过程中重新layout布局错乱
                DispatchQueue.main.asyncAfter(deadline: .seconds(0.2)) {
                    self.show(animated: false)
                }
            } else {
                hide(animated: false)
            }
        }
    }
    
    open func playerViewController(_ playerViewController: PlayerViewController, willForceRotate orientation: UIInterfaceOrientation) {
        if playerViewController.rotateManager.shouldForceAutorotate {
            isControlsAppeared ? show(animated: false) : hide(animated: false)
        }
    }
    
    open func playerViewController(_ playerViewController: PlayerViewController, didForceRotate orientation: UIInterfaceOrientation) {
        if playerViewController.rotateManager.shouldForceAutorotate {
            isControlsAppeared ? show(animated: false) : hide(animated: false)
        }
    }
    
    // MARK: - 🔥PlayerPictureInPictureable🔥
    
//    open func playerViewControllerWillStartPictureInPicture(_ playerViewController: PlayerViewController) { }
//    open func playerViewControllerDidStartPictureInPicture(_ playerViewController: PlayerViewController) {}
//    open func playerViewController(_ playerViewController: PlayerViewController, failedToStartPictureInPictureWithError error: PlayerPictureInPictureError) { }
//    open func playerViewControllerWillStopPictureInPicture(_ playerViewController: PlayerViewController) { }
//    open func playerViewControllerDidStopPictureInPicture(_ playerViewController: PlayerViewController) { }
//    open func playerViewController(_ playerViewController: PlayerViewController, failedToStopPictureInPictureWithError error: PlayerPictureInPictureError) { }
    
    // MARK: - 🔥PlayerGestureable🔥
    
    private var _sumTime: TimeInterval = 0
    
    open func playerViewController(_ playerViewController: PlayerViewController, shouldReceive gestureRecognizer: UIGestureRecognizer, touch: UITouch, type: PlayerGestureType) -> Bool {
        
        // 排除进度拖动条范围内手势
        let loc = touch.location(in: self)
        let sliderRect = bottomPanel.convert(bottomPanel.progressSlider.frame, to: self)
        if sliderRect.contains(loc) {
            return false
        }
        
        // 锁屏 or 需手动播放 or 显示moreContentView 时，仅响应单击手势
        if (isLockScreen || !centerPlayOrPauseButton.isHidden || !isHiddenMoreContent) && type != .singleTap {
            return false
        }
        
        return true
    }
    
    open func playerViewController(_ playerViewController: PlayerViewController, singleTap gestureRecognizer: UITapGestureRecognizer) {
        if !isHiddenMoreContent {
            isHiddenMoreContent = !isHiddenMoreContent
            show(animated: false)
        } else {
            if isControlsAppeared {
                hide(animated: true)
            } else {
                hide(animated: false)
                show(animated: true)
            }
        }
    }
    
    open func playerViewController(_ playerViewController: PlayerViewController, doubleTap gestureRecognizer: UITapGestureRecognizer) {
        failButton.isHidden = true
        replayButton.isHidden = true
        centerPlayOrPauseButton.isHidden = true
        
        // 防止快速切换 播放暂停 按钮，造成其显示样式混乱
        guard !bottomPanel.playOrPauseButton.isAnimating && !centerPlayOrPauseButton.isAnimating else { return }
        
        switch bottomPanel.playOrPauseButton.type {
        case .pause:
            pause()
        case .play:
            play()
        }
    }
    
    open func playerViewController(_ playerViewController: PlayerViewController, beganPan gestureRecognizer: UIPanGestureRecognizer, direction: PlayerPanDirection, location: PlayerPanLocation) {
        if direction == .hor {
            _sumTime = playerViewController.playback?.currentPlaybackTime ?? 0
        }
    }
    
    open func playerViewController(_ playerViewController: PlayerViewController, changedPan gestureRecognizer: UIPanGestureRecognizer, direction: PlayerPanDirection, location: PlayerPanLocation, movingDirection: PlayerPanMovingDirection) {
        
        let velocity = gestureRecognizer.velocity(in: gestureRecognizer.view)
        
        switch direction {
        case .unknown:
            break
        case .ver:
            guard playerViewController.isLandscape else { return }
            
            switch location {
            case .unknown:
                break
            case .left:
                // 调节亮度
                playerViewController.brightness -= (velocity.y) / 10000
                volumeBrightnessView.type = .brightness
                volumeBrightnessView.value = playerViewController.brightness
            case .right:
                // 调节音量
                playerViewController.volume -= (velocity.y) / 10000
                volumeBrightnessView.type = .volume
                volumeBrightnessView.value = playerViewController.volume
            }
        case .hor:
            _sumTime += TimeInterval(velocity.x / 200)
            let duration = playerViewController.playback?.duration ?? 0
            if duration == 0 { return }
            _sumTime = min(max(0, _sumTime), duration)
            
            if velocity.x == 0 { return }
            let isForward = velocity.x > 0
            
            showFast(isForward)
        }
    }
    
    open func playerViewController(_ playerViewController: PlayerViewController, endedPan gestureRecognizer: UIPanGestureRecognizer, direction: PlayerPanDirection, location: PlayerPanLocation) {
        if direction == .hor {
            hideFast(seekTime: _sumTime)
        }
    }
    
    open func playerViewController(_ playerViewController: PlayerViewController, pinch gestureRecognizer: UIPinchGestureRecognizer, scale: CGFloat) {
        playerViewController.playback?.scalingMode = scale > 1 ? .aspectFill : .aspectFit
    }
    
    // MARK: - 🔥PlayerPlaybackable🔥
    
    open func playerViewController(_ playerViewController: PlayerViewController, prepareToPlay contentURL: URL) {
        guard let playback = playerViewController.playback else { return }
        
        if playback.shouldAutoplay {
            centerPlayOrPauseButton.isHidden = true
            speedLoading.startAnimating()
        }
    }
    
    open func playerViewController(_ playerViewController: PlayerViewController, isPreparedToPlay contentURL: URL) {
        hide(animated: false)
    }
    
    open func playerViewController(_ playerViewController: PlayerViewController, durationDidAvailate duration: TimeInterval) {
        bottomPanel.totalTimeLabel.text = floor(duration + 0.5).formatTime
    }
    
//    open func playerViewController(_ playerViewController: PlayerViewController, naturalSizeDidAvailate naturalSize: CGSize) { }
    
    open func playerViewController(_ playerViewController: PlayerViewController, firstRender firstRenderType: PlayerRenderType) {
        if firstRenderType == .video {
            coverImageView.isHidden = true
            centerPlayOrPauseButton.isHidden = true
            hide(animated: false)
        }
    }
    
//    open func playerViewController(_ playerViewController: PlayerViewController, scalingModeDidChange scalingMode: PlayerScalingMode) { }
    
    open func playerViewController(_ playerViewController: PlayerViewController, playbackStateDidChange playbackState: PlayerPlaybackState) {
        guard let playback = playerViewController.playback else { return }
        switch playbackState {
        case .playing:
            let loadState = playback.loadState
            if loadState.contains(.stalled) || loadState.isEmpty {
                speedLoading.startAnimating()
            } else {
                speedLoading.stopAnimating()
            }
            
            bottomPanel.playOrPauseButton.type = .pause
            centerPlayOrPauseButton.type = .pause
            
            failButton.isHidden = true
            replayButton.isHidden = true
        case .paused:
            speedLoading.stopAnimating()
            
            bottomPanel.playOrPauseButton.type = .play
            centerPlayOrPauseButton.type = .play
            
            failButton.isHidden = true
            replayButton.isHidden = true
        case .interrupted, .stopped:
            speedLoading.stopAnimating()
            
            bottomPanel.playOrPauseButton.type = .play
            centerPlayOrPauseButton.type = .play
            
            if let playback = playerViewController.playback {
                if playback.isPlayFinishEnded {
                    failButton.isHidden = true
                    replayButton.isHidden = false
                } else if playback.isPlayFinishError {
                    failButton.isHidden = false
                    replayButton.isHidden = true
                } else {
                    failButton.isHidden = false
                    replayButton.isHidden = true
                }
            }
        case .seekingForward, .seekingBackward:
            failButton.isHidden = true
            replayButton.isHidden = true
        }
    }
    
    open func playerViewController(_ playerViewController: PlayerViewController, loadStateDidChange loadState: PlayerLoadState) {
        guard let playback = playerViewController.playback else { return }
        
        if loadState.isEmpty {
            coverImageView.isHidden = false
        } else if loadState.contains(.playthroughOK) {
            coverImageView.isHidden = true
        }
        
        if playback.isPlaying && (loadState.contains(.stalled) || loadState.isEmpty) {
            speedLoading.startAnimating()
        } else {
            speedLoading.stopAnimating()
        }
    }
    
    open func playerViewController(_ playerViewController: PlayerViewController, currentPlaybackTimeDidChange currentPlaybackTime: TimeInterval, duration: TimeInterval) {
        if currentPlaybackTime > 0 {
            coverImageView.isHidden = true
            centerPlayOrPauseButton.isHidden = true
            
            bottomPanel.playOrPauseButton.type = .pause
            centerPlayOrPauseButton.type = .pause
        }
        
        if isSeeking {
            speedLoading.startAnimating()
        } else {
            fastView.hide()
            speedLoading.stopAnimating()
            
            bottomPanel.currentTimeLabel.text = floor(currentPlaybackTime + 0.5).formatTime
            bottomPanel.totalTimeLabel.text = floor(duration + 0.5).formatTime
            
            let playProgress = Float(duration > 0 ? (currentPlaybackTime / duration) : 0)
            bottomPanel.progressSlider.value = playProgress
            bottomProgressSlider.value = playProgress
        }
    }
    
    open func playerViewController(_ playerViewController: PlayerViewController, playableDurationDidChange playableDuration: TimeInterval, duration: TimeInterval) {
        let bufferProgress = Float(duration > 0 ? (playableDuration / duration) : 0)
        bottomPanel.progressSlider.bufferValue = bufferProgress
        bottomProgressSlider.bufferValue = bufferProgress
    }
    
    open func playerViewController(_ playerViewController: PlayerViewController, seekDidComplete seekDuration: TimeInterval, duration: TimeInterval, isAccurate: Bool, error: Error?) {
        UIView.animate(withDuration: self.autoFadeTimeInterval) {
            self.bottomPanel.progressSlider.sliderButton.transform = .identity
        }
        autoHide()
    }
    
    open func playerViewController(_ playerViewController: PlayerViewController, didFinish reason: PlayerFinishReason, error: Error?) {
        switch reason {
        case .playbackEnded:
            replayButton.isHidden = false
            failButton.isHidden = true
        case .playbackError:
            replayButton.isHidden = true
            failButton.isHidden = false
        case .userExited:
            replayButton.isHidden = true
            failButton.isHidden = true
        }
        
        centerPlayOrPauseButton.isHidden = true
        bottomPanel.playOrPauseButton.type = .play
        centerPlayOrPauseButton.type = .play
        speedLoading.stopAnimating()
    }
}
