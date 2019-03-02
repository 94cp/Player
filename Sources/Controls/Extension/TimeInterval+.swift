//
//  TimeInterval+.swift
//  Player
//
//  Created by chenp on 2018/9/27.
//  Copyright © 2018 chenp. All rights reserved.
//

import Foundation

extension TimeInterval {
    
    var formatTime: String {
        let sec = Int(self)
        if sec < 60 {
            return String(format: "00:%02d", sec)
        } else if sec >= 60 && sec < 3600 {
            return String(format: "%02d:%02d", sec / 60, sec % 60)
        } else {
            return String(format: "%02d:%02d:%02d", sec / 60 * 60, sec % 3600 / 60, sec % 60)
        }
    }
}
