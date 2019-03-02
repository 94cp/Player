//
//  IJKPlayerController.swift
//  Player
//
//  Created by chenp on 2018/10/11.
//  Copyright © 2018 chenp. All rights reserved.
//

import PlayerCore
import IJKMediaFramework

open class IJKPlayerController: PlayerPlayback {
    
    /// ijk播放配置
    open var options: IJKFFOptions = IJKFFOptions.byDefault()
    /// ijk播放器
    open private(set) var player: IJKFFMoviePlayerController?
    
    /// 记录静音前音量，用于恢复音量
    private var _muteBeforeVolume: Float = 0
    
    private var _seekingTime: TimeInterval = 0
    private var _isSeeking = false
    
    private var _isPlayFunc = false
    
    private var _lastCurrentPlaybackTime: TimeInterval = 0
    private var _lastPlayableDuration: TimeInterval = 0
    
    /// 定时器，定时刷新播放进度
    private var _timer: DispatchSourceTimer?
    
    public required init(contentURL url: URL) {
        var isReport = true
        var logLevel = k_IJK_LOG_INFO
        switch Log.logLevel {
        case .none:
            isReport = false
        case .debug:
            logLevel = k_IJK_LOG_DEBUG
        case .info:
            logLevel = k_IJK_LOG_INFO
        case .warn:
            logLevel = k_IJK_LOG_WARN
        case .error:
            logLevel = k_IJK_LOG_ERROR
        }
        
        IJKFFMoviePlayerController.setLogReport(isReport)
        IJKFFMoviePlayerController.setLogLevel(logLevel)
        
        // 检查FFmpeg版本是否和jik要求的版本匹配
        IJKFFMoviePlayerController.checkIfFFmpegVersionMatch(true)
        
        contentURL = url
        
        addApplicationObservers()
    }
    
    deinit {
        stop()
        removeApplicationObservers()
    }
    
    open var contentURL: URL {
        didSet {
            stop()
        }
    }
    
    open lazy var view: UIView = {
        let view = UIView()
        view.backgroundColor = .black
        return view
    }()
    
    open weak var delegate: PlayerPlaybackDelegate?
    
    open var scalingMode: PlayerScalingMode = .aspectFit {
        didSet {
            if scalingMode == oldValue { return }
            
            player?.scalingMode = scalingMode.ijkScalingMode
            
            delegate?.playback(self, scalingModeDidChange: scalingMode)
            Log.info("IJKPlayer scalingModeDidChange = \(scalingMode)")
        }
    }
    
    open var playbackState: PlayerPlaybackState {
        return player?.playbackState.playbackState ?? .stopped
    }
    
    open var loadState: PlayerLoadState {
        return player?.loadState.loadState ?? []
    }
    
    open var shouldAutoplay: Bool = true {
        didSet {
            player?.shouldAutoplay = shouldAutoplay
        }
    }
    
    open var currentPlaybackTime: TimeInterval {
        get {
            if _isSeeking {
                return _seekingTime
            }
            return player?.currentPlaybackTime ?? 0
        }
        set {
            _seekingTime = newValue
            _isSeeking = true
            player?.currentPlaybackTime = newValue
        }
    }
    
    open var duration: TimeInterval {
        return player?.duration ?? 0
    }
    
    open var playableDuration: TimeInterval {
        return player?.playableDuration ?? 0
    }
    
    open var progressInterval: TimeInterval = 0.5
    
    open var naturalSize: CGSize {
        return player?.naturalSize ?? .zero
    }
    
    open var isMated: Bool = false {
        didSet {
            if isMated {
                _muteBeforeVolume = player?.playbackVolume ?? 0
                player?.playbackVolume = 0
            } else {
                if _muteBeforeVolume == 0 {
                    _muteBeforeVolume = player?.playbackVolume ?? 0
                }
                player?.playbackVolume = _muteBeforeVolume
            }
        }
    }
    
    open var playbackVolume: Float = 1.0 {
        didSet {
            let volume = max(0, min(playbackVolume, 1))
            player?.playbackVolume = volume
        }
    }
    
    open var playbackRate: Float = 1.0 {
        didSet {
            player?.playbackRate = playbackRate
        }
    }
    
    open var shouldPlayInBackground: Bool = false {
        didSet {
            player?.setPauseInBackground(!shouldPlayInBackground)
        }
    }
    
    open var isPlaying: Bool {
        return player?.isPlaying() ?? false
    }
    
    open var isPreparedToPlay: Bool {
        return player?.isPreparedToPlay ?? false
    }
    
    open private(set) var isPlayFinishEnded: Bool = false
    open private(set) var isPlayFinishError: Bool = false
    
    open func prepareToPlay() {
        isPlayFinishEnded = false
        
        player = IJKFFMoviePlayerController(contentURL: contentURL, with: options)
        if let player = player {
            view.addSubview(player.view)
            player.view.frame = view.bounds
            player.view.autoresizingMask = [.flexibleWidth, .flexibleHeight]
            
            // 初始一些配置
            player.shouldAutoplay = shouldAutoplay
            player.scalingMode = scalingMode.ijkScalingMode
            player.playbackVolume = playbackVolume
            let tempIsMated = isMated
            isMated = tempIsMated
            player.playbackRate = playbackRate
            player.setPauseInBackground(!shouldPlayInBackground)
            
            addObservers(to: player)
        }
        player?.prepareToPlay()
        
        delegate?.playback(self, prepareToPlay: contentURL)
    }
    
    open func play() {
        if isPreparedToPlay {
            if isPlayFinishEnded {
                player?.currentPlaybackTime = 0
            }
            player?.play()
        } else {
            prepareToPlay()
            _isPlayFunc = true
        }
    }
    
    open func pause() {
        player?.pause()
    }
    
    open func stop() {
        guard let player = player else { return }
        
        player.stop()
        player.shutdown()
        player.view.removeFromSuperview()
        
        removeObservers(from: player)
        
        _timer?.cancel()
        _timer = nil
        
        self.player = nil
        
        _isSeeking = false
        _seekingTime = 0
        
        _isPlayFunc = false
        
        _lastCurrentPlaybackTime = 0
        _lastPlayableDuration = 0
        
        isPlayFinishEnded = false
        isPlayFinishError = false
    }
    
    open func seek(to time: TimeInterval, isAccurate: Bool, completion: ((Bool) -> Void)?) {
        _seekingTime = time
        _isSeeking = true
        player?.currentPlaybackTime = time
        completion?(true)
    }
    
    open func thumbnailImageAtCurrentTime() -> UIImage? {
        return player?.thumbnailImageAtCurrentTime()
    }
}

extension IJKPlayerController {
    
    private func addObservers(to player: IJKFFMoviePlayerController) {
        NotificationCenter.default.addObserver(self, selector: #selector(isPreparedToPlay(_:)), name: .IJKMPMediaPlaybackIsPreparedToPlayDidChange, object: player)
        
        NotificationCenter.default.addObserver(self, selector: #selector(naturalSizeAvailable(_:)), name: .IJKMPMovieNaturalSizeAvailable, object: player)
        
        NotificationCenter.default.addObserver(self, selector: #selector(firstVideoFrameRendered(_:)), name: .IJKMPMoviePlayerFirstVideoFrameRendered, object: player)
        NotificationCenter.default.addObserver(self, selector: #selector(firstAudioFrameRendered(_:)), name: .IJKMPMoviePlayerFirstAudioFrameRendered, object: player)
        
        NotificationCenter.default.addObserver(self, selector: #selector(playbackStateDidChange(_:)), name: .IJKMPMoviePlayerPlaybackStateDidChange, object: player)
        NotificationCenter.default.addObserver(self, selector: #selector(loadStateDidChange(_:)), name: .IJKMPMoviePlayerLoadStateDidChange, object: player)
        
        NotificationCenter.default.addObserver(self, selector: #selector(didSeekComplete(_:)), name: .IJKMPMoviePlayerDidSeekComplete, object: player)
        NotificationCenter.default.addObserver(self, selector: #selector(accurateSeekComplete(_:)), name: .IJKMPMoviePlayerAccurateSeekComplete, object: player)
        
        NotificationCenter.default.addObserver(self, selector: #selector(didFinish(_:)), name: .IJKMPMoviePlayerPlaybackDidFinish, object: player)
    }
    
    private func removeObservers(from player: IJKFFMoviePlayerController) {
        NotificationCenter.default.removeObserver(self, name: .IJKMPMediaPlaybackIsPreparedToPlayDidChange, object: player)
        
        NotificationCenter.default.removeObserver(self, name: .IJKMPMovieNaturalSizeAvailable, object: player)
        
        NotificationCenter.default.removeObserver(self, name: .IJKMPMoviePlayerFirstVideoFrameRendered, object: player)
        NotificationCenter.default.removeObserver(self, name: .IJKMPMoviePlayerFirstAudioFrameRendered, object: player)
    
        NotificationCenter.default.removeObserver(self, name: .IJKMPMoviePlayerPlaybackStateDidChange, object: player)
        NotificationCenter.default.removeObserver(self, name: .IJKMPMoviePlayerLoadStateDidChange, object: player)
        
        NotificationCenter.default.removeObserver(self, name: .IJKMPMoviePlayerDidSeekComplete, object: player)
        NotificationCenter.default.removeObserver(self, name: .IJKMPMoviePlayerAccurateSeekComplete, object: player)
        
        NotificationCenter.default.removeObserver(self, name: .IJKMPMoviePlayerPlaybackDidFinish, object: player)
    }
    
    @objc
    private func isPreparedToPlay(_ notification: Notification) {
        if duration > 0 {
            delegate?.playback(self, durationDidAvailate: duration)
            Log.info("IJKPlayer durationDidAvailate = \(duration)")
        }
        
        if isPreparedToPlay && _isPlayFunc {
            player?.play()
        }
        
        delegate?.playback(self, isPreparedToPlay: contentURL)
        Log.info("IJKPlayer isPreparedToPlay = \(isPreparedToPlay)")
    }
    
    @objc
    private func naturalSizeAvailable(_ notification: Notification) {
        delegate?.playback(self, naturalSizeDidAvailate: naturalSize)
        Log.info("IJKPlayer naturalSizeAvailable = \(naturalSize)")
    }
    
    @objc
    private func firstVideoFrameRendered(_ notification: Notification) {
        delegate?.playback(self, firstRender: .video)
        Log.info("IJKPlayer firstVideoFrameRendered")
    }
    
    @objc
    private func firstAudioFrameRendered(_ notification: Notification) {
        delegate?.playback(self, firstRender: .audio)
        Log.info("IJKPlayer firstAudioFrameRendered")
    }
    
    @objc
    private func loadStateDidChange(_ notification: Notification) {
       delegate?.playback(self, loadStateDidChange: loadState)
        Log.info("IJKPlayer loadStateDidChange = \(loadState)")
    }
    
    @objc
    private func playbackStateDidChange(_ notification: Notification) {
        if playbackState == .playing {
            if _timer == nil {
                _timer = DispatchSource.makeTimerSource()
                _timer?.schedule(deadline: .now(), repeating: progressInterval) // 时间间隔0.5s
                _timer?.setEventHandler(handler: { [weak self] in
                    guard let self = self else { return }
                    DispatchQueue.main.async {
                        if self._lastCurrentPlaybackTime != self.currentPlaybackTime {
                            self.isPlayFinishError = false
    
                            self._lastCurrentPlaybackTime = self.currentPlaybackTime
                            self.delegate?.playback(self, currentPlaybackTimeDidChange: self.currentPlaybackTime, duration: self.duration)
                            Log.info("IJKPlayer currentPlaybackTimeDidChange = \(self.currentPlaybackTime)")
                        }
                        
                        if self._lastPlayableDuration != self.playableDuration {
                            self.isPlayFinishError = false
                            
                            self._lastPlayableDuration = self.playableDuration
                            self.delegate?.playback(self, playableDurationDidChange: self.playableDuration, duration: self.duration)
                            Log.info("IJKPlayer playableDurationDidChange = \(self.playableDuration)")
                        }
                    }
                })
                _timer?.resume()
            }
        }
        
        delegate?.playback(self, playbackStateDidChange: playbackState)
        Log.info("IJKPlayer playbackStateDidChange = \(playbackState)")
    }
    
    @objc
    private func didSeekComplete(_ notification: Notification) {
        _isSeeking = false
        delegate?.playback(self, seekDidComplete: _seekingTime, duration: duration, isAccurate: false, error: nil)
        _seekingTime = 0
        Log.info("IJKPlayer didSeekComplete")
    }
    
    @objc
    private func accurateSeekComplete(_ notification: Notification) {
        _isSeeking = false
        delegate?.playback(self, seekDidComplete: _seekingTime, duration: duration, isAccurate: true, error: nil)
        _seekingTime = 0
        Log.info("IJKPlayer accurateSeekComplete")
    }
    
    @objc
    private func didFinish(_ notification: Notification) {
        guard let ijkReason = notification.userInfo?[IJKMPMoviePlayerPlaybackDidFinishReasonUserInfoKey] as? Int else { return }
        
        if ijkReason == IJKMPMovieFinishReason.playbackEnded.rawValue {
            isPlayFinishEnded = true
            delegate?.playback(self, didFinish: .playbackEnded, error: nil)
        } else if ijkReason == IJKMPMovieFinishReason.playbackError.rawValue {
            isPlayFinishError = true
            delegate?.playback(self, didFinish: .playbackError, error: nil)
        } else if ijkReason == IJKMPMovieFinishReason.userExited.rawValue {
            delegate?.playback(self, didFinish: .userExited, error: nil)
        }
        
        self._timer?.cancel()
        self._timer = nil
        
        Log.info("IJKPlayer didFinish = \(ijkReason)")
    }
}

extension IJKPlayerController {
    
    private func addApplicationObservers() {
        NotificationCenter.default.addObserver(self, selector: #selector(audioSessionInterruption(_:)), name: AVAudioSession.interruptionNotification, object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(applicationWillEnterForeground(_:)), name: UIApplication.willEnterForegroundNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(applicationDidBecomeActive(_:)), name: UIApplication.didBecomeActiveNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(applicationWillResignActive(_:)), name: UIApplication.willResignActiveNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(applicationDidEnterBackground(_:)), name: UIApplication.didEnterBackgroundNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(applicationWillTerminate(_:)), name: UIApplication.willTerminateNotification, object: nil)
    }
    
    private func removeApplicationObservers() {
        NotificationCenter.default.removeObserver(self, name: AVAudioSession.interruptionNotification, object: nil)
        
        NotificationCenter.default.removeObserver(self, name: UIApplication.willEnterForegroundNotification, object: nil)
        NotificationCenter.default.removeObserver(self, name: UIApplication.didBecomeActiveNotification, object: nil)
        NotificationCenter.default.removeObserver(self, name: UIApplication.willResignActiveNotification, object: nil)
        NotificationCenter.default.removeObserver(self, name: UIApplication.didEnterBackgroundNotification, object: nil)
        NotificationCenter.default.removeObserver(self, name: UIApplication.willTerminateNotification, object: nil)
    }
    
    @objc
    private func audioSessionInterruption(_ notification: Notification) {
        guard let interruptionType = notification.userInfo?[AVAudioSessionInterruptionTypeKey] as? AVAudioSession.InterruptionType else { return }
        delegate?.playback(self, audioSessionInterruption: interruptionType)
        Log.info("AVAudioSession.Interruption type = \(interruptionType)")
    }
    
    @objc
    private func applicationWillEnterForeground(_ notification: Notification) {
        delegate?.playback(self, applicationWillEnterForeground: UIApplication.shared)
        Log.info("applicationWillEnterForeground")
    }
    
    @objc
    private func applicationDidBecomeActive(_ notification: Notification) {
        delegate?.playback(self, applicationDidBecomeActive: UIApplication.shared)
        Log.info("applicationDidBecomeActive")
    }
    
    @objc
    private func applicationWillResignActive(_ notification: Notification) {
        delegate?.playback(self, applicationWillResignActive: UIApplication.shared)
        Log.info("applicationWillResignActive")
    }
    
    @objc
    private func applicationDidEnterBackground(_ notification: Notification) {
        delegate?.playback(self, applicationDidEnterBackground: UIApplication.shared)
        Log.info("applicationDidEnterBackground")
    }
    
    @objc
    private func applicationWillTerminate(_ notification: Notification) {
        delegate?.playback(self, applicationWillTerminate: UIApplication.shared)
        Log.info("applicationWillTerminate")
    }
}
