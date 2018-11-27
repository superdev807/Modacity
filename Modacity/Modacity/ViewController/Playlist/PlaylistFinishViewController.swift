//
//  PlaylistFinishViewController.swift
//  Modacity
//
//  Created by Benjamin Chris on 3/7/18.
//  Copyright © 2018 Modacity, Inc. All rights reserved.
//

import UIKit
import StoreKit

class PlaylistFinishViewController: ModacityParentViewController {
    
    @IBOutlet weak var labelPlaylistName: UILabel!
    @IBOutlet weak var labelSessionDuration: UILabel!
    @IBOutlet weak var labelSessionImprovements: UILabel!
    @IBOutlet weak var labelDurationUnits: UILabel!
    @IBOutlet weak var buttonNotes: UIButton!
    
    var playlistDetailsViewModel: PlaylistContentsViewModel!
    
    @IBOutlet weak var labelQuote: UILabel!
    
    @IBOutlet weak var labelQuotePersonName: UILabel!
    @IBOutlet weak var viewQuoteBox: UIView!
    @IBOutlet weak var viewSeparator: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        self.labelPlaylistName.text = self.playlistDetailsViewModel.playlistName
        ModacityAnalytics.LogStringEvent("Congratulations Screen", extraParamName: "total seconds", extraParamValue:self.playlistDetailsViewModel.sessionDurationInSecond)
        if #available(iOS 10.3, *) {
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
        
        if let dayStreak = LocalCacheManager.manager.dayStreak() {
            self.labelSessionImprovements.text = "\(dayStreak)"
        } else {
            self.labelSessionImprovements.text = ""
        }
        
        DispatchQueue.global(qos: .background).async {
            let data = PracticingDailyLocalManager.manager.statsPracticing()
            let dayStreakValues = data["streak"] ?? 1
            
            DispatchQueue.main.async {
                self.labelSessionImprovements.text = "\(dayStreakValues)"
            }
        }
        
        if AppUtils.sizeModelOfiPhone() == .iphone4_35in {
            self.viewQuoteBox.isHidden = true
        } else if AppUtils.sizeModelOfiPhone() == .iphone5_4in {
            self.viewSeparator.isHidden = true
        }
        
        let quote = MusicQuotesManager.manager.randomeQuote()
        self.labelQuote.text = quote["quote"]
        self.labelQuotePersonName.text = quote["person"]
        
        if !AppOveralDataManager.manager.finishedFirstPlaylist() {
            AppOveralDataManager.manager.setFinishedFirstPlaylist()
        }
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
        
        if Authorizer.authorizer.isGuestLogin() {
            self.processSignup()
        } else {
            self.navigationController?.dismiss(animated: true, completion: nil)
        }
        ModacityAnalytics.LogStringEvent("Congrats Screen Skip Button")
    }
    
    func openNotes() {
        let detailsViewController = UIStoryboard(name: "details", bundle: nil).instantiateViewController(withIdentifier: "DetailsViewController") as! DetailsViewController
        detailsViewController.playlistItemId = self.playlistDetailsViewModel.playlist.id
        detailsViewController.startTabIdx = 2
        self.navigationController?.pushViewController(detailsViewController, animated: true)
        ModacityAnalytics.LogStringEvent("Congrats Screen Notes Button")
    }
    
    @IBAction func onNotes(_ sender: Any) {
        DropdownMenuView.instance.show(in: self.view,
                                       on: buttonNotes,
                                       rows: [["icon":"icon_notes", "text":"Details"]]) { (row) in
                                                self.openNotes()
        }
    }
    
    func processSignup() {
        let controller = UIStoryboard(name: "welcome", bundle: nil).instantiateViewController(withIdentifier: "LoginScene") as! UINavigationController
        self.present(controller, animated: true, completion: nil)
    }
}
