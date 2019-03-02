//
//  MoreContentView.swift
//  Player
//
//  Created by chenp on 2018/9/26.
//  Copyright © 2018年 chenp. All rights reserved.
//

import UIKit

open class MoreContentView: UIView, BufferSliderDelegate {
    
    open lazy var volumeView = UIView()
    
    open lazy var volumeLabel: UILabel = {
        let lbl = UILabel()
        lbl.text = "音量"
        lbl.textColor = .white
        return lbl
    }()
    
    lazy var volumeMinImageView: UIImageView = UIImageView(image: UIImage(inBundle: "player_icon_volume_min"))
    
    lazy var volumeMaxImageView: UIImageView = UIImageView(image: UIImage(inBundle: "player_icon_volume_max"))
    
    open lazy var volumeSlider: BufferSlider = {
        let slider = BufferSlider()
        slider.minimumValueImage = UIImage(inBundle: "player_bg_progress_min")
        slider.bufferTrackTintColor = .gray
        slider.maximumTrackTintColor = UIColor.black.withAlphaComponent(0.6)
        slider.setThumbImage(UIImage(inBundle: "player_btn_progress_point"), for: .normal)
        slider.sliderHeight = 2.0
        slider.delegate = self
        return slider
    }()
    
    open lazy var brightnessView = UIView()
    
    open lazy var brightnessLabel: UILabel = {
        let lbl = UILabel()
        lbl.text = "亮度"
        lbl.textColor = .white
        return lbl
    }()
    
    lazy var brightnessMinImageView: UIImageView = UIImageView(image: UIImage(inBundle: "player_icon_brightness_min"))
    
    lazy var brightnessMaxImageView: UIImageView = UIImageView(image: UIImage(inBundle: "player_icon_brightness_max"))
    
    open lazy var brightnessSlider: BufferSlider = {
        let slider = BufferSlider()
        slider.minimumValueImage = UIImage(inBundle: "player_bg_progress_min")
        slider.bufferTrackTintColor = .gray
        slider.maximumTrackTintColor = UIColor.black.withAlphaComponent(0.6)
        slider.setThumbImage(UIImage(inBundle: "player_btn_progress_point"), for: .normal)
        slider.sliderHeight = 2.0
        slider.delegate = self
        return slider
    }()
    
    open lazy var rateView = UIView()
    
    open lazy var rateLabel: UILabel = {
        let lbl = UILabel()
        lbl.text = "倍速"
        lbl.textColor = .white
        return lbl
    }()
    
    lazy var rate0_5Button: UIButton = { // swiftlint:disable:this identifier_name
        let btn = UIButton(type: .custom)
        btn.setTitle("0.5X", for: .normal)
        btn.setTitleColor(.white, for: .normal)
        btn.setTitleColor(rateSelectedColor, for: .selected)
        btn.addTarget(self, action: #selector(rateAction(_:)), for: .touchUpInside)
        return btn
    }()
    
    lazy var rate1_0Button: UIButton = { // swiftlint:disable:this identifier_name
        let btn = UIButton(type: .custom)
        btn.setTitle("1.0X", for: .normal)
        btn.isSelected = true
        btn.setTitleColor(.white, for: .normal)
        btn.setTitleColor(rateSelectedColor, for: .selected)
        btn.addTarget(self, action: #selector(rateAction(_:)), for: .touchUpInside)
        return btn
    }()
    
    lazy var rate1_25Button: UIButton = { // swiftlint:disable:this identifier_name
        let btn = UIButton(type: .custom)
        btn.setTitle("1.25X", for: .normal)
        btn.setTitleColor(.white, for: .normal)
        btn.setTitleColor(rateSelectedColor, for: .selected)
        btn.addTarget(self, action: #selector(rateAction(_:)), for: .touchUpInside)
        return btn
    }()
    
    lazy var rate1_5Button: UIButton = { // swiftlint:disable:this identifier_name
        let btn = UIButton(type: .custom)
        btn.setTitle("1.5X", for: .normal)
        btn.setTitleColor(.white, for: .normal)
        btn.setTitleColor(rateSelectedColor, for: .selected)
        btn.addTarget(self, action: #selector(rateAction(_:)), for: .touchUpInside)
        return btn
    }()
    
    lazy var rate2_0Button: UIButton = { // swiftlint:disable:this identifier_name
        let btn = UIButton(type: .custom)
        btn.setTitle("2.0X", for: .normal)
        btn.setTitleColor(.white, for: .normal)
        btn.setTitleColor(rateSelectedColor, for: .selected)
        btn.addTarget(self, action: #selector(rateAction(_:)), for: .touchUpInside)
        return btn
    }()
    
    open var rateSelectedColor: UIColor = #colorLiteral(red: 0.9843137255, green: 0.5333333333, blue: 0.1333333333, alpha: 1)
    
    open var rate: Float = 1.0 {
        didSet {
            rate0_5Button.isSelected = (rate == 0.5)
            rate1_0Button.isSelected = (rate == 1.0)
            rate1_25Button.isSelected = (rate == 1.25)
            rate1_5Button.isSelected = (rate == 1.5)
            rate2_0Button.isSelected = (rate == 2.0)
        }
    }
    
    open weak var delegate: MoreContentViewDelegate?

    /// width >= 330
    public override init(frame: CGRect) {
        super.init(frame: frame)
        initialize()
    }
    
    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        initialize()
    }
    
    private func initialize() {
        backgroundColor = UIColor.black.withAlphaComponent(0.5)
        
        addSubview(volumeView)
        volumeView.addSubview(volumeLabel)
        volumeView.addSubview(volumeMinImageView)
        volumeView.addSubview(volumeMaxImageView)
        volumeView.addSubview(volumeSlider)
        
        addSubview(brightnessView)
        brightnessView.addSubview(brightnessLabel)
        brightnessView.addSubview(brightnessMinImageView)
        brightnessView.addSubview(brightnessMaxImageView)
        brightnessView.addSubview(brightnessSlider)
        
        addSubview(rateView)
        rateView.addSubview(rateLabel)
        rateView.addSubview(rate0_5Button)
        rateView.addSubview(rate1_0Button)
        rateView.addSubview(rate1_25Button)
        rateView.addSubview(rate1_5Button)
        rateView.addSubview(rate2_0Button)
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
        
        let w: CGFloat = width - 20 - safeArea.right
        let h: CGFloat = 50
        let subH: CGFloat = 30
        let subY: CGFloat = (h - subH) / 2
        
        let lblW: CGFloat = 44
        
        let rateW: CGFloat = 46
        let rateH: CGFloat = 34
        let rateY: CGFloat = (h - rateH) / 2
        let rateMargin: CGFloat = max(0, (w - lblW - rateW * 5) / 4)
        
        volumeView.frame = CGRect(x: 10, y: 20 + safeArea.top, width: w, height: h)
        volumeLabel.frame = CGRect(x: 0, y: subY, width: lblW, height: subH)
        volumeMinImageView.frame = CGRect(x: volumeLabel.right, y: subY, width: subH, height: subH)
        volumeMaxImageView.frame = CGRect(x: volumeView.bounds.width - subH, y: subY, width: subH, height: subH)
        volumeSlider.frame = CGRect(x: volumeMinImageView.right, y: subY, width: volumeMaxImageView.left - volumeMinImageView.right, height: subH)
        
        brightnessView.frame = CGRect(x: 10, y: volumeView.bottom, width: w, height: h)
        brightnessLabel.frame = CGRect(x: 0, y: subY, width: lblW, height: subH)
        brightnessMinImageView.frame = CGRect(x: brightnessLabel.right, y: subY, width: subH, height: subH)
        brightnessMaxImageView.frame = CGRect(x: brightnessView.bounds.width - subH, y: subY, width: subH, height: subH)
        brightnessSlider.frame = CGRect(x: brightnessMinImageView.right, y: subY, width: brightnessMaxImageView.left - brightnessMinImageView.right, height: subH)
        
        rateView.frame = CGRect(x: 10, y: brightnessView.bottom, width: w, height: h)
        rateLabel.frame = CGRect(x: 0, y: subY, width: lblW, height: subH)
        rate0_5Button.frame = CGRect(x: rateLabel.right, y: rateY, width: rateW, height: rateH)
        rate1_0Button.frame = CGRect(x: rate0_5Button.right + rateMargin, y: rateY, width: rateW, height: rateH)
        rate1_25Button.frame = CGRect(x: rate1_0Button.right + rateMargin, y: rateY, width: rateW, height: rateH)
        rate1_5Button.frame = CGRect(x: rate1_25Button.right + rateMargin, y: rateY, width: rateW, height: rateH)
        rate2_0Button.frame = CGRect(x: rate1_5Button.right + rateMargin, y: rateY, width: rateW, height: rateH)
    }
    
    open func update(volume: CGFloat, brightness: CGFloat, rate: Float) {
        volumeSlider.value = Float(volume)
        brightnessSlider.value = Float(brightness)
        self.rate = rate
    }
    
    @objc
    open func rateAction(_ sender: UIButton) {
        var rate: Float = 1.0
        if sender == rate0_5Button {
            rate = 0.5
        } else if sender == rate1_0Button {
            rate = 1.0
        } else if sender == rate1_25Button {
            rate = 1.25
        } else if sender == rate1_5Button {
            rate = 1.5
        } else if sender == rate2_0Button {
            rate = 2.0
        }
        
        if rate != self.rate {
            delegate?.moreContentView(self, playRateDidChange: rate)
        }
        
        self.rate = rate
    }
    
    // MARK: - 🔥BufferSlider🔥
    
    open func slider(_ slider: BufferSlider, touchBegin value: Float) {
        
    }
    
    open func slider(_ slider: BufferSlider, valueChanged value: Float) {
        if slider == volumeSlider {
            delegate?.moreContentView(self, volumeDidChange: CGFloat(value))
        } else {
            delegate?.moreContentView(self, brightnessDidChange: CGFloat(value))
        }
    }
    
    open func slider(_ slider: BufferSlider, touchEnd value: Float) {
        if slider == volumeSlider {
            delegate?.moreContentView(self, volumeDidChange: CGFloat(value))
        } else {
            delegate?.moreContentView(self, brightnessDidChange: CGFloat(value))
        }
    }
    
    open func slider(_ slider: BufferSlider, clicked value: Float) {
        if slider == volumeSlider {
            delegate?.moreContentView(self, volumeDidChange: CGFloat(value))
        } else {
            delegate?.moreContentView(self, brightnessDidChange: CGFloat(value))
        }
    }
}

public protocol MoreContentViewDelegate: class {
    func moreContentView(_ moreContentView: MoreContentView, volumeDidChange volume: CGFloat)
    func moreContentView(_ moreContentView: MoreContentView, brightnessDidChange brightness: CGFloat)
    func moreContentView(_ moreContentView: MoreContentView, playRateDidChange rate: Float)
}

extension MoreContentViewDelegate {
    public func moreContentView(_ moreContentView: MoreContentView, volumeDidChange volume: CGFloat) {}
    public func moreContentView(_ moreContentView: MoreContentView, brightnessDidChange brightness: CGFloat) {}
    public func moreContentView(_ moreContentView: MoreContentView, playRateDidChange rate: Float) {}
}
