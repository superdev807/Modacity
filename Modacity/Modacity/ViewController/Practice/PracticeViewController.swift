//
//  PracticeViewController.swift
//  Modacity
//
//  Created by Perfect Engineer on 1/10/18.
//  Copyright © 2018 crossover. All rights reserved.
//

import UIKit

class PracticeViewController: UIViewController {
    
    @IBOutlet weak var buttonFavorite: UIButton!
    
    @IBOutlet weak var labelHour: UILabel!
    @IBOutlet weak var labelMinute: UILabel!
    @IBOutlet weak var labelSeconds: UILabel!
    @IBOutlet weak var viewMinimizedDrone: UIView!
    @IBOutlet weak var viewMaximizedDrone: UIView!
    
    @IBOutlet weak var constraintForMaximizedDroneBottomSpace: NSLayoutConstraint!
    
    var isFavorite = false
    
    var timer: Timer!
    var timerRunning = false
    var timerStarted: Date!
    var secondsPrevPlayed: Int!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        self.perform(#selector(onTimerStart), with: nil, afterDelay: 0.5)
        self.constraintForMaximizedDroneBottomSpace.constant =  self.view.bounds.size.height * 336/667 - 40
    }
    
    deinit {
        self.timer.invalidate()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }
    

    @IBAction func onEnd(_ sender: Any) {
        self.navigationController?.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func onToggleFavorite(_ sender: Any) {
        self.isFavorite = !self.isFavorite
        if self.isFavorite {
            self.buttonFavorite.alpha = 1
        } else {
            self.buttonFavorite.alpha = 0.5
        }
    }
    
    @IBAction func onTapTimer(_ sender: Any) {
        if self.timerRunning {
            self.secondsPrevPlayed = Int(Date().timeIntervalSince1970 - self.timerStarted.timeIntervalSince1970) + self.secondsPrevPlayed
            self.timer.invalidate()
            self.timerRunning = false
        } else {
            self.timerStarted = Date()
            self.timer = Timer.scheduledTimer(timeInterval: 0.1, target: self, selector: #selector(onTimer), userInfo: nil, repeats: true)
            self.timerRunning = true
        }
    }
    
    @objc func onTimerStart() {
        self.timerStarted = Date()
        self.secondsPrevPlayed = 0
        self.labelHour.text = "00"
        self.labelMinute.text = "00"
        self.labelSeconds.text = "00"
        self.timer = Timer.scheduledTimer(timeInterval: 0.1, target: self, selector: #selector(onTimer), userInfo: nil, repeats: true)
        self.timerRunning = true
    }
    
    @objc func onTimer() {
        
        let date = Date()
        let diff = Int(date.timeIntervalSince1970 - self.timerStarted.timeIntervalSince1970) + self.secondsPrevPlayed
        
        self.labelHour.text = String(format:"%02d", diff / 3600)
        self.labelMinute.text = String(format:"%02d", (diff % 3600) / 60)
        self.labelSeconds.text = String(format:"%02d", diff % 60)
        
    }
    
    @IBAction func onShowDrones(_ sender: Any) {
        self.viewMaximizedDrone.isHidden = false
        self.constraintForMaximizedDroneBottomSpace.constant = 0
        UIView.animate(withDuration: 1.0) {
            self.view.layoutIfNeeded()
        }
    }
    
    @IBAction func onHideDrones(_ sender: Any) {
        self.constraintForMaximizedDroneBottomSpace.constant =  self.view.bounds.size.height * 336/667 - 40
        UIView.animate(withDuration: 1.0, animations: {
            self.view.layoutIfNeeded()
        }) { (finished) in
            if finished {
                self.viewMinimizedDrone.isHidden = false
                self.viewMaximizedDrone.isHidden = true
            }
        }
    }
    
}
