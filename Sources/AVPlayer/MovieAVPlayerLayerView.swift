//
//  MovieAVPlayerLayerView.swift
//  Player
//
//  Created by chenp on 2018/9/16.
//  Copyright © 2018 chenp. All rights reserved.
//

import UIKit
import AVFoundation

open class MovieAVPlayerLayerView: UIView {
    
    open override class var layerClass: AnyClass {
        return AVPlayerLayer.self
    }
    
    open var playerLayer: AVPlayerLayer {
        return layer as! AVPlayerLayer // swiftlint:disable:this force_cast
    }
    
    open var player: AVPlayer? {
        get {
            return playerLayer.player
        }
        set {
            playerLayer.player = newValue
        }
    }
    
    open var videoGravity: AVLayerVideoGravity {
        get {
            return playerLayer.videoGravity
        }
        set {
            playerLayer.videoGravity = newValue
        }
    }
}
