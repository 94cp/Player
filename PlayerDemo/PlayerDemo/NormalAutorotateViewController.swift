//
//  NormalAutorotateViewController.swift
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
import Kingfisher

class NormalAutorotateViewController: UIViewController {

    @IBOutlet weak var iPhoneXStatusBar: UIView!
    
    @IBOutlet weak var iPhoneXStatusBarHeight: NSLayoutConstraint!
    
    @IBOutlet weak var playerView: UIView!
    
    @IBOutlet weak var playerViewSafeTop: NSLayoutConstraint!
    @IBOutlet weak var playerViewTop: NSLayoutConstraint!
    @IBOutlet weak var playerViewBottom: NSLayoutConstraint!
    @IBOutlet weak var playerViewHeight: NSLayoutConstraint!
    
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
     
        iPhoneXStatusBarHeight.constant = UIApplication.shared.statusBarFrame.height
        
        addChild(playerViewController)
        playerView.addSubview(playerViewController.view)
        playerViewController.view.frame = playerView.bounds
        playerViewController.view.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        playerViewController.didMove(toParent: self)
        
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
        navigationController?.setNavigationBarHidden(true, animated: animated)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        navigationController?.setNavigationBarHidden(false, animated: animated)
    }
    
    override var shouldAutorotate: Bool {
        return true
    }
    
    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        return controls.isLockScreen ? .landscape : .allButUpsideDown
    }
    
    override var preferredInterfaceOrientationForPresentation: UIInterfaceOrientation {
        return .portrait
    }

    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    open override var prefersStatusBarHidden: Bool {
        return playerViewController.isStatusBarHidden
    }
}

extension NormalAutorotateViewController: PlayerViewControllerDelegate {
    
    func playerViewController(_ playerViewController: PlayerViewController, deviceOrientationChange interfaceOrientation: UIInterfaceOrientation) {
        if controls.isLockScreen { return }
        
        if interfaceOrientation.isLandscape {
            iPhoneXStatusBarHeight.constant = 0
            
            playerViewSafeTop.isActive = false
            playerViewHeight.constant = UIScreen.main.bounds.height
            
            playerViewTop.isActive = true
            playerViewBottom.isActive = true
        } else {
            iPhoneXStatusBarHeight.constant = UIApplication.shared.statusBarFrame.height
            
            playerViewSafeTop.isActive = true
            playerViewHeight.constant = UIScreen.main.bounds.width / 16 * 9
            
            playerViewTop.isActive = false
            playerViewBottom.isActive = false
        }
    }
    
    func playerViewController(_ playerViewController: PlayerViewController, nextAction sender: UIButton) {
        let nextIndex = currentPlayIndex + 1
        if nextIndex > assets.count - 1 {
            let alert = UIAlertController(title: "没有下一集了", message: nil, preferredStyle: .alert)
            present(alert, animated: true, completion: nil)
        } else {
            currentPlayIndex = nextIndex
            
            controls.reset()
            controls.topPanel.titleLabel.text = assets[currentPlayIndex].title
            controls.coverImageView.kf.setImage(with: assets[currentPlayIndex].coverURL)
            controls.show(animated: true)
            
            player.contentURL = assets[currentPlayIndex].contentURL
            if shouldAutoplay {
                player.prepareToPlay()
            } else {
                player.play()
            }
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
