//
//  NormalForceRotateViewController.swift
//  PlayerDemo
//
//  Created by chenp on 2018/12/2.
//  Copyright © 2018 chenp. All rights reserved.
//

import UIKit
import PlayerCore
import PlayerControls
import PlayerAVPlayer
import PlayerIJKPlayer

class NormalForceRotateViewController: UIViewController {
    
    @IBOutlet weak var playerView: UIView!

    lazy var playerViewController = PlayerViewController()
    
    lazy var player = MovieAVPlayerController(contentURL: assets[currentPlayIndex].contentURL)
    
    lazy var controls = PlayerControlsView()
    lazy var pipControls = PlayerPictureInPictureControlsView()
    
    var currentPlayIndex = 0
    var assets: [(title: String, contentURL: URL, coverURL: URL)] = []
    var shouldAutoplay: Bool = true
    
    convenience init(assets: [(title: String, contentURL: URL, coverURL: URL)], currentPlayIndex: Int = 0, shouldAutoplay: Bool = true) {
        self.init()
        self.assets = assets
        self.currentPlayIndex = currentPlayIndex
        self.shouldAutoplay = shouldAutoplay
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        addChild(playerViewController)
        playerView.addSubview(playerViewController.view)
        playerViewController.view.frame = playerView.bounds
        playerViewController.view.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        playerViewController.didMove(toParent: self)
   
        playerViewController.rotateManager.shouldForceAutorotate = true
        playerViewController.rotateManager.forceFatherView = playerView
        playerViewController.delegate = self
        
        playerViewController.controlsView = controls
        playerViewController.playback = player
        
        // 允许后台播放
        player.shouldPlayInBackground = true
        
        if shouldAutoplay {
            player.prepareToPlay()
        } else {
            player.shouldAutoplay = false
        }
        
        // 显示下一集按钮
        controls.isHiddenNext = false
        
        controls.topPanel.titleLabel.text = assets[currentPlayIndex].title
        controls.coverImageView.kf.setImage(with: assets[currentPlayIndex].coverURL)
        controls.show(animated: true)
    }
    
    deinit {
        Log.info("deinit")
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // 隐藏导航栏
        navigationController?.navigationBar.setBackgroundImage(UIImage(), for: .default)
        navigationController?.navigationBar.shadowImage = UIImage()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        // 显示导航栏
        navigationController?.navigationBar.setBackgroundImage(nil, for: .default)
        navigationController?.navigationBar.shadowImage = nil
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    open override var prefersStatusBarHidden: Bool {
        return playerViewController.isStatusBarHidden
    }
}

extension NormalForceRotateViewController: PlayerViewControllerDelegate {
    func playerViewController(_ playerViewController: PlayerViewController, nextAction sender: UIButton) {
        let nextIndex = currentPlayIndex + 1
        if nextIndex > assets.count - 1 {
            let alert = UIAlertController(title: "没有下一集了", message: nil, preferredStyle: .alert)
            present(alert, animated: true, completion: nil)
        } else {
            currentPlayIndex = nextIndex
            
            player.contentURL = assets[currentPlayIndex].contentURL
            if shouldAutoplay {
                player.prepareToPlay()
            } else {
                player.play()
            }
            
            controls.reset()
            controls.centerPlayOrPauseButton.isHidden = true
            controls.topPanel.titleLabel.text = assets[currentPlayIndex].title
            controls.coverImageView.kf.setImage(with: assets[currentPlayIndex].coverURL)
            controls.show(animated: true)
            controls.speedLoading.startAnimating()
        }
    }
    
    func playerViewControllerWillStartPictureInPicture(_ playerViewController: PlayerViewController) {
        pipControls.coverImageView.kf.setImage(with: assets[currentPlayIndex].coverURL)
        playerViewController.controlsView = pipControls
    }
    
    func playerViewControllerWillStopPictureInPicture(_ playerViewController: PlayerViewController) {
        playerViewController.controlsView = controls
    }
}
