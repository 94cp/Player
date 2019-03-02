//
//  VolumeBrightnessView.swift
//  Player
//
//  Created by chenp on 2018/9/21.
//  Copyright © 2018年 chenp. All rights reserved.
//

import UIKit

public enum VolumeBrightnessViewType {
    case volume
    case brightness
    
    public var image: UIImage? {
        switch self {
        case .volume:
            return UIImage(inBundle: "player_img_volume")
        case .brightness:
            return UIImage(inBundle: "player_img_brightness")
        }
    }
    
    public var title: String {
        switch self {
        case .volume:
            return "音量"
        case .brightness:
            return "亮度"
        }
    }
}

open class VolumeBrightnessView: UIView {

    open var type: VolumeBrightnessViewType = .volume {
        didSet {
            imageView.image = type.image
            titleLabel.text = type.title
        }
    }
    
    open lazy var backgroundVisualEffectView: UIVisualEffectView = {
        let blur = UIBlurEffect(style: .light)
        let visualEffectView = UIVisualEffectView(effect: blur)
        visualEffectView.alpha = 0.9
        return visualEffectView
    }()
    
    open lazy var titleLabel: UILabel = {
        let lbl = UILabel()
        lbl.font = .boldSystemFont(ofSize: 16)
        lbl.textAlignment = .center
        lbl.text = type.title
        return lbl
    }()
    
    open lazy var imageView: UIImageView = {
        let iv = UIImageView()
        iv.image = type.image
        return iv
    }()
    
    open lazy var levelView: UIView = {
        let view = UIView()
        view.backgroundColor = #colorLiteral(red: 0.2, green: 0.2, blue: 0.2, alpha: 1) // #333333
        for _ in 0..<16 {
            let v = UIView()
            v.backgroundColor = .white
            view.addSubview(v)
        }
        return view
    }()
    
    /// 0-1.0
    open var value: CGFloat = 1.0 {
        didSet {
            value = max(0, min(value, 1))
            
            let count = levelView.subviews.count
            let level = Int(value * CGFloat(count))
            for i in 0..<count {
                levelView.subviews[i].isHidden = i >= level ? true : false
            }
            
            if type == .volume {
                imageView.image = level >= 1 ? type.image : UIImage(inBundle: "player_img_mute")
            }
            
            isHidden = false
            
            NSObject.cancelPreviousPerformRequests(withTarget: self, selector: #selector(hide), object: nil)
            perform(#selector(hide), with: nil, afterDelay: 1.0)
        }
    }
    
    /// width = height = 155
    public override init(frame: CGRect) {
        super.init(frame: frame)
        initialize()
    }
    
    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        initialize()
    }
    
    private func initialize() {
        layer.cornerRadius = 10
        clipsToBounds = true
        
        addSubview(backgroundVisualEffectView)
        addSubview(titleLabel)
        addSubview(imageView)
        addSubview(levelView)
    
    }
    
    open override func layoutSubviews() {
        super.layoutSubviews()
        
        backgroundVisualEffectView.frame = bounds
        titleLabel.frame = CGRect(x: 0, y: 5, width: bounds.width, height: 30)
        imageView.frame = CGRect(x: (bounds.width - 80) / 2, y: titleLabel.frame.maxY + 3, width: 80, height: 80)
        levelView.frame = CGRect(x: 12, y: imageView.frame.maxY + 14, width: bounds.width - 24, height: 7)
        
        let count = levelView.subviews.count
        let w = (levelView.bounds.width - CGFloat(count + 1)) / CGFloat(count)
        for i in 0..<count {
            levelView.subviews[i].frame = CGRect(x: (CGFloat(i) * (w + 1) + 1), y: 1, width: w, height: 5)
        }
    }
    
    @objc
    private func hide() {
        isHidden = true
    }
    
    open func update(_ type: VolumeBrightnessViewType, value: CGFloat) {
        self.type = type
        self.value = value
    }
}
