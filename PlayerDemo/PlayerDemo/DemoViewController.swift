//
//  DemoViewController.swift
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

class DemoViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    @IBOutlet weak var tableView: UITableView! {
        didSet {
            tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cellId")
        }
    }
    
    lazy var assets: [(title: String, contentURL: URL, coverURL: URL)] = {
        let assets = [
            (title: "bipbop basic master playlist",
             contentURL: URL(string: "http://devimages.apple.com.edgekey.net/streaming/examples/bipbop_4x3/bipbop_4x3_variant.m3u8")!,
             coverURL: URL(string: "https://upload-images.jianshu.io/upload_images/635942-14593722fe3f0695.png?imageMogr2/auto-orient/strip%7CimageView2/2/w/1240")!),
            
            (title: "bipbop basic 400x300 @ 232 kbps",
             contentURL: URL(string: "http://devimages.apple.com.edgekey.net/streaming/examples/bipbop_4x3/gear1/prog_index.m3u8")!,
             coverURL: URL(string: "https://upload-images.jianshu.io/upload_images/635942-14593722fe3f0695.png?imageMogr2/auto-orient/strip%7CimageView2/2/w/1240")!),
            
            (title: "bipbop basic 640x480 @ 650 kbps",
             contentURL: URL(string: "http://devimages.apple.com.edgekey.net/streaming/examples/bipbop_4x3/gear2/prog_index.m3u8")!,
             coverURL: URL(string: "https://upload-images.jianshu.io/upload_images/635942-14593722fe3f0695.png?imageMogr2/auto-orient/strip%7CimageView2/2/w/1240")!),
            
            (title: "bipbop basic 640x480 @ 1 Mbps",
             contentURL: URL(string: "http://devimages.apple.com.edgekey.net/streaming/examples/bipbop_4x3/gear3/prog_index.m3u8")!,
             coverURL: URL(string: "https://upload-images.jianshu.io/upload_images/635942-14593722fe3f0695.png?imageMogr2/auto-orient/strip%7CimageView2/2/w/1240")!),
            
            (title: "bipbop basic 960x720 @ 2 Mbps",
             contentURL: URL(string: "http://devimages.apple.com.edgekey.net/streaming/examples/bipbop_4x3/gear4/prog_index.m3u8")!,
             coverURL: URL(string: "https://upload-images.jianshu.io/upload_images/635942-14593722fe3f0695.png?imageMogr2/auto-orient/strip%7CimageView2/2/w/1240")!),
            
            (title: "bipbop basic 22.050Hz stereo @ 40 kbps",
             contentURL: URL(string: "http://devimages.apple.com.edgekey.net/streaming/examples/bipbop_4x3/gear0/prog_index.m3u8")!,
             coverURL: URL(string: "https://upload-images.jianshu.io/upload_images/635942-14593722fe3f0695.png?imageMogr2/auto-orient/strip%7CimageView2/2/w/1240")!),
            
            (title: "bipbop advanced master playlist",
             contentURL: URL(string: "http://devimages.apple.com.edgekey.net/streaming/examples/bipbop_16x9/bipbop_16x9_variant.m3u8")!,
             coverURL: URL(string: "https://upload-images.jianshu.io/upload_images/635942-14593722fe3f0695.png?imageMogr2/auto-orient/strip%7CimageView2/2/w/1240")!),
            
            (title: "bipbop advanced 416x234 @ 265 kbps",
             contentURL: URL(string: "http://devimages.apple.com.edgekey.net/streaming/examples/bipbop_16x9/gear1/prog_index.m3u8")!,
             coverURL: URL(string: "https://upload-images.jianshu.io/upload_images/635942-14593722fe3f0695.png?imageMogr2/auto-orient/strip%7CimageView2/2/w/1240")!),
            
            (title: "bipbop advanced 640x360 @ 580 kbps",
             contentURL: URL(string: "http://devimages.apple.com.edgekey.net/streaming/examples/bipbop_16x9/gear2/prog_index.m3u8")!,
             coverURL: URL(string: "https://upload-images.jianshu.io/upload_images/635942-14593722fe3f0695.png?imageMogr2/auto-orient/strip%7CimageView2/2/w/1240")!),
            
            (title: "bipbop advanced 960x540 @ 910 kbps",
             contentURL: URL(string: "http://devimages.apple.com.edgekey.net/streaming/examples/bipbop_16x9/gear3/prog_index.m3u8")!,
             coverURL: URL(string: "https://upload-images.jianshu.io/upload_images/635942-14593722fe3f0695.png?imageMogr2/auto-orient/strip%7CimageView2/2/w/1240")!),
            
            (title: "bipbop advanced 1280x720 @ 1 Mbps",
             contentURL: URL(string: "http://devimages.apple.com.edgekey.net/streaming/examples/bipbop_16x9/gear4/prog_index.m3u8")!,
             coverURL: URL(string: "https://upload-images.jianshu.io/upload_images/635942-14593722fe3f0695.png?imageMogr2/auto-orient/strip%7CimageView2/2/w/1240")!),
            
            (title: "bipbop advanced 1920x1080 @ 2 Mbps",
             contentURL: URL(string: "http://devimages.apple.com.edgekey.net/streaming/examples/bipbop_16x9/gear5/prog_index.m3u8")!,
             coverURL: URL(string: "https://upload-images.jianshu.io/upload_images/635942-14593722fe3f0695.png?imageMogr2/auto-orient/strip%7CimageView2/2/w/1240")!),
            
            (title: "bipbop advanced 22.050Hz stereo @ 40 kbps",
             contentURL: URL(string: "http://devimages.apple.com.edgekey.net/streaming/examples/bipbop_16x9/gear0/prog_index.m3u8")!,
             coverURL: URL(string: "https://upload-images.jianshu.io/upload_images/635942-14593722fe3f0695.png?imageMogr2/auto-orient/strip%7CimageView2/2/w/1240")!)
        ]
        return assets
    }()
    
    var sections: [(title: String, datas: [String])] = [
        (
            title: "Present",
            datas: [
                "普通模式+自动旋转（腾讯视频）",
                "普通模式+强制自动旋转（优酷/爱奇艺）",
                "手动播放",
                "横屏播放"
            ]
        ),
        (
            title: "Push",
            datas: [
                "普通模式+自动旋转（腾讯视频）",
                "普通模式+强制自动旋转（优酷/爱奇艺）",
                "手动播放",
                "横屏播放"
            ]
        )
    ]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "播放示例"
        
        view.addSubview(tableView)
        tableView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
    }
    
    /// 解决初始横屏布局错乱问题
    override var shouldAutorotate: Bool {
        return true
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return sections.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return sections[section].datas.count
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return sections[section].title
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cellId", for: indexPath)
        cell.textLabel?.text = sections[indexPath.section].datas[indexPath.row]
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        switch indexPath.section {
        case 0:
            switch indexPath.row {
            case 0:
                present(NormalAutorotateViewController(assets: assets), animated: true, completion: nil)
            case 1:
                present(NormalForceRotateViewController(assets: assets), animated: true, completion: nil)
            case 2:
                present(NormalAutorotateViewController(assets: assets, shouldAutoplay: false), animated: true, completion: nil)
            case 3:
                let currentPlayIndex = 0
                let playerViewController = PlayerViewController()
                let player = MovieAVPlayerController(contentURL: assets[currentPlayIndex].contentURL)
                let controls = PlayerControlsView()
                playerViewController.controlsView = controls
                playerViewController.playback = player
                player.prepareToPlay()
                controls.topPanel.titleLabel.text = assets[currentPlayIndex].title
                controls.coverImageView.kf.setImage(with: assets[currentPlayIndex].coverURL)
                controls.show(animated: true)
                controls.speedLoading.startAnimating()
                present(playerViewController, animated: true, completion: nil)
            default:
                break
            }
        case 1:
            hidesBottomBarWhenPushed = true
            switch indexPath.row {
            case 0:
                navigationController?.pushViewController(NormalAutorotateViewController(assets: assets), animated: true)
            case 1:
                navigationController?.pushViewController(NormalForceRotateViewController(assets: assets), animated: true)
            case 2:
                navigationController?.pushViewController(NormalAutorotateViewController(assets: assets, shouldAutoplay: false), animated: true)
            case 3:
                let currentPlayIndex = 0
                let playerViewController = PlayerViewController()
                let player = IJKPlayerController(contentURL: assets[currentPlayIndex].contentURL)
                let controls = PlayerControlsView()
                playerViewController.controlsView = controls
                playerViewController.playback = player
                player.prepareToPlay()
                controls.topPanel.titleLabel.text = assets[currentPlayIndex].title
                controls.coverImageView.kf.setImage(with: assets[currentPlayIndex].coverURL)
                controls.show(animated: true)
                controls.speedLoading.startAnimating()
                navigationController?.pushViewController(playerViewController, animated: true)
            default:
                break
            }
        default:
            break
        }
    }
}
