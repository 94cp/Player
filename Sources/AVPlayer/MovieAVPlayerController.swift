//
//  MovieAVPlayerController.swift
//  Player
//
//  Created by chenp on 2018/9/16.
//  Copyright © 2018 chenp. All rights reserved.
//

import UIKit
import AVFoundation
import PlayerCore

public enum MovieAVPlayerControllerError: Error {
    case assetCancelled
    case assetCannotPlayable
}

private extension String {
    static let playableKey = "playable"
    static let tracksKey = "tracks"
    static let durationKey = "duration"
}

open class MovieAVPlayerController: PlayerPlayback {
    
    // MARK: - 🔥其它属性🔥
    
    open private(set) var asset: AVURLAsset?
    open private(set) var playerItem: AVPlayerItem?
    open private(set) var player: AVPlayer?
    
    private var _isPrerolling = false
    private var _isSeeking = false
    private var _seekingTime: TimeInterval = 0
    
    private var _isPlayFunc = false
    private var _isFirstRendered = false
    
    /// HLS 截屏
    private var _videoOutput: AVPlayerItemVideoOutput?
    
    /// 记录静音前音量，用于恢复音量
    private var _muteBeforeVolume: Float = 0
    
    /// 中断之前是否正在播放
    private var _isPlayingBeforeInterruption = false
    
    /// 播放状态 KVO
    private var _playerItemStatusObservation: NSKeyValueObservation?
    /// 缓冲进度 KVO
    private var _loadedTimeRangesObservation: NSKeyValueObservation?
    /// 是否支持不停顿地播放 KVO
    private var _isPlaybackLikelyToKeepUpObservation: NSKeyValueObservation?
    /// 缓冲数据是否消耗完毕 KVO
    private var _isPlaybackBufferEmptyObservation: NSKeyValueObservation?
    /// 缓冲区是否已满 KVO
    private var _isPlaybackBufferFullObservation: NSKeyValueObservation?
    
    /// 播放速率 KVO
    private var _playerRateObservation: NSKeyValueObservation?
    
    /// 播放进度 Observer
    private var _playerTimeObserver: Any?
    
    // MARK: - 🔥PlayerPlayback🔥
    
    public required init(contentURL url: URL) {
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
        let view = MovieAVPlayerLayerView()
        view.backgroundColor = .black
        return view
    }()
    
    open weak var delegate: PlayerPlaybackDelegate?
    
    open var scalingMode: PlayerScalingMode = .aspectFit {
        didSet {
            guard oldValue != scalingMode else { return }
            
            switch scalingMode {
            case .none:
                view.contentMode = .center
                (view as? MovieAVPlayerLayerView)?.videoGravity = .resizeAspect
            case .aspectFit:
                view.contentMode = .scaleAspectFit
                (view as? MovieAVPlayerLayerView)?.videoGravity = .resizeAspect
            case .aspectFill:
                view.contentMode = .scaleAspectFill
                (view as? MovieAVPlayerLayerView)?.videoGravity = .resizeAspectFill
            case .fill:
                view.contentMode = .scaleToFill
                (view as? MovieAVPlayerLayerView)?.videoGravity = .resize
            }
            
            delegate?.playback(self, scalingModeDidChange: scalingMode)
        }
    }
    
    open private(set) var playbackState: PlayerPlaybackState = .stopped {
        didSet {
            guard oldValue != playbackState else { return }
            delegate?.playback(self, playbackStateDidChange: playbackState)
        }
    }
    
    open private(set) var loadState: PlayerLoadState = [] {
        didSet {
            guard oldValue != loadState else { return }
            delegate?.playback(self, loadStateDidChange: loadState)
        }
    }
    
    open var shouldAutoplay: Bool = true
    
    open var currentPlaybackTime: TimeInterval {
        get {
            guard let player = player else { return 0 }
            if _isSeeking { return _seekingTime }
            return CMTimeGetSeconds(player.currentTime())
        }
        set {
            seek(to: newValue, isAccurate: false, completion: nil)
        }
    }
    
    open private(set) var duration: TimeInterval = 0
    
    open private(set) var playableDuration: TimeInterval = 0 {
        didSet {
            guard oldValue != playableDuration else { return }
            self.isPlayFinishError = false
            delegate?.playback(self, playableDurationDidChange: playableDuration, duration: duration)
        }
    }
    
    open var progressInterval: TimeInterval = 0.5
    
    open private(set) var naturalSize: CGSize = .zero
    
    open var isMated: Bool = false {
        didSet {
            if isMated {
                _muteBeforeVolume = playbackVolume
                playbackVolume = 0
            } else {
                if _muteBeforeVolume == 0 {
                    _muteBeforeVolume = playbackVolume
                }
                playbackVolume = _muteBeforeVolume
            }
        }
    }
    
    open var playbackVolume: Float = 1.0 {
        didSet {
            let volume = max(0, min(playbackVolume, 1))
            player?.volume = volume
            player?.isMuted = (volume == 0)
        }
    }
    
    open var playbackRate: Float {
        get { return player?.rate ?? 0 }
        set { player?.rate = newValue }
    }
    
    open var shouldPlayInBackground: Bool = true
    
    open var isPlaying: Bool {
        guard let player = player else { return false }
        if player.rate != 0 { return true }
        return _isPrerolling
    }
    
    open private(set) var isPreparedToPlay: Bool = false
    
    open private(set) var isPlayFinishEnded: Bool = false
    open private(set) var isPlayFinishError: Bool = false
    
    open func prepareToPlay() {
        isPlayFinishEnded = false
        
        // 配置音频
        AVAudioSession.sharedInstance().setPlaybackCategory()
        AVAudioSession.sharedInstance().setActive(true)
        
        let playAsset = AVURLAsset(url: contentURL)
        asset = playAsset
        asyncLoadValue(from: playAsset)
        
        delegate?.playback(self, prepareToPlay: contentURL)
    }
    
    open func play() {
        if isPreparedToPlay {
            if isPlayFinishEnded {
                isPlayFinishEnded = false
                player?.seek(to: .zero)
            }
            
            player?.play()
            
            playbackState = .playing
            
            if !_isFirstRendered {
                _isFirstRendered = true
                delegate?.playback(self, firstRender: .video)
                delegate?.playback(self, firstRender: .audio)
            }
        } else {
            _isPlayFunc = true
            prepareToPlay()
        }
    }
    
    open func pause() {
        _isPrerolling = false
        player?.pause()
    }
    
    open func stop() {
        player?.pause()
        
        asset?.cancelLoading()
        
        if let playerItem = playerItem {
            playerItem.cancelPendingSeeks()
            removeObservers(for: playerItem)
            if let videoOutput = _videoOutput {
                playerItem.remove(videoOutput)
            }
        }
        
        if let player = player {
            removeObservers(for: player)
        }
        
        (self.view as? MovieAVPlayerLayerView)?.player = nil
        
        _isPrerolling = false
        _isSeeking = false
        _seekingTime = 0
        
        _isPlayFunc = false
        _isFirstRendered = false
        
        _videoOutput = nil
        
        playbackState = .stopped
        loadState = []
        duration = 0
        playableDuration = 0
        naturalSize = .zero
        
        isPreparedToPlay = false
        
        isPlayFinishEnded = false
        isPlayFinishError = false
    }
    
    open func seek(to time: TimeInterval, isAccurate: Bool, completion: ((Bool) -> Void)?) {
        guard let player = player else { return }
        
        if time == currentPlaybackTime { return }
        
        if _isSeeking {
            playerItem?.cancelPendingSeeks()
        }
        
        if _isPrerolling {
            player.pause()
        }
        
        if time > currentPlaybackTime {
            playbackState = .seekingForward
        } else if time < currentPlaybackTime {
            playbackState = .seekingBackward
        }
        loadState = .stalled
        
        _seekingTime = time
        _isSeeking = true
        
        let seekTime = CMTime(seconds: time, preferredTimescale: CMTimeScale(NSEC_PER_SEC))
        let before: CMTime = isAccurate ? .zero : .positiveInfinity
        let after: CMTime = isAccurate ? .zero : .positiveInfinity
        
        player.seek(to: seekTime, toleranceBefore: before, toleranceAfter: after, completionHandler: { (finished) in
            DispatchQueue.main.async {
                self._isSeeking = false
                self._seekingTime = 0
                
                if self._isPrerolling {
                    player.play()
                }
                self.playbackState = self.isPlaying ? .playing : .paused
                if self.playbackRate != 0 {
                    self.loadState = [.playable, .playthroughOK]
                }
                
                completion?(finished)
                self.delegate?.playback(self, seekDidComplete: time, duration: self.duration, isAccurate: isAccurate, error: nil)
            }
        })
    }
    
    open func thumbnailImageAtCurrentTime() -> UIImage? {
        if let thumbnailImage = snapshotImage() {
            return thumbnailImage
        } else {
            return snapshotHLSImage()
        }
    }
    
    /// 普通 快照
    open func snapshotImage() -> UIImage? {
        guard let asset = asset else { return nil }
        
        let imageGenerator = AVAssetImageGenerator(asset: asset)
        
        let time = CMTime(seconds: currentPlaybackTime, preferredTimescale: CMTimeScale(NSEC_PER_SEC))
        
        imageGenerator.requestedTimeToleranceBefore = .zero
        imageGenerator.requestedTimeToleranceAfter = .zero
        var _cgImage = try? imageGenerator.copyCGImage(at: time, actualTime: nil) // swiftlint:disable:this identifier_name
        
        if _cgImage == nil {
            imageGenerator.requestedTimeToleranceBefore = .positiveInfinity
            imageGenerator.requestedTimeToleranceAfter = .positiveInfinity
            _cgImage = try? imageGenerator.copyCGImage(at: time, actualTime: nil)
        }
        
        guard let cgImage = _cgImage else { return nil }
        
        return UIImage(cgImage: cgImage)
    }
    
    /// HLS 快照
    open func snapshotHLSImage() -> UIImage? {
        guard let playerItem = playerItem else { return nil }
        
        if _videoOutput == nil {
            let videoOutput = AVPlayerItemVideoOutput(pixelBufferAttributes: nil)
            playerItem.add(videoOutput)
            _videoOutput = videoOutput
        }
        
        let time = _videoOutput!.itemTime(forHostTime: CACurrentMediaTime())
        
        if _videoOutput!.hasNewPixelBuffer(forItemTime: time) {
            if let snapshotPixelBuffer = _videoOutput!.copyPixelBuffer(forItemTime: time, itemTimeForDisplay: nil) {
                let ciImage = CIImage(cvPixelBuffer: snapshotPixelBuffer)
                let context = CIContext(options: nil)
                let rect = CGRect(x: 0, y: 0, width: CVPixelBufferGetWidth(snapshotPixelBuffer), height: CVPixelBufferGetHeight(snapshotPixelBuffer))
                
                if let cgImage = context.createCGImage(ciImage, from: rect) {
                    return UIImage(cgImage: cgImage)
                }
            }
        }
        
        return nil
    }
}

extension MovieAVPlayerController {
    
    private func asyncLoadValue(from asset: AVURLAsset) {
        /// 媒体资源的playable、tracks、duration等属性获取比较耗时，异步获取
        asset.loadValuesAsynchronously(forKeys: [.playableKey, .tracksKey, .durationKey]) {
            DispatchQueue.main.async {
                self.didPrepareToPlayAsset(asset)
            }
        }
    }
    
    private func didPrepareToPlayAsset(_ asset: AVURLAsset) {
        var error: NSError?
        // 加载是否能够播放状态
        let playableStatus = asset.statusOfValue(forKey: .playableKey, error: &error)
        switch playableStatus {
        case .failed:
            self.isPlayFinishError = true
            delegate?.playback(self, didFinish: .playbackError, error: error)
            Log.error("AVURLAsset loadValuesAsynchronously failed, error: \(String(describing: error))")
            return
        case .cancelled:
            self.isPlayFinishError = true
            delegate?.playback(self, didFinish: .playbackError, error: MovieAVPlayerControllerError.assetCancelled)
            Log.error("AVURLAsset loadValuesAsynchronously cancelled")
            return
        default:
            if !asset.isPlayable {
                self.isPlayFinishError = true
                delegate?.playback(self, didFinish: .playbackError, error: MovieAVPlayerControllerError.assetCannotPlayable)
                Log.error("AVURLAsset loadValuesAsynchronously isPlayable = false")
            } else {
                let item = AVPlayerItem(asset: asset)
                playerItem = item
                addObservers(for: item)
                
                if let player = player {
                    if player.currentItem != item {
                        player.replaceCurrentItem(with: item)
                    }
                } else {
                    let avPlayer = AVPlayer(playerItem: item)
                    player = avPlayer
                    addObservers(for: avPlayer)
                }
                
                // 初始一些配置
                player?.volume = playbackVolume
                player?.isMuted = (playbackVolume == 0)
            }
        }
        
        // 加载音轨、视轨状态（已知问题：HLS视频 asset.tracks = [] ）
        let tracksStatus = asset.statusOfValue(forKey: .tracksKey, error: &error)
        if tracksStatus == .loaded {
            for track in asset.tracks where track.mediaType == .video {
                naturalSize = track.naturalSize
                delegate?.playback(self, naturalSizeDidAvailate: naturalSize)
                Log.info("AVURLAsset naturalSize = \(naturalSize)")
            }
        }
        
        // 加载总时长状态
        let durationStatus = asset.statusOfValue(forKey: .durationKey, error: &error)
        if durationStatus == .loaded {
            duration = CMTimeGetSeconds(asset.duration)
            delegate?.playback(self, durationDidAvailate: duration)
            Log.info("AVURLAsset duration = \(duration)")
        }
    }
    
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
    
    private func addObservers(for playerItem: AVPlayerItem) {// swiftlint:disable:this cyclomatic_complexity function_body_length
        // 播放状态 KVO
        _playerItemStatusObservation = playerItem.observe(\.status, options: [.new], changeHandler: { [weak self] (item, change) in // swiftlint:disable:this unused_closure_parameter
            guard let self = self else { return }
            // let status = change.newValue // 对于AVPlayerItem.Status，change.newValue方式在swift4中永远返回nil
            let status = item.status
            switch status {
            case .unknown:
                break
            case .readyToPlay:
                self.playbackState = .paused
                self.loadState = [.playable, .playthroughOK]
                
                (self.view as? MovieAVPlayerLayerView)?.player = self.player
                
                if self.duration <= 0 {
                    let duration = CMTimeGetSeconds(item.duration)
                    self.duration = duration
                    self.delegate?.playback(self, durationDidAvailate: duration)
                    Log.info("AVPlayerItem duration = \(duration)")
                }
                
                // 解决 HLS 视频 asset.tracks = [] 问题
                if self.naturalSize.equalTo(.zero) {
                    for track in item.tracks {
                        if let assetTrack = track.assetTrack, assetTrack.mediaType == .video {
                            let naturalSize = assetTrack.naturalSize
                            self.naturalSize = naturalSize
                            self.delegate?.playback(self, naturalSizeDidAvailate: naturalSize)
                            Log.info("AVPlayerItem naturalSize = \(naturalSize)")
                        }
                    }
                    
                    // 解决 HLS 视频 首次截屏 为nil问题
                    if self._videoOutput == nil {
                        let videoOutput = AVPlayerItemVideoOutput(pixelBufferAttributes: nil)
                        playerItem.add(videoOutput)
                        self._videoOutput = videoOutput
                    }
                }
                
                // 准备播放就绪
                self.isPreparedToPlay = true
                self.delegate?.playback(self, isPreparedToPlay: self.contentURL)
                
                // 判断是否开始播放视频
                if (self.shouldAutoplay || self._isPlayFunc) && (self.shouldPlayInBackground || UIApplication.shared.applicationState == .active) {
                    self.play()
                }
                
                Log.info("AVPlayerItem status = readyToPlay")
            case .failed:
                self.isPlayFinishError = true
                
                self.playbackState = .stopped
                self.loadState = []
                
                self.delegate?.playback(self, didFinish: .playbackError, error: item.error)
                
                Log.error("AVPlayerItem status = failed, error: \(String(describing: item.error))")
            }
        })
        
        // 缓冲进度 KVO
        _loadedTimeRangesObservation = playerItem.observe(\.loadedTimeRanges, options: [.new], changeHandler: { [weak self] (item, change) in
            if item.status != .readyToPlay {
                self?.playableDuration = 0
                return
            }
            
            guard let player = self?.player,
                let timeRange = change.newValue?.first?.timeRangeValue,
                CMTimeRangeContainsTime(timeRange, time: player.currentTime()) else { return }
            
            let maxTime = CMTimeRangeGetEnd(timeRange)
            let playableDuration = CMTimeGetSeconds(maxTime)
            if playableDuration > 0 {
                self?.playableDuration = playableDuration
            }
            
            Log.info("AVPlayerItem loadedTimeRanges playableDuration = \(playableDuration)")
        })
        
        // 是否支持不停顿地播放 KVO
        _isPlaybackLikelyToKeepUpObservation = playerItem.observe(\.isPlaybackLikelyToKeepUp, options: [.new], changeHandler: { [weak self] (item, change) in // swiftlint:disable:this unused_closure_parameter
            guard let self = self, let isPlaybackLikelyToKeepUp = change.newValue else { return }
            if isPlaybackLikelyToKeepUp {
                self.loadState = [.playable, .playthroughOK]
            }
            
            Log.info("AVPlayerItem isPlaybackLikelyToKeepUp = \(isPlaybackLikelyToKeepUp)")
        })
        
        // 缓冲数据是否消耗完毕 KVO
        _isPlaybackBufferEmptyObservation = playerItem.observe(\.isPlaybackBufferEmpty, options: [.new], changeHandler: { [weak self] (item, change) in // swiftlint:disable:this unused_closure_parameter
            guard let self = self, let isPlaybackBufferEmpty = change.newValue else { return }
            if isPlaybackBufferEmpty {
                self._isPrerolling = true
                self.loadState = .stalled
            }
            
            Log.info("AVPlayerItem isPlaybackBufferEmpty = \(isPlaybackBufferEmpty)")
        })
        
        // 缓冲区是否已满 KVO
        _isPlaybackBufferFullObservation = playerItem.observe(\.isPlaybackBufferFull, options: [.new], changeHandler: { [weak self] (item, change) in // swiftlint:disable:this unused_closure_parameter
            guard let self = self, let isPlaybackBufferFull = change.newValue else { return }
            if isPlaybackBufferFull {
                self.loadState = [.playable, .playthroughOK]
            }
            
            Log.info("AVPlayerItem isPlaybackBufferFull = \(isPlaybackBufferFull)")
        })
        
        // 播放结束
        NotificationCenter.default.addObserver(self, selector: #selector(playerItemDidPlayToEndTime(_:)), name: .AVPlayerItemDidPlayToEndTime, object: playerItem)
        // 播放结束失败
        NotificationCenter.default.addObserver(self, selector: #selector(playerItemFailedToPlayToEndTime(_:)), name: .AVPlayerItemFailedToPlayToEndTime, object: playerItem)
    }
    
    private func removeObservers(for playerItem: AVPlayerItem) {
        if let observation = _playerItemStatusObservation {
            observation.invalidate()
            _playerItemStatusObservation = nil
        }
        if let observation = _loadedTimeRangesObservation {
            observation.invalidate()
            _loadedTimeRangesObservation = nil
        }
        if let observation = _isPlaybackLikelyToKeepUpObservation {
            observation.invalidate()
            _isPlaybackLikelyToKeepUpObservation = nil
        }
        if let observation = _isPlaybackBufferEmptyObservation {
            observation.invalidate()
            _isPlaybackBufferEmptyObservation = nil
        }
        if let observation = _isPlaybackBufferFullObservation {
            observation.invalidate()
            _isPlaybackBufferFullObservation = nil
        }
        
        NotificationCenter.default.removeObserver(self, name: .AVPlayerItemDidPlayToEndTime, object: playerItem)
        NotificationCenter.default.removeObserver(self, name: .AVPlayerItemFailedToPlayToEndTime, object: playerItem)
    }
    
    private func addObservers(for player: AVPlayer) {
        // 播放速率 KVO
        _playerRateObservation = player.observe(\.rate, options: [.new]) { [weak self] (player, change) in // swiftlint:disable:this unused_closure_parameter
            guard let self = self, let rate = change.newValue else { return }
            if rate == 0 {
                self.playbackState = .paused
            } else {
                self._isPrerolling = false
            }
            
            Log.info("AVPlayer rate = \(rate)")
        }
        
        // 播放进度 Observer
        _playerTimeObserver = player.addPeriodicTimeObserver(forInterval: CMTime(seconds: progressInterval, preferredTimescale: CMTimeScale(NSEC_PER_SEC)), queue: DispatchQueue.main) { [weak self] (time) in
            guard let self = self else { return }
            if CMTimeGetSeconds(time) != 0 {
                self.isPlayFinishError = false
                self.delegate?.playback(self, currentPlaybackTimeDidChange: self.currentPlaybackTime, duration: self.duration)
                 Log.info("AVPlayer currentPlaybackTime = \(self.currentPlaybackTime)")
            }
        }
    }
    
    private func removeObservers(for player: AVPlayer) {
        if let observation = _playerRateObservation {
            observation.invalidate()
            _playerRateObservation = nil
        }
        
        if let observer = _playerTimeObserver {
            player.removeTimeObserver(observer)
            _playerTimeObserver = nil
        }
    }
}

extension MovieAVPlayerController {
    
    @objc
    private func playerItemDidPlayToEndTime(_ notification: Notification) {
        isPlayFinishEnded = true
        DispatchQueue.main.async {
            self.playbackState = .stopped
            self.delegate?.playback(self, didFinish: .playbackEnded, error: nil)
        }
        Log.info("AVPlayerItem playerItemDidPlayToEndTime")
    }
    
    @objc
    private func playerItemFailedToPlayToEndTime(_ notification: Notification) {
        isPlayFinishError = true
        let error = notification.userInfo?["error"] as? Error
        DispatchQueue.main.async {
            self.playbackState = .paused
            self.delegate?.playback(self, didFinish: .playbackError, error: error)
        }
        Log.error("AVPlayerItem playerItemFailedToPlayToEndTime error：\(String(describing: error))")
    }
    
    @objc
    private func audioSessionInterruption(_ notification: Notification) {
        guard let interruptionType = notification.userInfo?[AVAudioSessionInterruptionTypeKey] as? AVAudioSession.InterruptionType else { return }
        switch interruptionType {
        case .began:
            switch playbackState {
            case .playing, .seekingBackward, .seekingForward:
                _isPlayingBeforeInterruption = true
            case .stopped, .paused, .interrupted:
                _isPlayingBeforeInterruption = false
            }
            pause()
            AVAudioSession.sharedInstance().setActive(false)
        case .ended:
            AVAudioSession.sharedInstance().setActive(true)
            if _isPlayingBeforeInterruption {
                play()
            }
        }
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
        (view as? MovieAVPlayerLayerView)?.player = player
        delegate?.playback(self, applicationDidBecomeActive: UIApplication.shared)
        Log.info("applicationDidBecomeActive")
    }
    
    @objc
    private func applicationWillResignActive(_ notification: Notification) {
        DispatchQueue.main.async {
            if !self.shouldPlayInBackground {
                self.pause()
            }
        }
        delegate?.playback(self, applicationWillResignActive: UIApplication.shared)
        Log.info("applicationWillResignActive")
    }
    
    @objc
    private func applicationDidEnterBackground(_ notification: Notification) {
        if !shouldPlayInBackground {
            pause()
        } else {
            (view as? MovieAVPlayerLayerView)?.player = nil
            if isPlaying {
                DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                    self.play()
                }
            }
        }
        delegate?.playback(self, applicationDidEnterBackground: UIApplication.shared)
        Log.info("applicationDidEnterBackground")
    }
    
    @objc
    private func applicationWillTerminate(_ notification: Notification) {
        DispatchQueue.main.async {
            if !self.shouldPlayInBackground {
                self.pause()
            }
        }
        delegate?.playback(self, applicationWillTerminate: UIApplication.shared)
        Log.info("applicationWillTerminate")
    }
}
