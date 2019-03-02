//
//  FastView.swift
//  Player
//
//  Created by chenp on 2018/9/20.
//  Copyright © 2018年 chenp. All rights reserved.
//

import UIKit

open class FastView: UIView {

    open lazy var imageView: UIImageView = {
        let iv = UIImageView()
        iv.isHidden = true
        return iv
    }()
    
    open lazy var timeLabel: UILabel = {
        let timeLabel = UILabel()
        timeLabel.textColor = .white
        timeLabel.textAlignment = .center
        timeLabel.font = .systemFont(ofSize: 20)
        timeLabel.adjustsFontSizeToFitWidth = true
        return timeLabel
    }()
    
    open lazy var progressSlider: BufferSlider = {
        let slider = BufferSlider()
        slider.minimumValueImage = UIImage(inBundle: "player_bg_progress_min")
        slider.bufferTrackTintColor = .gray
        slider.maximumTrackTintColor = UIColor.black.withAlphaComponent(0.6)
        slider.sliderButton.isHidden = true
        slider.sliderHeight = 2
        return slider
    }()
    
    open var animateDuration: TimeInterval = 0.4
    
    open var isTranslationX = false
    
    open var isHiddenPreviewImage = true {
        didSet {
            imageView.isHidden = isHiddenPreviewImage
            timeLabel.font = .systemFont(ofSize: isHiddenPreviewImage ? 20 : 14)
            setNeedsLayout()
            layoutIfNeeded()
        }
    }
    
    /// width: 160, height: 130
    public override init(frame: CGRect) {
        super.init(frame: frame)
        initialize()
    }
    
    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        initialize()
    }
    
    private func initialize() {
        addSubview(imageView)
        addSubview(timeLabel)
        addSubview(progressSlider)
    }
    
    open override func layoutSubviews() {
        super.layoutSubviews()
        
        if isHiddenPreviewImage {
            timeLabel.frame = CGRect(x: 0, y: (height - 34) / 2, width: width, height: 20)
            progressSlider.frame = CGRect(x: 0, y: timeLabel.bottom + 4, width: width, height: 10)
        } else {
            imageView.frame = CGRect(x: 0, y: 0, width: width, height: width / 16 * 9)
            timeLabel.frame = CGRect(x: 0, y: imageView.bottom + 2, width: width, height: 20)
            progressSlider.frame = CGRect(x: 0, y: timeLabel.bottom + 4, width: width, height: 10)
        }
    }

    open func show(progress: Float, bufferProgress: Float, time: String, isForward: Bool) {
        isHidden = false
        alpha = 1
        
        progressSlider.value = progress
        progressSlider.bufferValue = bufferProgress
        timeLabel.text = time
        
//        NSObject.cancelPreviousPerformRequests(withTarget: self, selector: #selector(hide), object: nil)
//        perform(#selector(hide), with: nil, afterDelay: 0.1)
        
        if isTranslationX {
            UIView.animate(withDuration: animateDuration) {
                self.transform = CGAffineTransform(translationX: isForward ? 10 : -10, y: 0)
            }
        }
    }
    
    @objc
    open func hide() {
        UIView.animate(withDuration: animateDuration, animations: {
            self.transform = .identity
            self.alpha = 0
        }, completion: { _ in
            self.isHidden = true
        })
    }
}
