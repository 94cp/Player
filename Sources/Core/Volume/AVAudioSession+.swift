//
//  AVAudioSession+.swift
//  Player
//
//  Created by chenp on 2018/9/16.
//  Copyright © 2018年 chenp. All rights reserved.
//

import AVFoundation.AVFAudio.AVAudioSession

extension AVAudioSession {
    
    /// 检查当前 AVAudioSession 的 category 配置是否可以播放音频。仅.ambient, .soloAmbient, .playback 或 .playAndRecord时返回true
    public var isPlayable: Bool {
        switch category {
        case .ambient, .soloAmbient, .playback, .playAndRecord:
            return true
        default:
            return false
        }
    }
    
    /// 检查当前 AVAudioSession 的 category 配置是否可以后台播放。仅.playback 或 .playAndRecord时返回true
    public var canPlayInBackground: Bool {
        switch category {
        case .playback, .playAndRecord:
            return true
        default:
            return false
        }
    }
}

extension AVAudioSession {
    
    /// 设置AVAudioSession 的 category 为 playback，使静音状态也可播放音频（如果激活音频会话，将会中断其它音频）
    public func setPlaybackCategory() {
        do {
            if #available(iOS 11.0, *) {
                try setCategory(.playback, mode: .moviePlayback, policy: .longForm, options: [])
            } else if #available(iOS 10.0, *) {
                try setCategory(.playback, mode: .moviePlayback, options: [])
            } else {
                perform(NSSelectorFromString("setCategory:withOptions:error:"), with: AVAudioSession.Category.playback, with: [])
            }
        } catch {
            Log.error("AVAudioSession.setCategory() failed：\(error)")
        }
    }
    
    /// 激活音频
    public func setActive(_ active: Bool) {
        do {
            try setActive(active, options: [])
        } catch {
            Log.error("AVAudioSession.setActive(\(active)) failed：\(error)")
        }
    }
}
