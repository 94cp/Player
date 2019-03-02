//
//  PlayerPictureInPictureControlsView.swift
//  Player
//
//  Created by chenp on 2018/11/10.
//  Copyright © 2018年 chenp. All rights reserved.
//

import UIKit
import PlayerCore

open class PlayerPictureInPictureControlsView: UIView, PlayerControlsable {
    
    /// 封面图
    open lazy var coverImageView: UIImageView = {
        let coverImageView = UIImageView()
        coverImageView.contentMode = .scaleAspectFit
        return coverImageView
    }()

    /// 画中画按钮
    open lazy var stopPipButton: UIButton = {
        let btn = UIButton(type: .custom)
        btn.setImage(UIImage(inBundle: "player_btn_pip"), for: .normal)
        btn.addTarget(self, action: #selector(stopPipAction(_:)), for: .touchUpInside)
        return btn
    }()

    /// 播放或暂停按钮
    open lazy var playOrPauseButton: AnimatablePlayOrPauseButton = {
        let btn = AnimatablePlayOrPauseButton(frame: CGRect(origin: .zero, size: CGSize(width: 44, height: 44)), type: .play)
        btn.contentEdgeInsets = UIEdgeInsets(top: 14, left: 14, bottom: 14, right: 14)
        btn.addTarget(self, action: #selector(playOrPauseAction(_:)), for: .touchUpInside)
        return btn
    }()
    
    /// 关闭按钮
    open lazy var closeButton: UIButton = {
        let btn = UIButton(type: .custom)
        btn.setImage(UIImage(inBundle: "player_btn_close"), for: .normal)
        btn.addTarget(self, action: #selector(closeAction(_:)), for: .touchUpInside)
        return btn
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
    
    /// 加载loading
    open lazy var speedLoading = SpeedLoadingView()
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        initialize()
    }
    
    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        initialize()
    }
    
    private func initialize() {
        addSubview(coverImageView)
        
        addSubview(stopPipButton)
        addSubview(playOrPauseButton)
        addSubview(closeButton)
        
        addSubview(bottomProgressSlider)
        addSubview(speedLoading)
    }
    
    deinit {
        cancelAutoHide()
        Log.info("deinit")
    }
    
    open override func layoutSubviews() {
        super.layoutSubviews()
        
        coverImageView.frame = bounds
        
        let btnWH: CGFloat = 44
        let margin: CGFloat = 10
        
        let x = (width - btnWH * 3 - margin * 2) / 2
        let y = height - btnWH - margin
        stopPipButton.frame = CGRect(x: x, y: y, width: btnWH, height: btnWH)
        playOrPauseButton.frame = CGRect(x: stopPipButton.right + margin, y: y, width: btnWH, height: btnWH)
        closeButton.frame = CGRect(x: playOrPauseButton.right + margin, y: y, width: btnWH, height: btnWH)
        
        bottomProgressSlider.frame = CGRect(x: 0, y: height - 2, width: width, height: 2)
        
        speedLoading.frame = CGRect(x: (width - 80) / 2, y: (height - 80) / 2, width: 80, height: 80)
    }
    
    // MARK: - 🔥PlayerControlsable🔥
    
    open weak var delegate: PlayerControlsDelegate?
    
    open weak var playerViewController: PlayerViewController?
    
    // MARK: - 🔥Action🔥

    @objc
    open func stopPipAction(_ sender: UIButton) {
        playerViewController?.pictureInPictureController.stopPictureInPicture(animated: true)
        delegate?.controls(self, stopPictureInPictureAction: sender)
    }
    
    @objc
    open func playOrPauseAction(_ sender: AnimatablePlayOrPauseButton) {
        guard let playback = playerViewController?.playback else { return }
        if playOrPauseButton.isAnimating { return }
        
        switch sender.type {
        case .pause:
            playOrPauseButton.type = .play
            playerViewController?.playback?.pause()
            
            speedLoading.stopAnimating()
            
            delegate?.controls(self, pauseAction: sender)
        case .play:
            if playback.isPlayFinishEnded || playback.isPlayFinishError {
                playOrPauseButton.type = .play
                show(animated: false)
                cancelAutoHide()
            } else {
                playOrPauseButton.type = .pause
                hide(animated: false)
            }
            
            playback.play()
            
            speedLoading.startAnimating()
            
            delegate?.controls(self, playAction: sender)
        }
    }
    
    @objc
    open func closeAction(_ sender: UIButton) {
        playerViewController?.close(animated: true)
        delegate?.controls(self, closeAction: sender)
    }
    
    // MARK: - 🔥ControlsView Show / Hide🔥
    
    /// 控制面板是否显示
    open var isControlsAppeared: Bool = true
    
    open private(set) var isControlsAnimating = false
    
    /// 控制层自动隐藏动画时长
    open var autoHideTimeInterval: TimeInterval = 2.5
    
    /// 控制层显示、隐藏动画时长
    open var autoFadeTimeInterval: TimeInterval = 0.25
    
    /// 隐藏控制层任务
    private var _hideControlDispatchWorkItem: DispatchWorkItem?
    
    /// 显示控制层
    open func show(animated: Bool) {
        if isControlsAppeared {
            showControls()
            return
        }
        
        delegate?.controls(self, willAppear: animated)
        
        isControlsAnimating = true
        
        UIView.animate(withDuration: animated ? autoFadeTimeInterval : 0, animations: {
            self.showControls()
        }, completion: { _ in
            self.isControlsAppeared = true
            self.isControlsAnimating = false
            
            self.autoHide()
            
            self.delegate?.controls(self, didAppear: animated)
        })
    }
    
    open func showControls() {
        stopPipButton.alpha = 1
        playOrPauseButton.alpha = 1
        closeButton.alpha = 1
        bottomProgressSlider.alpha = 1
    }
    
    /// 隐藏控制层
    open func hide(animated: Bool) {
        if !isControlsAppeared {
            hideControls()
            return
        }
        
        delegate?.controls(self, willDisAppear: animated)
        
        isControlsAnimating = true
        
        UIView.animate(withDuration: animated ? autoFadeTimeInterval : 0, animations: {
            self.hideControls()
        }, completion: { _ in
            self.isControlsAppeared = false
            self.isControlsAnimating = false
            
            self.delegate?.controls(self, didDisAppear: animated)
        })
    }
    
    open func hideControls() {
        stopPipButton.alpha = 0
        playOrPauseButton.alpha = 0
        closeButton.alpha = 0
        bottomProgressSlider.alpha = 0
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
    
    // MARK: - 🔥PlayerVolumeable🔥
    
    open func playerViewController(_ playerViewController: PlayerViewController, systemVolumeDidChange value: CGFloat) {
        playerViewController.volumeKit.removeSystemVolumeView()
    }
    
    // MARK: - 🔥PlayerPictureInPictureable🔥
    
    open func playerViewControllerDidStartPictureInPicture(_ playerViewController: PlayerViewController) {
        guard let playback = playerViewController.playback else { return }
        
        if playback.isPlaying {
            hide(animated: false)
            playOrPauseButton.type = .pause
            coverImageView.isHidden = true
        } else {
            show(animated: true)
            cancelAutoHide()
            playOrPauseButton.type = .play
            coverImageView.isHidden = false
        }
        speedLoading.stopAnimating()
    }

    // MARK: - 🔥PlayerGestureable🔥
    
    open func playerViewController(_ playerViewController: PlayerViewController, shouldReceive gestureRecognizer: UIGestureRecognizer, touch: UITouch, type: PlayerGestureType) -> Bool {
        return type == .singleTap
    }
    
    open func playerViewController(_ playerViewController: PlayerViewController, singleTap gestureRecognizer: UITapGestureRecognizer) {
        if isControlsAppeared {
            hide(animated: true)
        } else {
            hide(animated: false)
            show(animated: true)
        }
    }
    
    // MARK: - 🔥PlayerPlaybackable🔥
    
    open func playerViewController(_ playerViewController: PlayerViewController, prepareToPlay contentURL: URL) {
        guard let playback = playerViewController.playback else { return }
        
        if playback.shouldAutoplay {
            speedLoading.startAnimating()
        }
    }
    
    open func playerViewController(_ playerViewController: PlayerViewController, isPreparedToPlay contentURL: URL) {
        hide(animated: false)
    }
    
    open func playerViewController(_ playerViewController: PlayerViewController, firstRender firstRenderType: PlayerRenderType) {
        if firstRenderType == .video {
            coverImageView.isHidden = true
            hide(animated: false)
        }
    }
    
    open func playerViewController(_ playerViewController: PlayerViewController, playbackStateDidChange playbackState: PlayerPlaybackState) {
        guard let playback = playerViewController.playback else { return }
        
        switch playback.playbackState {
        case .playing:
            playOrPauseButton.type = .pause
            
            let loadState = playback.loadState
            if loadState.contains(.stalled) || loadState.isEmpty {
                speedLoading.startAnimating()
            } else {
                speedLoading.stopAnimating()
            }
        case .paused:
            playOrPauseButton.type = .play
            speedLoading.stopAnimating()
        case .interrupted, .stopped:
            speedLoading.stopAnimating()
            
            playOrPauseButton.type = .play
            
            if playback.isPlayFinishEnded || playback.isPlayFinishError {
                show(animated: false)
                cancelAutoHide()
            }
        case .seekingForward, .seekingBackward:
            break
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
        coverImageView.isHidden = true
        playOrPauseButton.type = .pause
        speedLoading.stopAnimating()
        
        let playProgress = Float(duration > 0 ? (currentPlaybackTime / duration) : 0)
        bottomProgressSlider.value = playProgress
    }
    
    open func playerViewController(_ playerViewController: PlayerViewController, playableDurationDidChange playableDuration: TimeInterval, duration: TimeInterval) {
        let bufferProgress = Float(duration > 0 ? (playableDuration / duration) : 0)
        bottomProgressSlider.bufferValue = bufferProgress
    }
    
    open func playerViewController(_ playerViewController: PlayerViewController, didFinish reason: PlayerFinishReason, error: Error?) {
        playOrPauseButton.type = .play
        speedLoading.stopAnimating()
        show(animated: false)
        cancelAutoHide()
    }
}
