//
//  Playerable+Optional.swift
//  Player
//
//  Created by chenp on 2018/10/19.
//  Copyright © 2018年 chenp. All rights reserved.
//

import Foundation
import AVFoundation.AVFAudio.AVAudioSession

// MARK: - 🔥Optional🔥

extension PlayerVolumeable {
    public func playerViewController(_ playerViewController: PlayerViewController, systemVolumeDidChange value: CGFloat) {}
}

extension PlayerRotateable {
    public func playerViewController(_ playerViewController: PlayerViewController, deviceOrientationChange orientation: UIInterfaceOrientation) {}
    public func playerViewController(_ playerViewController: PlayerViewController, willForceRotate orientation: UIInterfaceOrientation) {}
    public func playerViewController(_ playerViewController: PlayerViewController, didForceRotate orientation: UIInterfaceOrientation) {}
}

extension PlayerPictureInPictureable {
    public func playerViewControllerWillStartPictureInPicture(_ playerViewController: PlayerViewController) {}
    public func playerViewControllerDidStartPictureInPicture(_ playerViewController: PlayerViewController) {}
    public func playerViewController(_ playerViewController: PlayerViewController, failedToStartPictureInPictureWithError error: PlayerPictureInPictureControllerError) {}
    public func playerViewControllerWillStopPictureInPicture(_ playerViewController: PlayerViewController) {}
    public func playerViewControllerDidStopPictureInPicture(_ playerViewController: PlayerViewController) {}
    public func playerViewController(_ playerViewController: PlayerViewController, failedToStopPictureInPictureWithError error: PlayerPictureInPictureControllerError) {}
}

extension PlayerGestureable {
    public func playerViewController(_ playerViewController: PlayerViewController, shouldReceive gestureRecognizer: UIGestureRecognizer, touch: UITouch, type: PlayerGestureType) -> Bool { return true }
    public func playerViewController(_ playerViewController: PlayerViewController, singleTap gestureRecognizer: UITapGestureRecognizer) {}
    public func playerViewController(_ playerViewController: PlayerViewController, doubleTap gestureRecognizer: UITapGestureRecognizer) {}
    public func playerViewController(_ playerViewController: PlayerViewController, beganPan gestureRecognizer: UIPanGestureRecognizer, direction: PlayerPanDirection, location: PlayerPanLocation) {}
    public func playerViewController(_ playerViewController: PlayerViewController, changedPan gestureRecognizer: UIPanGestureRecognizer, direction: PlayerPanDirection, location: PlayerPanLocation, movingDirection: PlayerPanMovingDirection) {}
    public func playerViewController(_ playerViewController: PlayerViewController, endedPan gestureRecognizer: UIPanGestureRecognizer, direction: PlayerPanDirection, location: PlayerPanLocation) {}
    public func playerViewController(_ playerViewController: PlayerViewController, pinch gestureRecognizer: UIPinchGestureRecognizer, scale: CGFloat) {}
}

extension PlayerPlaybackable {
    public func playerViewController(_ playerViewController: PlayerViewController, prepareToPlay contentURL: URL) {}
    public func playerViewController(_ playerViewController: PlayerViewController, isPreparedToPlay contentURL: URL) {}
    public func playerViewController(_ playerViewController: PlayerViewController, durationDidAvailate duration: TimeInterval) {}
    public func playerViewController(_ playerViewController: PlayerViewController, naturalSizeDidAvailate naturalSize: CGSize) {}
    public func playerViewController(_ playerViewController: PlayerViewController, firstRender firstRenderType: PlayerRenderType) {}
    public func playerViewController(_ playerViewController: PlayerViewController, scalingModeDidChange scalingMode: PlayerScalingMode) {}
    public func playerViewController(_ playerViewController: PlayerViewController, playbackStateDidChange playbackState: PlayerPlaybackState) {}
    public func playerViewController(_ playerViewController: PlayerViewController, loadStateDidChange loadState: PlayerLoadState) {}
    public func playerViewController(_ playerViewController: PlayerViewController, currentPlaybackTimeDidChange currentPlaybackTime: TimeInterval, duration: TimeInterval) {}
    public func playerViewController(_ playerViewController: PlayerViewController, playableDurationDidChange playableDuration: TimeInterval, duration: TimeInterval) {}
    public func playerViewController(_ playerViewController: PlayerViewController, seekDidComplete seekDuration: TimeInterval, duration: TimeInterval, isAccurate: Bool, error: Error?) {}
    public func playerViewController(_ playerViewController: PlayerViewController, didFinish reason: PlayerFinishReason, error: Error?) {}
    public func playerViewController(_ playerViewController: PlayerViewController, audioSessionInterruption type: AVAudioSession.InterruptionType) {}
    public func playerViewController(_ playerViewController: PlayerViewController, applicationWillEnterForeground application: UIApplication) {}
    public func playerViewController(_ playerViewController: PlayerViewController, applicationDidBecomeActive application: UIApplication) {}
    public func playerViewController(_ playerViewController: PlayerViewController, applicationWillResignActive application: UIApplication) {}
    public func playerViewController(_ playerViewController: PlayerViewController, applicationDidEnterBackground application: UIApplication) {}
    public func playerViewController(_ playerViewController: PlayerViewController, applicationWillTerminate application: UIApplication) {}
}

extension PlayerViewControllerControlsAppearDelegate {
    public func playerViewController(_ playerViewController: PlayerViewController, controlsViewWillAppear animated: Bool) {}
    public func playerViewController(_ playerViewController: PlayerViewController, controlsViewDidAppear animated: Bool) {}
    public func playerViewController(_ playerViewController: PlayerViewController, controlsViewWillDisAppear animated: Bool) {}
    public func playerViewController(_ playerViewController: PlayerViewController, controlsViewDidDisAppear animated: Bool) {}
}

extension PlayerViewControllerControlsActionDelegate {
    public func playerViewController(_ playerViewController: PlayerViewController, backAction sender: UIButton) {}
    public func playerViewController(_ playerViewController: PlayerViewController, closeAction sender: UIButton) {}
    public func playerViewController(_ playerViewController: PlayerViewController, startPictureInPictureAction sender: UIButton) {}
    public func playerViewController(_ playerViewController: PlayerViewController, stopPictureInPictureAction sender: UIButton) {}
    public func playerViewController(_ playerViewController: PlayerViewController, shareAction sender: UIButton) {}
    public func playerViewController(_ playerViewController: PlayerViewController, moreAction sender: UIButton) {}
    public func playerViewController(_ playerViewController: PlayerViewController, nextAction sender: UIButton) {}
    public func playerViewController(_ playerViewController: PlayerViewController, playAction sender: UIButton) {}
    public func playerViewController(_ playerViewController: PlayerViewController, pauseAction sender: UIButton) {}
    public func playerViewController(_ playerViewController: PlayerViewController, sliderBegin sender: UIView, progress: Float) {}
    public func playerViewController(_ playerViewController: PlayerViewController, sliderChanged sender: UIView, progress: Float, isForword: Bool) {}
    public func playerViewController(_ playerViewController: PlayerViewController, sliderEnd sender: UIView, progress: Float) {}
    public func playerViewController(_ playerViewController: PlayerViewController, sliderClicked sender: UIView, progress: Float) {}
    public func playerViewController(_ playerViewController: PlayerViewController, fullScreenAction sender: UIButton) {}
    public func playerViewController(_ playerViewController: PlayerViewController, smallScreenAction sender: UIButton) {}
    public func playerViewController(_ playerViewController: PlayerViewController, lockAction sender: UIButton) {}
    public func playerViewController(_ playerViewController: PlayerViewController, unlockAction sender: UIButton) {}
    public func playerViewController(_ playerViewController: PlayerViewController, snapshotAction sender: UIButton) {}
    public func playerViewController(_ playerViewController: PlayerViewController, recordAction sender: UIButton) {}
    public func playerViewController(_ playerViewController: PlayerViewController, failAction sender: UIButton) {}
    public func playerViewController(_ playerViewController: PlayerViewController, replayAction sender: UIButton) {}
}
