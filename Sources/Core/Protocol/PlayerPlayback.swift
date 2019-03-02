//
//  PlayerPlayback.swift
//  Player
//
//  Created by chenp on 2018/9/16.
//  Copyright © 2018 chenp. All rights reserved.
//

import UIKit
import AVFoundation.AVFAudio.AVAudioSession

/// 缩放模式
public enum PlayerScalingMode {
    /// 无缩放
    /// No scaling
    case none
    
    /// 固定缩放比例并且尽量全部展示视频，不会裁切视频
    /// Uniform scale until one dimension fits
    case aspectFit
    
    /// 固定缩放比例并填充满整个视图展示，可能会裁切视频
    /// Uniform scale until the movie fills the visible bounds. One dimension may have clipped contents
    case aspectFill
    
    /// 不固定缩放比例压缩填充整个视图，视频不会被裁切但是比例可能失衡
    /// Non-uniform scale. Both render dimensions will exactly match the visible bounds
    case fill
}

/// 播放状态
public enum PlayerPlaybackState {
    /// 停止
    case stopped
    /// 播放
    case playing
    /// 暂停
    case paused
    /// 中断
    case interrupted
    /// 向前定位
    case seekingForward
    /// 向后定位
    case seekingBackward
}

/// 数据加载状态
public struct PlayerLoadState: OptionSet {
    
    public let rawValue: UInt8
    
    public init(rawValue: UInt8) {
        self.rawValue = rawValue
    }
    
    /// 可以播放
    public static let playable      = PlayerLoadState(rawValue: 1 << 0)
    
    /// 已缓冲到足够数据，如果shouldAutoPlay为true，播放器将会自动启动，以确保不停顿地播放
    /// Playback will be automatically started in this state when shouldAutoplay is YES
    public static let playthroughOK = PlayerLoadState(rawValue: 1 << 1)
    
    /// 缓冲停滞，如果启动，当播完缓冲数据后，播放器将会自动暂停
    /// Playback will be automatically paused in this state, if started
    public static let stalled       = PlayerLoadState(rawValue: 1 << 2)
}

/// 播放结束原因
public enum PlayerFinishReason {
    /// 播放完毕
    case playbackEnded
    /// 播放出错
    case playbackError
    /// 用户退出
    case userExited
}

/// 渲染类型
public enum PlayerRenderType {
    case video
    case audio
}

// MARK: - 🔥PlayerPlayback🔥

/// 播放器需遵循的协议
public protocol PlayerPlayback {
    
    init(contentURL url: URL)
    
    /// 播放资源URL
    var contentURL: URL { get set }
    
    /// 播放器视图
    /// The view in which the media are displayed.
    var view: UIView { get }
    
    /// 播放器代理
    var delegate: PlayerPlaybackDelegate? { get set }
    
    /// 视频播放视图的填充模式，默认.aspectFit
    /// Determines how the content scales to fit the view. Defaults to aspectFit.
    var scalingMode: PlayerScalingMode { get set}
    
    /// 视频播放状态，默认.stopped
    /// Returns the current playback state of the movie player. Defaults to stopped.
    var playbackState: PlayerPlaybackState { get }
    
    /// 网络加载状态，默认[]
    /// Returns the network load state of the movie player. Defaults to [].
    var loadState: PlayerLoadState { get }
    
    /// 是否在视频缓冲到足够数据时自动播放，以确保不停顿地播放，默认true
    /// Indicates if a movie should automatically start playback when it is likely to finish uninterrupted based on e.g. network conditions. Defaults to YES.
    var shouldAutoplay: Bool { get set }
    
    /// 当前已播放时长，默认0
    /// The current playback time of the now playing item in seconds.
    var currentPlaybackTime: TimeInterval { get set }
    
    /// 视频时长，默认0（直播或未知时为0）
    /// The duration of the movie, or 0.0 if not known.
    var duration: TimeInterval { get }
    
    /// 视频可播放时长(缓冲时长)，默认0
    /// The currently playable duration of the movie, for progressively downloaded network content.
    var playableDuration: TimeInterval { get }
    
    /// 播放进度回调间隔，默认0.5s
    var progressInterval: TimeInterval { get set }
    
    /// 视频实际尺寸，默认.zero（异步获取）
    /// The natural size of the movie, or CGSizeZero if not known/applicable.
    var naturalSize: CGSize { get }
    
    /// 播放器是否静音，不影响设备静音，默认false
    var isMated: Bool { get set }
    
    /// 0...1.0，播放器音量，不影响设备的音量大小，默认1.0
    var playbackVolume: Float { get set }
    
    /// 播放速率，默认1.0
    /// The current playback rate of the now playing item. Default is 1.0 (normal speed).
    /// Pausing will set the rate to 0.0. Setting the rate to non-zero implies playing.
    var playbackRate: Float { get set }
    
    /// 是否音频后台播放，默认false。
    /// 需确保 AVAudioSession.sharedInstance().canPlayInBackground为true，并在开启音频后台运行模式 UIBackgroundModes
    var shouldPlayInBackground: Bool { get set }
    
    /// 是否正在播放中，默认false
    var isPlaying: Bool { get }
    
    /// 是否准备就绪，默认false
    var isPreparedToPlay: Bool { get }
    
    /// 是否播放完毕，默认false
    var isPlayFinishEnded: Bool { get }
    
    /// 是否播放出错，默认false
    var isPlayFinishError: Bool { get }
    
    /// 准备播放，中断除non-mixible之外的任何音频会话。直接调用play()方法时，如果isPreparedToPlay为false，会自动调用prepareToPlay()方法
    /// Prepares the current queue for playback, interrupting any active (non-mixible) audio sessions.
    /// Automatically invoked when -play is called if the player is not already prepared.
    func prepareToPlay()
    
    /// 播放视频，如果isPreparedToPlay为false，会自动调用prepareToPlay()方法
    /// Plays items from the current queue, resuming paused playback if possible.
    func play()
    
    /// 暂停视频
    /// Pauses playback if playing.
    func pause()
    
    /// 停止视频，调用play()方法将重新开始播放视频
    /// Ends playback. Calling -play again will start from the beginnning of the queue.
    func stop()
    
    /// 调节播放进度，精准定位isAccurate默认true，completion默认 nil
    func seek(to time: TimeInterval, isAccurate: Bool, completion: ((Bool) -> Void)?)
    
    /// 获取当前视频帧图片（截屏）
    /// Captures and returns a thumbnail image from the current time
    func thumbnailImageAtCurrentTime() -> UIImage?
}

// MARK: - 🔥PlayerPlaybackDelegate🔥
/// 播放器代理
public protocol PlayerPlaybackDelegate: class {
    /// 视频准备播放
    func playback(_ playback: PlayerPlayback, prepareToPlay contentURL: URL)
    
    /// 视频准备播放就绪
    func playback(_ playback: PlayerPlayback, isPreparedToPlay contentURL: URL)
    
    /// 调用prepareToPlay()方法后，将异步获取视频播放总时长
    func playback(_ playback: PlayerPlayback, durationDidAvailate duration: TimeInterval)
    
    /// 调用prepareToPlay()方法后，将异步获取视频实际尺寸
    func playback(_ playback: PlayerPlayback, naturalSizeDidAvailate naturalSize: CGSize)
    
    /// 首帧渲染
    func playback(_ playback: PlayerPlayback, firstRender firstRenderType: PlayerRenderType)
    
    /// 缩放模式改变
    func playback(_ playback: PlayerPlayback, scalingModeDidChange scalingMode: PlayerScalingMode)
    
    /// 播放状态改变
    func playback(_ playback: PlayerPlayback, playbackStateDidChange playbackStat: PlayerPlaybackState)
    
    /// 数据加载状态改变
    func playback(_ playback: PlayerPlayback, loadStateDidChange loadState: PlayerLoadState)
    
    /// 播放进度改变
    func playback(_ playback: PlayerPlayback, currentPlaybackTimeDidChange currentPlaybackTime: TimeInterval, duration: TimeInterval)
    
    /// 缓冲进度改变
    func playback(_ playback: PlayerPlayback, playableDurationDidChange playableDuration: TimeInterval, duration: TimeInterval)
    
    /// 定位完成
    func playback(_ playback: PlayerPlayback, seekDidComplete seekDuration: TimeInterval, duration: TimeInterval, isAccurate: Bool, error: Error?)
    
    /// 播放结束
    func playback(_ playback: PlayerPlayback, didFinish reason: PlayerFinishReason, error: Error?)
    
    /// 音频中断
    func playback(_ playback: PlayerPlayback, audioSessionInterruption type: AVAudioSession.InterruptionType)
    
    func playback(_ playback: PlayerPlayback, applicationWillEnterForeground application: UIApplication)
    func playback(_ playback: PlayerPlayback, applicationDidBecomeActive application: UIApplication)
    func playback(_ playback: PlayerPlayback, applicationWillResignActive application: UIApplication)
    func playback(_ playback: PlayerPlayback, applicationDidEnterBackground application: UIApplication)
    func playback(_ playback: PlayerPlayback, applicationWillTerminate application: UIApplication)
}
