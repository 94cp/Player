//
//  PlayerPictureInPictureView.swift
//  Player
//
//  Created by chenp on 2018/11/10.
//  Copyright © 2018年 chenp. All rights reserved.
//

import UIKit

open class PlayerPictureInPictureView: UIView {

    public override init(frame: CGRect) {
        super.init(frame: frame)
        initialize()
    }
    
    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        initialize()
    }
    
    private func initialize() {
        layer.cornerRadius = 5
        clipsToBounds = true
        
        let pan = UIPanGestureRecognizer(target: self, action: #selector(handlePan(_:)))
        addGestureRecognizer(pan)
    }
    
    deinit {
        Log.info("deinit")
    }
    
    @objc
    open func handlePan(_ pan: UIPanGestureRecognizer) {
        guard let superview = superview else { return }
        
        let translation = pan.translation(in: superview)
        var center = CGPoint(x: self.center.x + translation.x, y: self.center.y + translation.y)
        
        var superviewSafeArea = UIEdgeInsets.zero
        if #available(iOS 11.0, *) {
            superviewSafeArea = superview.safeAreaInsets
        }
        
        center.x = max(frame.width / 2 + superviewSafeArea.left, center.x)
        center.x = min(superview.bounds.width - frame.width / 2 - superviewSafeArea.right, center.x)
        center.y = max(frame.height / 2 + superviewSafeArea.top, center.y)
        center.y = min(superview.bounds.height - frame.height / 2  - superviewSafeArea.bottom, center.y)
        
        self.center = center
        
        pan.setTranslation(.zero, in: superview)
    }
}
