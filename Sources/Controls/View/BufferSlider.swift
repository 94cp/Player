//
//  BufferSlider.swift
//  Player
//
//  Created by chenp on 2018/9/20.
//  Copyright © 2018年 chenp. All rights reserved.
//

import UIKit

public protocol BufferSliderDelegate: class {
    func slider(_ slider: BufferSlider, touchBegin value: Float)
    func slider(_ slider: BufferSlider, valueChanged value: Float)
    func slider(_ slider: BufferSlider, touchEnd value: Float)
    func slider(_ slider: BufferSlider, clicked value: Float)
}

open class BufferSlider: UIView {
    // 背景进度
    open lazy var backgroundProgressImageView: UIImageView = {
        let iv = UIImageView()
        iv.backgroundColor = UIColor.black.withAlphaComponent(0.6)
        iv.contentMode = .scaleAspectFill
        iv.clipsToBounds = true
        return iv
    }()
    // 缓冲进度
    open lazy var bufferProgressImageView: UIImageView = {
        let iv = UIImageView()
        iv.backgroundColor = .gray
        iv.contentMode = .scaleAspectFill
        iv.clipsToBounds = true
        return iv
    }()
    // 滑块进度
    open lazy var sliderProgressImageView: UIImageView = {
        let iv = UIImageView()
        iv.backgroundColor = .orange
        iv.contentMode = .scaleAspectFill
        iv.clipsToBounds = true
        return iv
    }()
    // 滑块
    open lazy var sliderButton: UIButton = {
        let sliderBtn = SliderButton(type: .custom)
        sliderBtn.backgroundColor = .orange
        sliderBtn.imageView?.contentMode = .scaleAspectFill
        sliderBtn.adjustsImageWhenHighlighted = false
        return sliderBtn
    }()
    
    open weak var delegate: BufferSliderDelegate?
    
    open var sliderButtonWH: CGFloat = 20 {
        didSet {
            setNeedsLayout()
            layoutIfNeeded()
        }
    }
    
    open var isSliding: Bool = false
    open var isForward: Bool = false
    
    /// 进度条值
    open var value: Float = 0.0 {
        didSet {
            value = min(max(minimumValue, value), maximumValue)
            if oldValue != value {
                setNeedsLayout()
                layoutIfNeeded()
            }
        }
    }
    /// 进度条缓冲值
    open var bufferValue: Float = 0.0 {
        didSet {
            bufferValue = min(max(minimumValue, bufferValue), maximumValue)
            if oldValue != value {
                setNeedsLayout()
                layoutIfNeeded()
            }
        }
    }
    /// 进度条最小值
    open var minimumValue: Float = 0.0 {
        didSet {
            minimumValue = max(0, minimumValue)
        }
    }
    /// 进度条最大值
    open var maximumValue: Float = 1.0 {
        didSet {
            maximumValue = max(minimumValue, maximumValue)
        }
    }
    
    /// 进度条高度
    open var sliderHeight: CGFloat = 2.0 {
        didSet {
            if oldValue != sliderHeight {
                setNeedsLayout()
                layoutIfNeeded()
            }
        }
    }
    
    /// 进度条已拖动颜色值
    open var minimumTrackTintColor: UIColor? {
        get { return sliderProgressImageView.backgroundColor }
        set { sliderProgressImageView.backgroundColor = newValue }
    }
    /// 进度条已缓存颜色值
    open var bufferTrackTintColor: UIColor? {
        get { return bufferProgressImageView.backgroundColor }
        set { bufferProgressImageView.backgroundColor = newValue }
    }
    /// 进度条未缓冲颜色值
    open var maximumTrackTintColor: UIColor? {
        get { return backgroundProgressImageView.backgroundColor }
        set { backgroundProgressImageView.backgroundColor = newValue }
    }
    
    /// 进度条已拖动图片
    open var minimumValueImage: UIImage? {
        get { return sliderProgressImageView.image }
        set {
            sliderProgressImageView.image = newValue
            minimumTrackTintColor = .clear
        }
    }
    /// 进度条已缓存图片
    open var bufferValueImage: UIImage? {
        get { return bufferProgressImageView.image }
        set {
            bufferProgressImageView.image = newValue
            bufferTrackTintColor = .clear
        }
    }
    /// 进度条未缓冲图片
    open var maximumValueImage: UIImage? {
        get { return backgroundProgressImageView.image }
        set {
            backgroundProgressImageView.image = newValue
            maximumTrackTintColor = .clear
        }
    }
    
    /// 进度条拖动块颜色值
    open var thumbTintColor: UIColor? {
        get { return sliderButton.backgroundColor }
        set { sliderButton.backgroundColor = newValue }
    }
    
    /// 设置滑块的图片
    open func setThumbImage(_ image: UIImage?, for state: UIControl.State) {
        sliderButton.backgroundColor = .clear
        sliderButton.setImage(image, for: state)
        sliderButton.sizeToFit()
    }
    
    open func thumbImage(for state: UIControl.State) -> UIImage? {
        return sliderButton.image(for: state)
    }
    
    open var progressMargin: CGFloat = 6
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        initialize()
    }
    
    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        initialize()
    }
    
    private func initialize() {
        backgroundColor = .clear
        
        addSubview(backgroundProgressImageView)
        addSubview(bufferProgressImageView)
        addSubview(sliderProgressImageView)
        addSubview(sliderButton)
        
        // 点击手势
        addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handleTap(_:))))
        // 拖拽手势
        addGestureRecognizer(UIPanGestureRecognizer(target: self, action: #selector(handlePan(_:))))
    }
    
    open override func layoutSubviews() {
        super.layoutSubviews()
        
        let x = sliderButton.isHidden ? 0 : progressMargin
        let y = (height - sliderHeight) / 2
        let w = sliderButton.isHidden ? width : width - progressMargin * 2
        
        let sliderProgress = CGFloat(value / (maximumValue - minimumValue))
        let bufferProgress = CGFloat(bufferValue / (maximumValue - minimumValue))

        backgroundProgressImageView.frame = CGRect(x: x, y: y, width: w, height: sliderHeight)
        bufferProgressImageView.frame = CGRect(x: x, y: y, width: w * bufferProgress, height: sliderHeight)
        sliderProgressImageView.frame = CGRect(x: x, y: y, width: w * sliderProgress, height: sliderHeight)
        
        sliderButton.frame = CGRect(x: (width - sliderButton.width) * sliderProgress, y: (height - sliderButtonWH) / 2, width: sliderButtonWH, height: sliderButtonWH)
        if !sliderButton.isHidden && sliderButton.imageView?.image == nil {
            sliderButton.layer.cornerRadius = sliderButton.width / 2
        }
    }
    
    @objc
    open func handleTap(_ tap: UITapGestureRecognizer) {
        switch tap.state {
        case .began:
            isSliding = true
        case .ended:
            isSliding = false
            let loc = tap.location(in: self)
            value = Float(((loc.x - backgroundProgressImageView.frame.minX) / backgroundProgressImageView.frame.width)) * (maximumValue - minimumValue)
            delegate?.slider(self, clicked: value)
        default:
            break
        }
    }
    
    @objc
    open func handlePan(_ pan: UIPanGestureRecognizer) {
        switch pan.state {
        case .began:
            isSliding = true
            delegate?.slider(self, touchBegin: value)
            sliderButton.transform = CGAffineTransform(scaleX: 1.5, y: 1.5)
        case .changed:
            isSliding = true
            let loc = pan.location(in: self)
            let progress = Float((loc.x - sliderButton.frame.width / 2) / (bounds.width - sliderButton.frame.width)) * (maximumValue - minimumValue)
            isForward = value < progress
            value = progress
            delegate?.slider(self, valueChanged: value)
        case .ended:
            isSliding = false
            delegate?.slider(self, touchEnd: value)
            sliderButton.transform = .identity
        default:
            break
        }
    }
}

private class SliderButton: UIButton {
    // 扩大点击区域
    override func point(inside point: CGPoint, with event: UIEvent?) -> Bool {
        let expandBounds = bounds.insetBy(dx: -20, dy: -20)
        return expandBounds.contains(point)
    }
}

extension BufferSliderDelegate {
    public func slider(_ slider: BufferSlider, touchBegin value: Float) {}
    public func slider(_ slider: BufferSlider, valueChanged value: Float) {}
    public func slider(_ slider: BufferSlider, touchEnd value: Float) {}
    public func slider(_ slider: BufferSlider, clicked value: Float) {}
}
