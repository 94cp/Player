//
//  UInt32.swift
//  Player
//
//  Created by chenp on 2018/9/17.
//  Copyright © 2018年 chenp. All rights reserved.
//

import Foundation

extension UInt32 {
    
    var formatSpeed: String {
        return "\(Double(self).formatBytes)/s"
    }
}
