//
//  PracticeRateViewController.swift
//  Modacity
//
//  Created by Perfect Engineer on 3/7/18.
//  Copyright © 2018 crossover. All rights reserved.
//

import UIKit

class PracticeRateViewController: UIViewController {
    
    var playlistViewModel: PlaylistDetailsViewModel!
    
    @IBOutlet weak var rateView: FloatRatingView!
    @IBOutlet weak var labelPracticeName: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        self.labelPracticeName.text = self.playlistViewModel.currentPracticeItem.name
        self.rateView.editable = true
        self.rateView.maxRating = 5
        self.rateView.type = .halfRatings
        self.rateView.contentMode = .scaleAspectFit
        self.rateView.delegate = self
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func onNext(_ sender: Any) {
        if !self.playlistViewModel.next() {
            if let controllers = self.navigationController?.viewControllers {
                for controller in controllers {
                    if controller is PlaylistDetailsViewController {
                        self.navigationController?.popToViewController(controller, animated: true)
                        return
                    }
                }
            }
        } else {
            if var controllers = self.navigationController?.viewControllers {
                for idx in 0..<controllers.count {
                    if controllers[idx] is PracticeViewController {
                        controllers.remove(at: idx)
                        break
                    }
                }
                
                let controller = UIStoryboard(name: "practice", bundle: nil).instantiateViewController(withIdentifier: "PracticeViewController") as! PracticeViewController
                controller.playlistViewModel = self.playlistViewModel
                controllers.insert(controller, at: controllers.count - 1)
                self.navigationController?.viewControllers = controllers
                self.navigationController?.popToViewController(controller, animated: true)
            }
        }
    }
    
    @IBAction func onBack(_ sender: Any) {
        if let controllers = self.navigationController?.viewControllers {
            for controller in controllers {
                if controller is PlaylistDetailsViewController {
                    self.navigationController?.popToViewController(controller, animated: true)
                    return
                }
            }
        }
    }
}

extension PracticeRateViewController: FloatRatingViewDelegate {
    func floatRatingView(_ ratingView: FloatRatingView, isUpdating rating: Double) {
        
    }
    
    func floatRatingView(_ ratingView: FloatRatingView, didUpdate rating: Double) {
        self.playlistViewModel.setRating(forPracticeItem: self.playlistViewModel.currentPracticeItem.name, rating: ratingView.rating)
    }
}
