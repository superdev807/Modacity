//
//  FeedbackSentViewController.swift
//  Modacity
//
//  Created by Perfect Engineer on 2/27/18.
//  Copyright © 2018 crossover. All rights reserved.
//

import UIKit

class FeedbackSentViewController: UIViewController {
    
    var pageUIMode: Int = 0
    
    @IBOutlet weak var labelResultScreenTitle: UILabel!
    @IBOutlet weak var labelTitle: UILabel!
    @IBOutlet weak var labelSubTitle: UILabel!
    @IBOutlet weak var labelEmailAddress: UILabel!
    
    var parentRootController: FeedbackRootViewController?
    var pageIsRootFromMenu = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        self.configureForPageMode()
    }

    @IBAction func onBack(_ sender: Any) {
        if self.pageIsRootFromMenu {
            self.navigationController?.popViewController(animated: true)
        } else {
            self.navigationController?.dismiss(animated: true, completion: nil)
        }
    }
    
    func configureForPageMode() {
        if pageUIMode == 0 {
            self.labelResultScreenTitle.text = "Pro Boost"
            self.labelTitle.text = "Your Message\nWas Received!"
            self.labelSubTitle.text = "Within 24-48 hours, we'll send our answer to:"
            self.labelEmailAddress.text = MyProfileLocalManager.manager.me?.email ?? ""
        } else {
            self.labelResultScreenTitle.text = "Feedback"
            self.labelTitle.text = "Your Feedback\nWas Received!"
            self.labelSubTitle.text = "Thank you for letting us know what\nyou think and helping Modacity improve"
            self.labelEmailAddress.text = ""
        }
    }
    
}
