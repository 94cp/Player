//
//  PlayerControlsable.swift
//  Player
//
//  Created by chenp on 2018/9/16.
//  Copyright © 2018 chenp. All rights reserved.
//

import UIKit

public protocol PlayerControlsable: Playerable {
    /// 控制器代理
    var delegate: PlayerControlsDelegate? { get set }
    
    var playerViewController: PlayerViewController? { get set }
}

public protocol PlayerControlsDelegate: PlayerControlsAppearDelegate, PlayerControlsActionDelegate { }

public protocol PlayerControlsAppearDelegate: class {
    func controls(_ controls: PlayerControlsable, willAppear animated: Bool)
    func controls(_ controls: PlayerControlsable, didAppear animated: Bool)
    func controls(_ controls: PlayerControlsable, willDisAppear animated: Bool)
    func controls(_ controls: PlayerControlsable, didDisAppear animated: Bool)
}

public protocol PlayerControlsActionDelegate: class {
    func controls(_ controls: PlayerControlsable, backAction sender: UIButton)
    func controls(_ controls: PlayerControlsable, closeAction sender: UIButton)
    
    func controls(_ controls: PlayerControlsable, startPictureInPictureAction sender: UIButton)
    func controls(_ controls: PlayerControlsable, stopPictureInPictureAction sender: UIButton)
    
    func controls(_ controls: PlayerControlsable, shareAction sender: UIButton)
    func controls(_ controls: PlayerControlsable, moreAction sender: UIButton)
    func controls(_ controls: PlayerControlsable, nextAction sender: UIButton)

    func controls(_ controls: PlayerControlsable, playAction sender: UIButton)
    func controls(_ controls: PlayerControlsable, pauseAction sender: UIButton)

    func controls(_ controls: PlayerControlsable, sliderBegin sender: UIView, progress: Float)
    func controls(_ controls: PlayerControlsable, sliderChanged sender: UIView, progress: Float, isForword: Bool)
    func controls(_ controls: PlayerControlsable, sliderEnd sender: UIView, progress: Float)
    func controls(_ controls: PlayerControlsable, sliderClicked sender: UIView, progress: Float)

    func controls(_ controls: PlayerControlsable, fullScreenAction sender: UIButton)
    func controls(_ controls: PlayerControlsable, smallScreenAction sender: UIButton)

    func controls(_ controls: PlayerControlsable, lockAction sender: UIButton)
    func controls(_ controls: PlayerControlsable, unlockAction sender: UIButton)

    func controls(_ controls: PlayerControlsable, snapshotAction sender: UIButton)
    func controls(_ controls: PlayerControlsable, recordAction sender: UIButton)

    func controls(_ controls: PlayerControlsable, failAction sender: UIButton)
    func controls(_ controls: PlayerControlsable, replayAction sender: UIButton)
}

extension PlayerControlsAppearDelegate {
    public func controls(_ controls: PlayerControlsable, willAppear animated: Bool) {}
    public func controls(_ controls: PlayerControlsable, didAppear animated: Bool) {}
    public func controls(_ controls: PlayerControlsable, willDisAppear animated: Bool) {}
    public func controls(_ controls: PlayerControlsable, didDisAppear animated: Bool) {}
}

extension PlayerControlsActionDelegate {
    public func controls(_ controls: PlayerControlsable, backAction sender: UIButton) {}
    public func controls(_ controls: PlayerControlsable, closeAction sender: UIButton) {}
    public func controls(_ controls: PlayerControlsable, startPictureInPictureAction sender: UIButton) {}
    public func controls(_ controls: PlayerControlsable, stopPictureInPictureAction sender: UIButton) {}
    public func controls(_ controls: PlayerControlsable, shareAction sender: UIButton) {}
    public func controls(_ controls: PlayerControlsable, moreAction sender: UIButton) {}
    public func controls(_ controls: PlayerControlsable, nextAction sender: UIButton) {}
    public func controls(_ controls: PlayerControlsable, playAction sender: UIButton) {}
    public func controls(_ controls: PlayerControlsable, pauseAction sender: UIButton) {}
    public func controls(_ controls: PlayerControlsable, sliderBegin sender: UIView, progress: Float) {}
    public func controls(_ controls: PlayerControlsable, sliderChanged sender: UIView, progress: Float, isForword: Bool) {}
    public func controls(_ controls: PlayerControlsable, sliderEnd sender: UIView, progress: Float) {}
    public func controls(_ controls: PlayerControlsable, sliderClicked sender: UIView, progress: Float) {}
    public func controls(_ controls: PlayerControlsable, fullScreenAction sender: UIButton) {}
    public func controls(_ controls: PlayerControlsable, smallScreenAction sender: UIButton) {}
    public func controls(_ controls: PlayerControlsable, lockAction sender: UIButton) {}
    public func controls(_ controls: PlayerControlsable, unlockAction sender: UIButton) {}
    public func controls(_ controls: PlayerControlsable, snapshotAction sender: UIButton) {}
    public func controls(_ controls: PlayerControlsable, recordAction sender: UIButton) {}
    public func controls(_ controls: PlayerControlsable, failAction sender: UIButton) {}
    public func controls(_ controls: PlayerControlsable, replayAction sender: UIButton) {}
}
