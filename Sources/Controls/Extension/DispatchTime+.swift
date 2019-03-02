//
//  DispatchTime+.swift
//  Player
//
//  Created by chenp on 2018/9/27.
//  Copyright © 2018 chenp. All rights reserved.
//

import Foundation

extension DispatchTime {
    
    static func seconds(_ seconds: TimeInterval) -> DispatchTime {
        return .now() + .milliseconds(Int(seconds * 1000))
    }
}
