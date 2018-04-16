//
//  PlaylistFinishViewController.swift
//  Modacity
//
//  Created by Perfect Engineer on 3/7/18.
//  Copyright © 2018 crossover. All rights reserved.
//

import UIKit

class PlaylistFinishViewController: UIViewController {
    
    @IBOutlet weak var labelPlaylistName: UILabel!
    @IBOutlet weak var labelSessionDuration: UILabel!
    @IBOutlet weak var labelSessionImprovements: UILabel!
    @IBOutlet weak var labelDurationUnits: UILabel!
    
    var playlistDetailsViewModel: PlaylistDetailsViewModel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        self.labelPlaylistName.text = self.playlistDetailsViewModel.playlistName
        ModacityAnalytics.LogStringEvent("Congratulations Screen", extraParamName: "total seconds", extraParamValue:self.playlistDetailsViewModel.sessionDurationInSecond)
        
        if let sessionDuration = self.playlistDetailsViewModel.sessionDurationInSecond {
            if sessionDuration < 60 {
                self.labelSessionDuration.text = "\(sessionDuration)"
                self.labelDurationUnits.text = "SECONDS"
            } else {
                self.labelSessionDuration.text = "\(sessionDuration / 60)"
                self.labelDurationUnits.text = "MINUTES"
            }
        } else {
            self.labelSessionDuration.text = "0"
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
}
