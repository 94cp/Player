//
//  PlayerGestureManager.swift
//  Player
//
//  Created by chenp on 2018/9/23.
//  Copyright © 2018年 chenp. All rights reserved.
//

import UIKit

open class PlayerGestureManager: NSObject, UIGestureRecognizerDelegate {
    
    open private(set) lazy var singleTap: UITapGestureRecognizer = {
        let singleTap = UITapGestureRecognizer(target: self, action: #selector(handleSingleTap(_:)))
        singleTap.delegate = self
        singleTap.delaysTouchesBegan = true
        singleTap.delaysTouchesEnded = true
        singleTap.numberOfTouchesRequired = 1
        singleTap.numberOfTapsRequired = 1
        return singleTap
    }()
    
    open private(set) lazy var doubleTap: UITapGestureRecognizer = {
        let doubleTap = UITapGestureRecognizer(target: self, action: #selector(handleDoubleTap(_:)))
        doubleTap.delegate = self
        doubleTap.delaysTouchesBegan = true
        doubleTap.delaysTouchesEnded = true
        doubleTap.numberOfTouchesRequired = 1
        doubleTap.numberOfTapsRequired = 2
        return doubleTap
    }()
    
    open private(set) lazy var pan: UIPanGestureRecognizer = {
        let pan = UIPanGestureRecognizer(target: self, action: #selector(handlePan(_:)))
        pan.delegate = self
        pan.delaysTouchesBegan = true
        pan.delaysTouchesEnded = true
        pan.maximumNumberOfTouches = 1
        pan.cancelsTouchesInView = true
        return pan
    }()
    
    open private(set) lazy var pinch: UIPinchGestureRecognizer = {
        let pinch = UIPinchGestureRecognizer(target: self, action: #selector(handlePinch(_:)))
        pinch.delegate = self
        pinch.delaysTouchesBegan = true
        return pinch
    }()
    
    open var disableTypes: PlayerGestureType = []
    
    open private(set) var touchLocation: PlayerPanLocation = .unknown
    open private(set) var panDirection: PlayerPanDirection = .unknown
    open private(set) var panMovingDirection: PlayerPanMovingDirection = .unknown
    
    open var targetView: UIView?
    
    open weak var delegate: PlayerGestureManagerDelegate?
    
    open func addGestures(to view: UIView) {
        view.isMultipleTouchEnabled = true
        
        // 双击失败响应单击事件
        singleTap.require(toFail: doubleTap)
        // 拖拽失败响应单击事件
        singleTap.require(toFail: pan)
        
        view.addGestureRecognizer(singleTap)
        view.addGestureRecognizer(doubleTap)
        view.addGestureRecognizer(pan)
        view.addGestureRecognizer(pinch)
        
        targetView = view
    }
    
    open func removeGestures() {
        targetView?.removeGestureRecognizer(singleTap)
        targetView?.removeGestureRecognizer(doubleTap)
        targetView?.removeGestureRecognizer(pan)
        targetView?.removeGestureRecognizer(pinch)
    }
    
    // MARK: 🔥UIGestureRecognizerDelegate🔥
    
    // 判断是否响应手势
    open func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldReceive touch: UITouch) -> Bool {
        guard let targetView = targetView else { return true }
        
        var type: PlayerGestureType = []
        
        let loc = touch.location(in: touch.view)
        touchLocation = (loc.x > targetView.center.x) ? .right : .left
        
        if singleTap == gestureRecognizer {
            type = .singleTap
            if disableTypes.contains(.singleTap) {
                return false
            }
        } else if doubleTap == gestureRecognizer {
            type = .doubleTap
            if disableTypes.contains(.doubleTap) {
                return false
            }
        } else if pan == gestureRecognizer {
            type = .pan
            if disableTypes.contains(.pan) {
                return false
            }
        } else if pinch == gestureRecognizer {
            type = .pinch
            if disableTypes.contains(.pinch) {
                return false
            }
        }
        
        return delegate?.gestureManager(self, shouldReceive: gestureRecognizer, touch: touch, type: type) ?? true
    }
    
    // 是否支持多触发器
    open func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        if otherGestureRecognizer != singleTap && otherGestureRecognizer != doubleTap && otherGestureRecognizer != pan && otherGestureRecognizer != pinch {
            return false
        }
        
        if gestureRecognizer.numberOfTouches >= 2 {
            return false
        }
        
        return true
    }
    
    // MARK: 🔥Gesture Action🔥
    
    @objc
    open func handleSingleTap(_ singleTap: UITapGestureRecognizer) {
        delegate?.gestureManager(self, singleTap: singleTap)
    }
    
    @objc
    open func handleDoubleTap(_ doubleTap: UITapGestureRecognizer) {
       delegate?.gestureManager(self, doubleTap: doubleTap)
    }
    
    @objc
    open func handlePan(_ pan: UIPanGestureRecognizer) {
        let translate = pan.translation(in: pan.view)
        let velocity = pan.velocity(in: pan.view)
        
        switch pan.state {
        case .possible: // 未识别何种手势
            break
        case .began:
            panDirection = (abs(velocity.x) > abs(velocity.y) ? .hor : .ver)
            
            delegate?.gestureManager(self, beganPan: pan, direction: panDirection, location: touchLocation)
        case .changed:
            if panDirection == .hor {
                panMovingDirection = (translate.x > 0 ? .right : .left)
            } else if panDirection == .ver {
                panMovingDirection = (translate.y > 0 ? .bottom : .top)
            }
            
            delegate?.gestureManager(self, changedPan: pan, direction: panDirection, location: touchLocation, movingDirection: panMovingDirection)
        case .ended, .cancelled, .failed:
            delegate?.gestureManager(self, endedPan: pan, direction: panDirection, location: touchLocation)
        }
        
        // 拖拽手势复位
        pan.setTranslation(.zero, in: pan.view)
    }
    
    @objc
    open func handlePinch(_ pinch: UIPinchGestureRecognizer) {
        guard pinch.state == .ended else { return }
        
        delegate?.gestureManager(self, pinch: pinch, scale: pinch.scale)
    }
}
