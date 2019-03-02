//
//  PlayerDelegate.swift
//  Player
//
//  Created by chenp on 2018/10/19.
//  Copyright © 2018年 chenp. All rights reserved.
//

import UIKit
import AVFoundation.AVFAudio.AVAudioSession

// MARK: - 🔥PlayerViewControllerDelegate🔥

public protocol PlayerViewControllerDelegate: PlayerViewControllerVolumeDelegate, PlayerViewControllerRotateDelegate, PlayerViewControllerPictureInPictureDelegate, PlayerViewControllerGestureDelegate, PlayerViewControllerPlaybackDelegate, PlayerViewControllerControlsDelegate { }

public protocol PlayerViewControllerVolumeDelegate: class, PlayerVolumeable { }

public protocol PlayerViewControllerRotateDelegate: class, PlayerRotateable { }

public protocol PlayerViewControllerPictureInPictureDelegate: class, PlayerPictureInPictureable { }

public protocol PlayerViewControllerGestureDelegate: class, PlayerGestureable { }

public protocol PlayerViewControllerPlaybackDelegate: class, PlayerPlaybackable { }

public protocol PlayerViewControllerControlsDelegate: PlayerViewControllerControlsAppearDelegate, PlayerViewControllerControlsActionDelegate { }

// MARK: - 🔥Playerable🔥

public protocol Playerable: PlayerVolumeable, PlayerRotateable, PlayerPictureInPictureable, PlayerGestureable, PlayerPlaybackable { }

// MARK: - 🔥PlayerVolumeable🔥

public protocol PlayerVolumeable {
    func playerViewController(_ playerViewController: PlayerViewController, systemVolumeDidChange value: CGFloat)
}

// MARK: - 🔥PlayerRotateable🔥
public protocol PlayerRotateable {
    /// 设备方向改变
    func playerViewController(_ playerViewController: PlayerViewController, deviceOrientationChange orientation: UIInterfaceOrientation)
    
    /// 将要手动强制旋转
    func playerViewController(_ playerViewController: PlayerViewController, willForceRotate orientation: UIInterfaceOrientation)
    /// 完成手动强制旋转
    func playerViewController(_ playerViewController: PlayerViewController, didForceRotate orientation: UIInterfaceOrientation)
}

// MARK: - 🔥PlayerPictureInPictureable🔥

public protocol PlayerPictureInPictureable {
    func playerViewControllerWillStartPictureInPicture(_ playerViewController: PlayerViewController)
    func playerViewControllerDidStartPictureInPicture(_ playerViewController: PlayerViewController)
    func playerViewController(_ playerViewController: PlayerViewController, failedToStartPictureInPictureWithError error: PlayerPictureInPictureControllerError)
    func playerViewControllerWillStopPictureInPicture(_ playerViewController: PlayerViewController)
    func playerViewControllerDidStopPictureInPicture(_ playerViewController: PlayerViewController)
    func playerViewController(_ playerViewController: PlayerViewController, failedToStopPictureInPictureWithError error: PlayerPictureInPictureControllerError)
}

// MARK: - 🔥PlayerGestureable🔥
public protocol PlayerGestureable {
    /// 触发条件（手势筛选）
    func playerViewController(_ playerViewController: PlayerViewController, shouldReceive gestureRecognizer: UIGestureRecognizer, touch: UITouch, type: PlayerGestureType) -> Bool
    
    /// 单击
    func playerViewController(_ playerViewController: PlayerViewController, singleTap gestureRecognizer: UITapGestureRecognizer)
    /// 双击
    func playerViewController(_ playerViewController: PlayerViewController, doubleTap gestureRecognizer: UITapGestureRecognizer)
    
    /// 开始拖拽
    func playerViewController(_ playerViewController: PlayerViewController, beganPan gestureRecognizer: UIPanGestureRecognizer, direction: PlayerPanDirection, location: PlayerPanLocation)
    /// 拖拽中
    func playerViewController(_ playerViewController: PlayerViewController, changedPan gestureRecognizer: UIPanGestureRecognizer, direction: PlayerPanDirection, location: PlayerPanLocation, movingDirection: PlayerPanMovingDirection)
    /// 拖拽结束
    func playerViewController(_ playerViewController: PlayerViewController, endedPan gestureRecognizer: UIPanGestureRecognizer, direction: PlayerPanDirection, location: PlayerPanLocation)
    
    /// 捏合手势
    func playerViewController(_ playerViewController: PlayerViewController, pinch gestureRecognizer: UIPinchGestureRecognizer, scale: CGFloat)
}

// MARK: - 🔥PlayerPlaybackable🔥
public protocol PlayerPlaybackable {
    /// 视频准备播放
    func playerViewController(_ playerViewController: PlayerViewController, prepareToPlay contentURL: URL)
    
    /// 视频准备播放就绪
    func playerViewController(_ playerViewController: PlayerViewController, isPreparedToPlay contentURL: URL)
    
    /// 调用prepareToPlay()方法后，将异步获取视频播放总时长
    func playerViewController(_ playerViewController: PlayerViewController, durationDidAvailate duration: TimeInterval)
    
    /// 调用prepareToPlay()方法后，将异步获取视频实际尺寸
    func playerViewController(_ playerViewController: PlayerViewController, naturalSizeDidAvailate naturalSize: CGSize)
    
    /// 首帧渲染
    func playerViewController(_ playerViewController: PlayerViewController, firstRender firstRenderType: PlayerRenderType)
    
    /// 缩放模式改变
    func playerViewController(_ playerViewController: PlayerViewController, scalingModeDidChange scalingMode: PlayerScalingMode)
    
    /// 播放状态改变
    func playerViewController(_ playerViewController: PlayerViewController, playbackStateDidChange playbackState: PlayerPlaybackState)
    
    /// 数据加载状态改变
    func playerViewController(_ playerViewController: PlayerViewController, loadStateDidChange loadState: PlayerLoadState)
    
    /// 播放进度改变
    func playerViewController(_ playerViewController: PlayerViewController, currentPlaybackTimeDidChange currentPlaybackTime: TimeInterval, duration: TimeInterval)
    
    /// 缓冲进度改变
    func playerViewController(_ playerViewController: PlayerViewController, playableDurationDidChange playableDuration: TimeInterval, duration: TimeInterval)
    
    /// 定位完成
    func playerViewController(_ playerViewController: PlayerViewController, seekDidComplete seekDuration: TimeInterval, duration: TimeInterval, isAccurate: Bool, error: Error?)
    
    /// 播放结束
    func playerViewController(_ playerViewController: PlayerViewController, didFinish reason: PlayerFinishReason, error: Error?)
    
    func playerViewController(_ playerViewController: PlayerViewController, audioSessionInterruption type: AVAudioSession.InterruptionType)
    
    func playerViewController(_ playerViewController: PlayerViewController, applicationWillEnterForeground application: UIApplication)
    func playerViewController(_ playerViewController: PlayerViewController, applicationDidBecomeActive application: UIApplication)
    func playerViewController(_ playerViewController: PlayerViewController, applicationWillResignActive application: UIApplication)
    func playerViewController(_ playerViewController: PlayerViewController, applicationDidEnterBackground application: UIApplication)
    func playerViewController(_ playerViewController: PlayerViewController, applicationWillTerminate application: UIApplication)
}

// MARK: - 🔥PlayerViewControllerControlsAppearDelegate🔥
public protocol PlayerViewControllerControlsAppearDelegate: class {
    func playerViewController(_ playerViewController: PlayerViewController, controlsViewWillAppear animated: Bool)
    func playerViewController(_ playerViewController: PlayerViewController, controlsViewDidAppear animated: Bool)
    func playerViewController(_ playerViewController: PlayerViewController, controlsViewWillDisAppear animated: Bool)
    func playerViewController(_ playerViewController: PlayerViewController, controlsViewDidDisAppear animated: Bool)
}

// MARK: - 🔥PlayerViewControllerControlsActionDelegate🔥
public protocol PlayerViewControllerControlsActionDelegate: class {
    func playerViewController(_ playerViewController: PlayerViewController, backAction sender: UIButton)
    func playerViewController(_ playerViewController: PlayerViewController, closeAction sender: UIButton)
    
    func playerViewController(_ playerViewController: PlayerViewController, startPictureInPictureAction sender: UIButton)
    func playerViewController(_ playerViewController: PlayerViewController, stopPictureInPictureAction sender: UIButton)
    
    func playerViewController(_ playerViewController: PlayerViewController, shareAction sender: UIButton)
    func playerViewController(_ playerViewController: PlayerViewController, moreAction sender: UIButton)
    func playerViewController(_ playerViewController: PlayerViewController, nextAction sender: UIButton)
    
    func playerViewController(_ playerViewController: PlayerViewController, playAction sender: UIButton)
    func playerViewController(_ playerViewController: PlayerViewController, pauseAction sender: UIButton)
    
    func playerViewController(_ playerViewController: PlayerViewController, sliderBegin sender: UIView, progress: Float)
    func playerViewController(_ playerViewController: PlayerViewController, sliderChanged sender: UIView, progress: Float, isForword: Bool)
    func playerViewController(_ playerViewController: PlayerViewController, sliderEnd sender: UIView, progress: Float)
    func playerViewController(_ playerViewController: PlayerViewController, sliderClicked sender: UIView, progress: Float)
    
    func playerViewController(_ playerViewController: PlayerViewController, fullScreenAction sender: UIButton)
    func playerViewController(_ playerViewController: PlayerViewController, smallScreenAction sender: UIButton)
    
    func playerViewController(_ playerViewController: PlayerViewController, lockAction sender: UIButton)
    func playerViewController(_ playerViewController: PlayerViewController, unlockAction sender: UIButton)
    
    func playerViewController(_ playerViewController: PlayerViewController, snapshotAction sender: UIButton)
    func playerViewController(_ playerViewController: PlayerViewController, recordAction sender: UIButton)
    
    func playerViewController(_ playerViewController: PlayerViewController, failAction sender: UIButton)
    func playerViewController(_ playerViewController: PlayerViewController, replayAction sender: UIButton)
}
