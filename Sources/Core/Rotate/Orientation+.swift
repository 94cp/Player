//
//  UIDeviceOrientation+.swift
//  Player
//
//  Created by chenp on 2018/9/23.
//  Copyright © 2018 chenp. All rights reserved.
//

import UIKit

extension UIDeviceOrientation {
    /// 横屏设备方向与屏幕方向相反，状态栏方向和设备方向一致
    public var interfaceOrientation: UIInterfaceOrientation {
        switch self {
        case .portrait:
            return .portrait
        case .portraitUpsideDown:
            return .portraitUpsideDown
        case .landscapeLeft:
            return .landscapeRight
        case .landscapeRight:
            return .landscapeLeft
        default:
            return .unknown
        }
    }
}

extension UIInterfaceOrientation {
    /// 横屏设备方向与屏幕方向相反，状态栏方向和设备方向一致
    public var deviceOrientation: UIDeviceOrientation {
        switch self {
        case .portrait:
            return .portrait
        case .portraitUpsideDown:
            return .portraitUpsideDown
        case .landscapeLeft:
            return .landscapeRight
        case .landscapeRight:
            return .landscapeLeft
        case .unknown:
            return .unknown
        }
    }
    
    /// 屏幕方向转屏幕支持方向
    public var interfaceOrientationMask: UIInterfaceOrientationMask {
        switch self {
        case .portrait:
            return .portrait
        case .portraitUpsideDown:
            return .portraitUpsideDown
        case .landscapeLeft:
            return .landscapeLeft
        case .landscapeRight:
            return .landscapeRight
        case .unknown:
            return .portrait
        }
    }
}
