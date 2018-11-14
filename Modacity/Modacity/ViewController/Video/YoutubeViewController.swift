//
//  YoutubeViewController.swift
//  Modacity
//
//  Created by Benjamin Chris on 14/11/18.
//  Copyright © 2018 Modacity, Inc. All rights reserved.
//

import UIKit
import YouTubePlayer_Swift

class YoutubeViewController: UIViewController {

    @IBOutlet weak var labelTitle: UILabel!
    
    @IBOutlet weak var youtubePlayerView: YouTubePlayerView!
    @IBOutlet weak var spinner: UIActivityIndicatorView!
    
    var titleString = ""
    var videoId = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        self.youtubePlayerView.loadVideoID(videoId)
        self.labelTitle.text = titleString
    }
    
    @IBAction func onBack(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
}
