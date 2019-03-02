//
//  PlayerViewController+Delegate.swift
//  Player
//
//  Created by chenp on 2018/11/3.
//  Copyright © 2018年 chenp. All rights reserved.
//

import Foundation
import AVFoundation.AVFAudio.AVAudioSession

// MARK: - 🔥VolumeKitDelegate🔥
extension PlayerViewController: VolumeKitDelegate {
    public func volumeKit(_ volumeKit: VolumeKit, systemVolumeDidChange value: CGFloat) {
        controlsView?.playerViewController(self, systemVolumeDidChange: value)
        delegate?.playerViewController(self, systemVolumeDidChange: value)
    }
}

// MARK: - 🔥PlayerRotateManagerDelegate🔥
extension PlayerViewController: PlayerRotateManagerDelegate {
    public func rotateManager(_ rotateManager: PlayerRotateManager, deviceOrientationChange orientation: UIInterfaceOrientation) {
        controlsView?.playerViewController(self, deviceOrientationChange: orientation)
        delegate?.playerViewController(self, deviceOrientationChange: orientation)
    }
    
    public func rotateManager(_ rotateManager: PlayerRotateManager, willForceRotate orientation: UIInterfaceOrientation) {
        controlsView?.playerViewController(self, willForceRotate: orientation)
        delegate?.playerViewController(self, willForceRotate: orientation)
    }
    
    public func rotateManager(_ rotateManager: PlayerRotateManager, didForceRotate orientation: UIInterfaceOrientation) {
        controlsView?.playerViewController(self, didForceRotate: orientation)
        delegate?.playerViewController(self, didForceRotate: orientation)
    }
}

// MARK: - 🔥PlayerGestureManagerDelegate🔥
extension PlayerViewController: PlayerGestureManagerDelegate {
    public func gestureManager(_ gestureManager: PlayerGestureManager, shouldReceive gestureRecognizer: UIGestureRecognizer, touch: UITouch, type: PlayerGestureType) -> Bool {
        let controlsFlag = controlsView?.playerViewController(self, shouldReceive: gestureRecognizer, touch: touch, type: type) ?? true
        let delegateFlag = delegate?.playerViewController(self, shouldReceive: gestureRecognizer, touch: touch, type: type) ?? true
        
        return delegateFlag ? controlsFlag : delegateFlag
    }
    
    public func gestureManager(_ gestureManager: PlayerGestureManager, singleTap gestureRecognizer: UITapGestureRecognizer) {
        controlsView?.playerViewController(self, singleTap: gestureRecognizer)
        delegate?.playerViewController(self, singleTap: gestureRecognizer)
    }
    
    public func gestureManager(_ gestureManager: PlayerGestureManager, doubleTap gestureRecognizer: UITapGestureRecognizer) {
        controlsView?.playerViewController(self, doubleTap: gestureRecognizer)
        delegate?.playerViewController(self, doubleTap: gestureRecognizer)
        
    }
    
    public func gestureManager(_ gestureManager: PlayerGestureManager, beganPan gestureRecognizer: UIPanGestureRecognizer, direction: PlayerPanDirection, location: PlayerPanLocation) {
        controlsView?.playerViewController(self, beganPan: gestureRecognizer, direction: direction, location: location)
        delegate?.playerViewController(self, beganPan: gestureRecognizer, direction: direction, location: location)
    }
    
    public func gestureManager(_ gestureManager: PlayerGestureManager, changedPan gestureRecognizer: UIPanGestureRecognizer, direction: PlayerPanDirection, location: PlayerPanLocation, movingDirection: PlayerPanMovingDirection) {
        controlsView?.playerViewController(self, changedPan: gestureRecognizer, direction: direction, location: location, movingDirection: movingDirection)
        delegate?.playerViewController(self, changedPan: gestureRecognizer, direction: direction, location: location, movingDirection: movingDirection)
    }
    
    public func gestureManager(_ gestureManager: PlayerGestureManager, endedPan gestureRecognizer: UIPanGestureRecognizer, direction: PlayerPanDirection, location: PlayerPanLocation) {
        controlsView?.playerViewController(self, endedPan: gestureRecognizer, direction: direction, location: location)
        delegate?.playerViewController(self, endedPan: gestureRecognizer, direction: direction, location: location)
    }
    
    public func gestureManager(_ gestureManager: PlayerGestureManager, pinch gestureRecognizer: UIPinchGestureRecognizer, scale: CGFloat) {
        controlsView?.playerViewController(self, pinch: gestureRecognizer, scale: scale)
        delegate?.playerViewController(self, pinch: gestureRecognizer, scale: scale)
    }
}

extension PlayerViewController: PlayerPictureInPictureControllerDelegate {
    public func pictureInPictureControllerWillStartPictureInPicture(_ pictureInPictureController: PlayerPictureInPictureController) {
        controlsView?.playerViewControllerWillStartPictureInPicture(self)
        delegate?.playerViewControllerWillStartPictureInPicture(self)
    }
    
    public func pictureInPictureControllerDidStartPictureInPicture(_ pictureInPictureController: PlayerPictureInPictureController) {
        controlsView?.playerViewControllerDidStartPictureInPicture(self)
        delegate?.playerViewControllerDidStartPictureInPicture(self)
    }
    
    public func pictureInPictureControllerWillStopPictureInPicture(_ pictureInPictureController: PlayerPictureInPictureController) {
        controlsView?.playerViewControllerWillStopPictureInPicture(self)
        delegate?.playerViewControllerWillStopPictureInPicture(self)
    }
    
    public func pictureInPictureControllerDidStopPictureInPicture(_ pictureInPictureController: PlayerPictureInPictureController) {
        controlsView?.playerViewControllerDidStopPictureInPicture(self)
        delegate?.playerViewControllerDidStopPictureInPicture(self)
    }
    
    public func pictureInPictureController(_ pictureInPictureController: PlayerPictureInPictureController, failedToStartPictureInPictureWithError error: PlayerPictureInPictureControllerError) {
        controlsView?.playerViewController(self, failedToStartPictureInPictureWithError: error)
        delegate?.playerViewController(self, failedToStartPictureInPictureWithError: error)
    }
    
    public func pictureInPictureController(_ pictureInPictureController: PlayerPictureInPictureController, failedToStopPictureInPictureWithError error: PlayerPictureInPictureControllerError) {
        controlsView?.playerViewController(self, failedToStopPictureInPictureWithError: error)
        delegate?.playerViewController(self, failedToStopPictureInPictureWithError: error)
    }
}

// MARK: - 🔥PlayerControlsAppearDelegate🔥
extension PlayerViewController: PlayerControlsDelegate {
    public func controls(_ controls: PlayerControlsable, willAppear animated: Bool) {
        delegate?.playerViewController(self, controlsViewWillAppear: animated)
    }
    
    public func controls(_ controls: PlayerControlsable, didAppear animated: Bool) {
        delegate?.playerViewController(self, controlsViewDidAppear: animated)
    }
    
    public func controls(_ controls: PlayerControlsable, willDisAppear animated: Bool) {
        delegate?.playerViewController(self, controlsViewWillDisAppear: animated)
    }
    
    public func controls(_ controls: PlayerControlsable, didDisAppear animated: Bool) {
        delegate?.playerViewController(self, controlsViewDidDisAppear: animated)
    }
}

// MARK: - 🔥PlayerControlsActionDelegate🔥
extension PlayerViewController: PlayerControlsActionDelegate {
    public func controls(_ controls: PlayerControlsable, backAction sender: UIButton) {
        delegate?.playerViewController(self, backAction: sender)
    }
    
    public func controls(_ controls: PlayerControlsable, closeAction sender: UIButton) {
        delegate?.playerViewController(self, closeAction: sender)
    }
    
    public func controls(_ controls: PlayerControlsable, startPictureInPictureAction sender: UIButton) {
        delegate?.playerViewController(self, startPictureInPictureAction: sender)
    }
    
    public func controls(_ controls: PlayerControlsable, stopPictureInPictureAction sender: UIButton) {
        delegate?.playerViewController(self, stopPictureInPictureAction: sender)
    }
    
    public func controls(_ controls: PlayerControlsable, shareAction sender: UIButton) {
        delegate?.playerViewController(self, shareAction: sender)
    }
    
    public func controls(_ controls: PlayerControlsable, moreAction sender: UIButton) {
        delegate?.playerViewController(self, moreAction: sender)
    }
    
    public func controls(_ controls: PlayerControlsable, nextAction sender: UIButton) {
        delegate?.playerViewController(self, nextAction: sender)
    }
    
    public func controls(_ controls: PlayerControlsable, playAction sender: UIButton) {
        delegate?.playerViewController(self, playAction: sender)
    }
    
    public func controls(_ controls: PlayerControlsable, pauseAction sender: UIButton) {
        delegate?.playerViewController(self, pauseAction: sender)
    }
    
    public func controls(_ controls: PlayerControlsable, sliderBegin sender: UIView, progress: Float) {
        delegate?.playerViewController(self, sliderBegin: sender, progress: progress)
    }
    
    public func controls(_ controls: PlayerControlsable, sliderChanged sender: UIView, progress: Float, isForword: Bool) {
        delegate?.playerViewController(self, sliderChanged: sender, progress: progress, isForword: isForword)
    }
    
    public func controls(_ controls: PlayerControlsable, sliderEnd sender: UIView, progress: Float) {
        delegate?.playerViewController(self, sliderEnd: sender, progress: progress)
    }
    
    public func controls(_ controls: PlayerControlsable, sliderClicked sender: UIView, progress: Float) {
        delegate?.playerViewController(self, sliderClicked: sender, progress: progress)
    }
    
    public func controls(_ controls: PlayerControlsable, fullScreenAction sender: UIButton) {
        delegate?.playerViewController(self, fullScreenAction: sender)
    }
    
    public func controls(_ controls: PlayerControlsable, smallScreenAction sender: UIButton) {
        delegate?.playerViewController(self, smallScreenAction: sender)
    }
    
    public func controls(_ controls: PlayerControlsable, lockAction sender: UIButton) {
        delegate?.playerViewController(self, lockAction: sender)
    }
    
    public func controls(_ controls: PlayerControlsable, unlockAction sender: UIButton) {
        delegate?.playerViewController(self, unlockAction: sender)
    }
    
    public func controls(_ controls: PlayerControlsable, snapshotAction sender: UIButton) {
        delegate?.playerViewController(self, snapshotAction: sender)
    }
    
    public func controls(_ controls: PlayerControlsable, recordAction sender: UIButton) {
        delegate?.playerViewController(self, recordAction: sender)
    }
    
    public func controls(_ controls: PlayerControlsable, failAction sender: UIButton) {
        delegate?.playerViewController(self, failAction: sender)
    }
    
    public func controls(_ controls: PlayerControlsable, replayAction sender: UIButton) {
        delegate?.playerViewController(self, replayAction: sender)
    }
}

// MARK: - 🔥PlayerPlaybackDelegate🔥
extension PlayerViewController: PlayerPlaybackDelegate {
    
    public func playback(_ playback: PlayerPlayback, prepareToPlay contentURL: URL) {
        controlsView?.playerViewController(self, prepareToPlay: contentURL)
        delegate?.playerViewController(self, prepareToPlay: contentURL)
    }
    
    public func playback(_ playback: PlayerPlayback, isPreparedToPlay contentURL: URL) {
        controlsView?.playerViewController(self, isPreparedToPlay: contentURL)
        delegate?.playerViewController(self, isPreparedToPlay: contentURL)
    }
    
    public func playback(_ playback: PlayerPlayback, durationDidAvailate duration: TimeInterval) {
        controlsView?.playerViewController(self, durationDidAvailate: duration)
        delegate?.playerViewController(self, durationDidAvailate: duration)
    }
    
    public func playback(_ playback: PlayerPlayback, naturalSizeDidAvailate naturalSize: CGSize) {
        controlsView?.playerViewController(self, naturalSizeDidAvailate: naturalSize)
        delegate?.playerViewController(self, naturalSizeDidAvailate: naturalSize)
    }
    
    public func playback(_ playback: PlayerPlayback, firstRender firstRenderType: PlayerRenderType) {
        controlsView?.playerViewController(self, firstRender: firstRenderType)
        delegate?.playerViewController(self, firstRender: firstRenderType)
    }
    public func playback(_ playback: PlayerPlayback, scalingModeDidChange scalingMode: PlayerScalingMode) {
        controlsView?.playerViewController(self, scalingModeDidChange: scalingMode)
        delegate?.playerViewController(self, scalingModeDidChange: scalingMode)
    }
    
    public func playback(_ playback: PlayerPlayback, loadStateDidChange playerLoadState: PlayerLoadState) {
        controlsView?.playerViewController(self, loadStateDidChange: playerLoadState)
        delegate?.playerViewController(self, loadStateDidChange: playerLoadState)
    }
    
    public func playback(_ playback: PlayerPlayback, playbackStateDidChange playerPlaybackState: PlayerPlaybackState) {
        controlsView?.playerViewController(self, playbackStateDidChange: playerPlaybackState)
        delegate?.playerViewController(self, playbackStateDidChange: playerPlaybackState)
    }
    
    public func playback(_ playback: PlayerPlayback, currentPlaybackTimeDidChange currentPlaybackTime: TimeInterval, duration: TimeInterval) {
        controlsView?.playerViewController(self, currentPlaybackTimeDidChange: currentPlaybackTime, duration: duration)
        delegate?.playerViewController(self, currentPlaybackTimeDidChange: currentPlaybackTime, duration: duration)
    }
    
    public func playback(_ playback: PlayerPlayback, playableDurationDidChange playableDuration: TimeInterval, duration: TimeInterval) {
        controlsView?.playerViewController(self, playableDurationDidChange: playableDuration, duration: duration)
        delegate?.playerViewController(self, playableDurationDidChange: playableDuration, duration: duration)
    }
    
    public func playback(_ playback: PlayerPlayback, seekDidComplete seekDuration: TimeInterval, duration: TimeInterval, isAccurate: Bool, error: Error?) {
        controlsView?.playerViewController(self, seekDidComplete: seekDuration, duration: duration, isAccurate: isAccurate, error: error)
        delegate?.playerViewController(self, seekDidComplete: seekDuration, duration: duration, isAccurate: isAccurate, error: error)
    }
    
    public func playback(_ playback: PlayerPlayback, didFinish reason: PlayerFinishReason, error: Error?) {
        controlsView?.playerViewController(self, didFinish: reason, error: error)
        delegate?.playerViewController(self, didFinish: reason, error: error)
    }
    
    public func playback(_ playback: PlayerPlayback, audioSessionInterruption type: AVAudioSession.InterruptionType) {
        controlsView?.playerViewController(self, audioSessionInterruption: type)
        delegate?.playerViewController(self, audioSessionInterruption: type)
    }
    
    public func playback(_ playback: PlayerPlayback, applicationWillEnterForeground application: UIApplication) {
        controlsView?.playerViewController(self, applicationWillEnterForeground: application)
        delegate?.playerViewController(self, applicationWillEnterForeground: application)
    }
    
    public func playback(_ playback: PlayerPlayback, applicationDidBecomeActive application: UIApplication) {
        controlsView?.playerViewController(self, applicationDidBecomeActive: application)
        delegate?.playerViewController(self, applicationDidBecomeActive: application)
    }
    
    public func playback(_ playback: PlayerPlayback, applicationWillResignActive application: UIApplication) {
        controlsView?.playerViewController(self, applicationWillResignActive: application)
        delegate?.playerViewController(self, applicationWillResignActive: application)
    }
    
    public func playback(_ playback: PlayerPlayback, applicationDidEnterBackground application: UIApplication) {
        controlsView?.playerViewController(self, applicationDidEnterBackground: application)
        delegate?.playerViewController(self, applicationDidEnterBackground: application)
    }
    
    public func playback(_ playback: PlayerPlayback, applicationWillTerminate application: UIApplication) {
        controlsView?.playerViewController(self, applicationWillTerminate: application)
        delegate?.playerViewController(self, applicationWillTerminate: application)
    }
}
