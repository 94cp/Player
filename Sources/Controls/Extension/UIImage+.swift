//
//  UIImage+.swift
//  Player
//
//  Created by chenp on 2018/9/16.
//  Copyright © 2018 chenp. All rights reserved.
//

import UIKit

extension UIImage {
    convenience init?(inBundle name: String) {
        self.init(named: "Player.bundle/\(name)", in: Bundle(for: PlayerControlsView.self), compatibleWith: nil)
    }
}
