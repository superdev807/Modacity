//
//  PlaylistFinishViewController.swift
//  Modacity
//
//  Created by Perfect Engineer on 3/7/18.
//  Copyright © 2018 crossover. All rights reserved.
//

import UIKit
import StoreKit

class PlaylistFinishViewController: UIViewController {
    
    @IBOutlet weak var labelPlaylistName: UILabel!
    @IBOutlet weak var labelSessionDuration: UILabel!
    @IBOutlet weak var labelSessionImprovements: UILabel!
    @IBOutlet weak var labelDurationUnits: UILabel!
    
    @IBOutlet weak var buttonNotes: UIButton!
    var playlistDetailsViewModel: PlaylistContentsViewModel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        self.labelPlaylistName.text = self.playlistDetailsViewModel.playlistName
        ModacityAnalytics.LogStringEvent("Congratulations Screen", extraParamName: "total seconds", extraParamValue:self.playlistDetailsViewModel.sessionDurationInSecond)
        if #available(iOS 10.3, *) {
            SKStoreReviewController.requestReview()
        }
        let sessionDuration = self.playlistDetailsViewModel.sessionDurationInSecond ?? 0
        if sessionDuration < 60 {
            self.labelSessionDuration.text = "\(sessionDuration)"
            self.labelDurationUnits.text = "SECONDS"
        } else {
            self.labelSessionDuration.text = "\(sessionDuration / 60)"
            self.labelDurationUnits.text = "MINUTES"
        }
        if self.playlistDetailsViewModel.playlistName == "" {
            self.buttonNotes.isHidden = true
        } else {
            self.buttonNotes.isHidden = false
        }
        
        self.labelSessionImprovements.text = "\(AppOveralDataManager.manager.calculateStreakDays())"
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "sid_set_reminder" {
            let controller = segue.destination as! SetReminderViewController
            controller.playlistParentViewModel = self.playlistDetailsViewModel
        }
    }
    
    @IBAction func onBack(_ sender: Any) {
        ModacityAnalytics.LogStringEvent("Congrats Screen Back Button")
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func onRemindMe(_ sender: Any) {
        ModacityAnalytics.LogStringEvent("Congrats Screen Reminder Button")
    }
    
    @IBAction func onSkip(_ sender: Any) {
        self.navigationController?.dismiss(animated: true, completion: nil)
        ModacityAnalytics.LogStringEvent("Congrats Screen Skip Button")
    }
    
    @IBAction func onNotes(_ sender: Any) {
        let detailsViewController = UIStoryboard(name: "details", bundle: nil).instantiateViewController(withIdentifier: "DetailsViewController") as! DetailsViewController
        detailsViewController.playlistItemId = self.playlistDetailsViewModel.playlist.id
        detailsViewController.startTabIdx = 2
        self.navigationController?.pushViewController(detailsViewController, animated: true)        
        ModacityAnalytics.LogStringEvent("Congrats Screen Notes Button")
    }
}
