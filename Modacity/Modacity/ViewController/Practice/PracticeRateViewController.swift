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
    var practiceItem: PracticeItem!
    
    @IBOutlet weak var rateView: FloatRatingView!
    @IBOutlet weak var labelPracticeName: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        if self.playlistViewModel != nil {
            self.labelPracticeName.text = self.playlistViewModel.currentPracticeEntry.practiceItem()?.name ?? ""
        } else {
            self.labelPracticeName.text = self.practiceItem.name ?? ""
        }
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
        if self.playlistViewModel != nil {
            if !self.playlistViewModel.next() {
                if var controllers = self.navigationController?.viewControllers {
                    for idx in 0..<controllers.count {
                        if controllers[idx] is PracticeViewController {
                            controllers.remove(at: idx)
                            break
                        }
                    }
                    controllers.removeLast()
                    let controller = UIStoryboard(name: "playlist", bundle: nil).instantiateViewController(withIdentifier: "PlaylistFinishViewController") as! PlaylistFinishViewController
                    controller.playlistDetailsViewModel = self.playlistViewModel
                    self.navigationController?.pushViewController(controller, animated: true)
                }
                
            } else {
                if var controllers = self.navigationController?.viewControllers {
                    for idx in 0..<controllers.count {
                        if controllers[idx] is PracticeViewController {
                            controllers.remove(at: idx)
                            break
                        }
                    }
                    
                    var controllerId = "PracticeViewController"
                    if AppUtils.sizeModelOfiPhone() == .iphone4_35in || AppUtils.sizeModelOfiPhone() == .iphone5_4in {
                        controllerId = "PracticeViewControllerSmallSizes"
                    }
                    let controller = UIStoryboard(name: "practice", bundle: nil).instantiateViewController(withIdentifier: controllerId) as! PracticeViewController
                    controller.playlistViewModel = self.playlistViewModel
                    controllers.insert(controller, at: controllers.count - 1)
                    self.navigationController?.viewControllers = controllers
                    self.navigationController?.popToViewController(controller, animated: true)
                }
            }
        } else {
            self.navigationController?.dismiss(animated: true, completion: nil)
        }
    }
    
    @IBAction func onBack(_ sender: Any) {
        if self.playlistViewModel != nil {
            if let controllers = self.navigationController?.viewControllers {
                for controller in controllers {
                    if controller is PlaylistDetailsViewController {
                        self.navigationController?.popToViewController(controller, animated: true)
                        return
                    }
                }
            }
        } else {
            self.navigationController?.dismiss(animated: true, completion: nil)
        }
    }
    
    @IBAction func onNotes(_ sender: Any) {
        let controller = UIStoryboard(name: "practice_note", bundle: nil).instantiateViewController(withIdentifier: "PracticeNotesViewController") as! PracticeNotesViewController
        controller.playlistViewModel = self.playlistViewModel
        controller.noteIsForPlaylist = false
        controller.practiceItem = self.practiceItem
        self.navigationController?.pushViewController(controller, animated: true)
    }
}

extension PracticeRateViewController: FloatRatingViewDelegate {
    func floatRatingView(_ ratingView: FloatRatingView, isUpdating rating: Double) {
        
    }
    
    func floatRatingView(_ ratingView: FloatRatingView, didUpdate rating: Double) {
        
        ModacityAnalytics.LogEvent(.RatedItem, extraParamName: "Rating", extraParamValue: rating)
        
        if self.playlistViewModel != nil {
            if let practiceItem = self.playlistViewModel.currentPracticeEntry.practiceItem() {
                self.playlistViewModel.setRating(for: practiceItem, rating: ratingView.rating)
                //        self.playlistViewModel.setRating(forPracticeItem: self.playlistViewModel.currentPracticeItem.name, rating: ratingView.rating)
            }
        } else {
            PracticeItemLocalManager.manager.setRatingValue(forItemId: self.practiceItem.id, rating: rating)
        }
    }
}
