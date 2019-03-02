//
//  Double+.swift
//  Player
//
//  Created by chenp on 2018/9/17.
//  Copyright © 2018年 chenp. All rights reserved.
//

import Foundation

extension Double {
    
    var b: Double { return self }
    var kb: Double { return b / 1024 }
    var mb: Double { return kb / 1024 }
    var gb: Double { return mb / 1024 }
    
    var formatBytes: String {
        if gb > 1 {
            return "\(gb.afterPoint(n: 1)) GB"
        } else if mb > 1 {
            return"\(mb.afterPoint(n: 1)) MB"
        } else if kb > 1 {
            return "\(kb.afterPoint(n: 1)) KB"
        } else {
            return "\(b.afterPoint(n: 1)) B"
        }
    }
    
    func afterPoint(n: Int) -> String {
        return String(format: "%.\(n)f", self)
    }
}
