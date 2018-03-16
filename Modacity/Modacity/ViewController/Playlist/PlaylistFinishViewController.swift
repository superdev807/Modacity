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
        
        if let sessionDuration = self.playlistDetailsViewModel.sessionDurationInSecond {
            if sessionDuration < 60 {
                self.labelSessionDuration.text = "\(sessionDuration)"
                self.labelDurationUnits.text = "SECONDS"
            } else {
                self.labelSessionDuration.text = "\(sessionDuration / 60)"
                self.labelDurationUnits.text = "MINUTES"
            }
        }
        
        self.labelSessionImprovements.text = "\(self.playlistDetailsViewModel.totalImprovements)"
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func onBack(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func onRemindMe(_ sender: Any) {
        
    }
    
    @IBAction func onSkip(_ sender: Any) {
        self.navigationController?.dismiss(animated: true, completion: nil)
    }
}
