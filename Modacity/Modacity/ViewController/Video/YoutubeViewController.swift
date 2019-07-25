//
//  YoutubeViewController.swift
//  Modacity
//
//  Created by Benjamin Chris on 14/11/18.
//  Copyright © 2018 Modacity, Inc. All rights reserved.
//

import UIKit
import YoutubePlayer_in_WKWebView

class YoutubeViewController: ModacityParentViewController {

    @IBOutlet weak var labelTitle: UILabel!
    
    @IBOutlet weak var youtubePlayerView: WKYTPlayerView!
    @IBOutlet weak var spinner: UIActivityIndicatorView!
    
    var titleString = ""
    var videoId = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        self.youtubePlayerView.load(withVideoId: videoId)
//        self.youtubePlayerView.delegate = self
        self.labelTitle.text = titleString
    }
    
    override var prefersStatusBarHidden: Bool {
        return false
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    @IBAction func onBack(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
}

extension YoutubeViewController {
//    func playerReady(_ videoPlayer: YouTubePlayerView) {
//
//    }
//
//    func playerStateChanged(_ videoPlayer: YouTubePlayerView, playerState: YouTubePlayerState) {
//        if playerState == .Ended {
//            print("Youtube player ended")
//            self.setNeedsStatusBarAppearanceUpdate()
//        }
//    }
//
//    func playerQualityChanged(_ videoPlayer: YouTubePlayerView, playbackQuality: YouTubePlaybackQuality) {
//
//    }
}
