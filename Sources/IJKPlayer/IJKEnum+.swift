//
//  IJKEnum+.swift
//  Player
//
//  Created by chenp on 2018/10/11.
//  Copyright © 2018 chenp. All rights reserved.
//

import PlayerCore
import IJKMediaFramework

extension PlayerScalingMode {
    public var ijkScalingMode: IJKMPMovieScalingMode {
        switch self {
        case .none:
            return .none
        case .aspectFit:
            return .aspectFit
        case .aspectFill:
            return .aspectFill
        case .fill:
            return .fill
        }
    }
}

extension IJKMPMovieScalingMode {
    public var scalingMode: PlayerScalingMode {
        switch self {
        case .none:
            return .none
        case .aspectFit:
            return .aspectFit
        case .aspectFill:
            return .aspectFill
        case .fill:
            return .fill
        }
    }
}

extension IJKMPMoviePlaybackState {
    public var playbackState: PlayerPlaybackState {
        switch self {
        case .stopped:
            return .stopped
        case .playing:
            return .playing
        case .paused:
            return .paused
        case .interrupted:
            return .interrupted
        case .seekingForward:
            return .seekingForward
        case .seekingBackward:
            return .seekingBackward
        }
    }
}

extension IJKMPMovieLoadState {
    public var loadState: PlayerLoadState {
        var state: PlayerLoadState = []
        
        if self.contains(.playable) {
            state.insert(.playable)
        }
        
        if self.contains(.playthroughOK) {
            state.insert(.playthroughOK)
        }
        
        if self.contains(.stalled) {
            state.insert(.stalled)
        }
        
        return state
    }
}

extension IJKMPMovieFinishReason {
    public var reason: PlayerFinishReason {
        switch self {
        case .playbackEnded:
            return .playbackEnded
        case .playbackError:
            return .playbackError
        case .userExited:
            return .userExited
        }
    }
}
