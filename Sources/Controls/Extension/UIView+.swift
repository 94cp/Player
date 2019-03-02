//
//  UIView+.swift
//  Player
//
//  Created by chenp on 2018/9/16.
//  Copyright © 2018 chenp. All rights reserved.
//

import UIKit

extension UIView {
    var x: CGFloat {
        get {
            return frame.minX
        }
        set {
            var tmpFrame = frame
            tmpFrame.origin.x = newValue
            frame = tmpFrame
        }
    }
    
    var y: CGFloat {
        get {
            return frame.minY
        }
        set {
            var tmpFrame = frame
            tmpFrame.origin.y = newValue
            frame = tmpFrame
        }
    }
    
    var height: CGFloat {
        get {
            return frame.height
        }
        set {
            var tmpFrame = frame
            tmpFrame.size.height = newValue
            frame = tmpFrame
        }
    }
    
    var width: CGFloat {
        get {
            return frame.width
        }
        set {
            var tmpFrame = frame
            tmpFrame.size.width = newValue
            frame = tmpFrame
        }
    }
    
    var size: CGSize {
        get {
            return frame.size
        }
        set {
            frame.size = newValue
        }
    }
    
    var origin: CGPoint {
        get {
            return frame.origin
        }
        set {
            frame.origin = newValue
        }
    }
    
    var left: CGFloat {
        get {
            return frame.minX
        }
        set {
            var tmpFrame = frame
            tmpFrame.origin.x = newValue
            frame = tmpFrame
        }
    }
    
    var right: CGFloat {
        get {
            return frame.maxX
        }
        set {
            var tmpFrame = frame
            tmpFrame.origin.x = newValue - frame.width
            frame = tmpFrame
        }
    }
    
    var top: CGFloat {
        get {
            return frame.minY
        }
        set {
            var tmpFrame = frame
            tmpFrame.origin.y = newValue
            frame = tmpFrame
        }
    }
    
    var bottom: CGFloat {
        get {
            return frame.maxY
        }
        set {
            var tmpFrame = frame
            tmpFrame.origin.y = newValue - frame.height
            frame = tmpFrame
        }
    }
    
    var centerX: CGFloat {
        get {
            return center.x
        }
        set {
            center = CGPoint(x: newValue, y: center.y)
        }
    }
    
    var centerY: CGFloat {
        get {
            return center.y
        }
        set {
            center = CGPoint(x: center.x, y: newValue)
        }
    }
    
    var midX: CGFloat {
        return frame.midX
    }
    
    var midY: CGFloat {
        return frame.midY
    }
    
    var midOrigin: CGPoint {
        return CGPoint(x: frame.midX, y: frame.midY)
    }
}

// MARK: - 🔥UIController🔥
extension UIView {
    
    var viewController: UIViewController? {
        return findControllerWithClass(clzz: UIViewController.self)
    }
    
    var navigationController: UINavigationController? {
        return findControllerWithClass(clzz: UINavigationController.self)
    }
    
    func findControllerWithClass<T>(clzz: AnyClass) -> T? {
        var responder = next
        while responder != nil {
            if (responder?.isKind(of: clzz))! {
                return responder as? T
            }
            responder = responder?.next
        }
        return nil
    }
}
