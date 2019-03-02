//
//  BottomPanel.swift
//  Player
//
//  Created by chenp on 2018/9/20.
//  Copyright © 2018年 chenp. All rights reserved.
//

import UIKit

open class BottomPanel: UIView, BufferSliderDelegate {

    /// 底部工具栏的背景图片
    open lazy var bottomBackgroundImageView: UIImageView = {
        let iv = UIImageView()
        iv.image = UIImage(inBundle: "player_bg_shadow_bottom")
        return iv
    }()
    /// 播放或暂停按钮
    open lazy var playOrPauseButton: AnimatablePlayOrPauseButton = {
        let btn = AnimatablePlayOrPauseButton(frame: CGRect(origin: .zero, size: CGSize(width: 44, height: 44)), type: .play)
        btn.contentEdgeInsets = UIEdgeInsets(top: 14, left: 14, bottom: 14, right: 14)
        btn.addTarget(self, action: #selector(playOrPauseAction(_:)), for: .touchUpInside)
        return btn
    }()
    
    open lazy var nextButton: UIButton = {
        let btn = UIButton(type: .custom)
        btn.setImage(UIImage(inBundle: "player_btn_next"), for: .normal)
        btn.addTarget(self, action: #selector(nextAction(_:)), for: .touchUpInside)
        return btn
    }()
    
    /// 当前播放时间
    open lazy var currentTimeLabel: UILabel = {
        let lbl = UILabel()
        lbl.text = "00:00"
        lbl.textColor = .white
        lbl.font = UIFont.systemFont(ofSize: 14)
        lbl.textAlignment = .center
        return lbl
    }()
    /// 播放进度条
    open lazy var progressSlider: BufferSlider = {
        let slider = BufferSlider()
        slider.minimumValueImage = UIImage(inBundle: "player_bg_progress_min")
        slider.bufferTrackTintColor = .gray
        slider.maximumTrackTintColor = UIColor.black.withAlphaComponent(0.6)
        slider.setThumbImage(UIImage(inBundle: "player_btn_progress_point"), for: .normal)
        slider.sliderHeight = 2.0
        slider.delegate = self
        return slider
    }()
    /// 视频总时间
    open lazy var totalTimeLabel: UILabel = {
        let lbl = UILabel()
        lbl.text = "00:00"
        lbl.textColor = .white
        lbl.font = UIFont.systemFont(ofSize: 14)
        lbl.textAlignment = .center
        return lbl
    }()
    /// 全屏或小屏按钮
    open lazy var fullOrSmallScreenButton: UIButton = {
        let btn = UIButton(type: .custom)
        btn.setImage(UIImage(inBundle: "player_btn_full_screen"), for: .normal)
        btn.setImage(UIImage(inBundle: "player_btn_small_screen"), for: .selected)
        btn.addTarget(self, action: #selector(fullOrSmallScreenAction(_:)), for: .touchUpInside)
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
        addSubview(bottomBackgroundImageView)
        addSubview(playOrPauseButton)
        addSubview(nextButton)
        addSubview(currentTimeLabel)
        addSubview(progressSlider)
        addSubview(fullOrSmallScreenButton)
        addSubview(totalTimeLabel)
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
        
        let bottomPanelH = bounds.height - safeArea.bottom
        let timeLabelW: CGFloat = 64
        
        bottomBackgroundImageView.frame = bounds
        playOrPauseButton.frame = CGRect(x: safeArea.left, y: 0, width: bottomPanelH, height: bottomPanelH)
        
        if isHiddenNext {
            nextButton.frame = .zero
            currentTimeLabel.frame = CGRect(x: playOrPauseButton.right, y: 0, width: timeLabelW, height: bottomPanelH)
        } else {
            nextButton.frame = CGRect(x: playOrPauseButton.right, y: 0, width: bottomPanelH, height: bottomPanelH)
            currentTimeLabel.frame = CGRect(x: nextButton.right, y: 0, width: timeLabelW, height: bottomPanelH)
        }
        
        fullOrSmallScreenButton.frame = CGRect(x: width - safeArea.right - bottomPanelH, y: 0, width: bottomPanelH, height: bottomPanelH)
        totalTimeLabel.frame = CGRect(x: fullOrSmallScreenButton.left - timeLabelW, y: 0, width: timeLabelW, height: bottomPanelH)
        progressSlider.frame = CGRect(x: currentTimeLabel.right, y: 0, width: totalTimeLabel.left - currentTimeLabel.right, height: bottomPanelH)
    }
    
    open var isHiddenNext: Bool = false {
        didSet {
            nextButton.isHidden = isHiddenNext
            layoutIfNeeded()
            setNeedsLayout()
        }
    }
    
    open weak var delegate: BottomPanelDelegate?
    
    @objc
    open func playOrPauseAction(_ sender: AnimatablePlayOrPauseButton) {
        delegate?.bottomPanel(self, playOrPauseAction: sender)
    }
    
    @objc
    open func nextAction(_ sender: UIButton) {
        delegate?.bottomPanel(self, nextAction: sender)
    }
    
    @objc
    open func fullOrSmallScreenAction(_ sender: UIButton) {
       delegate?.bottomPanel(self, fullOrSmallScreenAction: sender)
    }
    
    // MARK: - 🔥BufferSlider🔥
    
    open func slider(_ slider: BufferSlider, touchBegin value: Float) {
        delegate?.bottomPanel(self, sliderTouchBegin: slider, value: value)
    }
    
    open func slider(_ slider: BufferSlider, valueChanged value: Float) {
        delegate?.bottomPanel(self, sliderValueChanged: slider, value: value)
    }
    
    open func slider(_ slider: BufferSlider, touchEnd value: Float) {
        delegate?.bottomPanel(self, sliderTouchEnd: slider, value: value)
    }
    
    open func slider(_ slider: BufferSlider, clicked value: Float) {
        delegate?.bottomPanel(self, sliderTouchClicked: slider, value: value)
    }
}

public protocol BottomPanelDelegate: class {
    func bottomPanel(_ bottomPanel: BottomPanel, playOrPauseAction sender: AnimatablePlayOrPauseButton)
    func bottomPanel(_ bottomPanel: BottomPanel, fullOrSmallScreenAction sender: UIButton)
    func bottomPanel(_ bottomPanel: BottomPanel, nextAction sender: UIButton)
    
    func bottomPanel(_ bottomPanel: BottomPanel, sliderTouchBegin slider: BufferSlider, value: Float)
    func bottomPanel(_ bottomPanel: BottomPanel, sliderValueChanged slider: BufferSlider, value: Float)
    func bottomPanel(_ bottomPanel: BottomPanel, sliderTouchEnd slider: BufferSlider, value: Float)
    func bottomPanel(_ bottomPanel: BottomPanel, sliderTouchClicked slider: BufferSlider, value: Float)
}

extension BottomPanelDelegate {
    public func bottomPanel(_ bottomPanel: BottomPanel, playOrPauseAction sender: AnimatablePlayOrPauseButton) {}
    public func bottomPanel(_ bottomPanel: BottomPanel, fullOrSmallScreenAction sender: UIButton) {}
    public func bottomPanel(_ bottomPanel: BottomPanel, nextAction sender: UIButton) {}
    
    public func bottomPanel(_ bottomPanel: BottomPanel, sliderTouchBegin slider: BufferSlider, value: Float) {}
    public func bottomPanel(_ bottomPanel: BottomPanel, sliderValueChanged slider: BufferSlider, value: Float) {}
    public func bottomPanel(_ bottomPanel: BottomPanel, sliderTouchEnd slider: BufferSlider, value: Float) {}
    public func bottomPanel(_ bottomPanel: BottomPanel, sliderTouchClicked slider: BufferSlider, value: Float) {}
}
