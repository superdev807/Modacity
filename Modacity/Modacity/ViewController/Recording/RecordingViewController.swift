//
//  RecordingViewController.swift
//  Modacity
//
//  Created by Perfect Engineer on 1/10/18.
//  Copyright © 2018 crossover. All rights reserved.
//

import UIKit

import AVFoundation

class RecordingViewController: UIViewController, RecordingsListViewDelegate {
    
    @IBOutlet weak var constraintForHeaderImageViewHeight: NSLayoutConstraint!
    @IBOutlet weak var imageViewHeader: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        if AppUtils.iphoneIsXModel() {
            self.constraintForHeaderImageViewHeight.constant = 108
        } else {
            self.constraintForHeaderImageViewHeight.constant = 88
        }
        
        let recordingListView = RecordingsListView()
        recordingListView.delegate = self
        self.view.addSubview(recordingListView)
        
        self.view.leadingAnchor.constraint(equalTo: recordingListView.leadingAnchor).isActive = true
        self.view.trailingAnchor.constraint(equalTo: recordingListView.trailingAnchor).isActive = true
        self.view.bottomAnchor.constraint(equalTo: recordingListView.bottomAnchor).isActive = true
        self.imageViewHeader.bottomAnchor.constraint(equalTo: recordingListView.topAnchor).isActive = true
        
        recordingListView.showRecordings(RecordingsLocalManager.manager.loadRecordings())
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationItem.title = "Playlist"
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }

    @IBAction func onMenu(_ sender: Any) {
        self.sideMenuController?.showLeftViewAnimated()
    }
    
    func onShareRecording(text: String, url: URL) {
        let activityViewController = UIActivityViewController(activityItems: [text, url], applicationActivities: nil)
        self.present(activityViewController, animated: true, completion: nil)
    }
}
