//
//  PlayerGestureManagerDelegate.swift
//  Player
//
//  Created by chenp on 2018/9/23.
//  Copyright © 2018年 chenp. All rights reserved.
//

import UIKit

/// 手势类型：单击、双击、拖拽、捏合
public struct PlayerGestureType: OptionSet {
    public let rawValue: UInt8
    
    public init(rawValue: UInt8) {
        self.rawValue = rawValue
    }
    
    public static let singleTap = PlayerGestureType(rawValue: 1 << 0)
    public static let doubleTap = PlayerGestureType(rawValue: 1 << 1)
    public static let pan = PlayerGestureType(rawValue: 1 << 2)
    public static let pinch = PlayerGestureType(rawValue: 1 << 3)
    
    public static let all: PlayerGestureType = [.singleTap, .doubleTap, .pan, .pinch]
}

/// 拖拽位置
public enum PlayerPanLocation {
    case unknown
    case left
    case right
}

/// 拖拽方向：垂直、水平
public enum PlayerPanDirection: Int {
    case unknown
    case ver
    case hor
}

/// 拖拽移动方向
public enum PlayerPanMovingDirection {
    case unknown
    case top
    case left
    case bottom
    case right
}

public protocol PlayerGestureManagerDelegate: class {
    /// 触发条件（手势筛选）
    func gestureManager(_ gestureManager: PlayerGestureManager, shouldReceive gestureRecognizer: UIGestureRecognizer, touch: UITouch, type: PlayerGestureType) -> Bool
    
    /// 单击
    func gestureManager(_ gestureManager: PlayerGestureManager, singleTap gestureRecognizer: UITapGestureRecognizer)
    /// 双击
    func gestureManager(_ gestureManager: PlayerGestureManager, doubleTap gestureRecognizer: UITapGestureRecognizer)
    
    /// 开始拖拽
    func gestureManager(_ gestureManager: PlayerGestureManager, beganPan gestureRecognizer: UIPanGestureRecognizer, direction: PlayerPanDirection, location: PlayerPanLocation)
    /// 拖拽中
    func gestureManager(_ gestureManager: PlayerGestureManager, changedPan gestureRecognizer: UIPanGestureRecognizer, direction: PlayerPanDirection, location: PlayerPanLocation, movingDirection: PlayerPanMovingDirection)
    /// 拖拽结束
    func gestureManager(_ gestureManager: PlayerGestureManager, endedPan gestureRecognizer: UIPanGestureRecognizer, direction: PlayerPanDirection, location: PlayerPanLocation)
    
    /// 捏合手势
    func gestureManager(_ gestureManager: PlayerGestureManager, pinch gestureRecognizer: UIPinchGestureRecognizer, scale: CGFloat)
}

extension PlayerGestureManagerDelegate {
    public func gestureManager(_ gestureManager: PlayerGestureManager, shouldReceive gestureRecognizer: UIGestureRecognizer, touch: UITouch, type: PlayerGestureType) -> Bool { return true }
    public func gestureManager(_ gestureManager: PlayerGestureManager, singleTap gestureRecognizer: UITapGestureRecognizer) {}
    public func gestureManager(_ gestureManager: PlayerGestureManager, doubleTap gestureRecognizer: UITapGestureRecognizer) {}
    public func gestureManager(_ gestureManager: PlayerGestureManager, beganPan gestureRecognizer: UIPanGestureRecognizer, direction: PlayerPanDirection, location: PlayerPanLocation) {}
    public func gestureManager(_ gestureManager: PlayerGestureManager, changedPan gestureRecognizer: UIPanGestureRecognizer, direction: PlayerPanDirection, location: PlayerPanLocation, movingDirection: PlayerPanMovingDirection) {}
    public func gestureManager(_ gestureManager: PlayerGestureManager, endedPan gestureRecognizer: UIPanGestureRecognizer, direction: PlayerPanDirection, location: PlayerPanLocation) {}
    public func gestureManager(_ gestureManager: PlayerGestureManager, pinch gestureRecognizer: UIPinchGestureRecognizer, scale: CGFloat) {}
}
