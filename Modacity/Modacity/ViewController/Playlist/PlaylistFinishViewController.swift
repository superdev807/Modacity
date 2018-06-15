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
    
    @IBOutlet weak var buttonNotes: UIButton!
    var playlistDetailsViewModel: PlaylistContentsViewModel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        self.labelPlaylistName.text = self.playlistDetailsViewModel.playlistName
        ModacityAnalytics.LogStringEvent("Congratulations Screen", extraParamName: "total seconds", extraParamValue:self.playlistDetailsViewModel.sessionDurationInSecond)
        let sessionDuration = self.playlistDetailsViewModel.totalPracticedTime()
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
//        self.playlistDetailsViewModel.addPracticeTotalTime(inSec: self.playlistDetailsViewModel.totalPracticedTime())
        self.navigationController?.dismiss(animated: true, completion: nil)
        ModacityAnalytics.LogStringEvent("Congrats Screen Skip Button")
    }
    
    @IBAction func onNotes(_ sender: Any) {
        let controller = UIStoryboard(name: "practice_note", bundle: nil).instantiateViewController(withIdentifier: "PracticeNotesViewController") as! PracticeNotesViewController
        controller.playlistViewModel = self.playlistDetailsViewModel
        controller.noteIsForPlaylist = true
        self.navigationController?.pushViewController(controller, animated: true)
        ModacityAnalytics.LogStringEvent("Congrats Screen Notes Button")
    }
}
