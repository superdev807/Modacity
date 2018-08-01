//
//  PracticeRateViewController.swift
//  Modacity
//
//  Created by Perfect Engineer on 3/7/18.
//  Copyright © 2018 crossover. All rights reserved.
//

import UIKit

class PracticeRateViewController: UIViewController {
    
    var playlistViewModel: PlaylistContentsViewModel!
    var practiceItem: PracticeItem!
    var deliverModel: PlaylistAndPracticeDeliverModel!
    
    @IBOutlet weak var viewWalkThrough: UIView!
    @IBOutlet weak var rateView: FloatRatingView!
    @IBOutlet weak var labelPracticeName: UILabel!
    
    var walkthroughIsDismissed = false
    
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
        
        if !AppOveralDataManager.manager.walkThroughDoneForPracticeRatePage() {
            self.showWalkThrough() // for Modacity coding style, put stuff like this in separate functions... especially viewDidLoad should always read easy and be short.
        } else {
            self.walkthroughIsDismissed = true
            self.viewWalkThrough.removeFromSuperview()
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func onNext(_ sender: Any) {
        ModacityAnalytics.LogStringEvent("Pressed Rating Screen Next")
        self.storePracticeData()
        if self.playlistViewModel != nil {
            if !self.playlistViewModel.next() {
                if let controllers = self.navigationController?.viewControllers {
                    for controller in controllers {
                        if controller is PlaylistContentsViewController {
                            (controller as! PlaylistContentsViewController).justLastPracticeItemFinished = true
                            self.navigationController?.popToViewController(controller, animated: true)
                            return
                        }
                    }
                }
            } else {
                if AppOveralDataManager.manager.settingsGotoNextItemAfterRating() {
                    if var controllers = self.navigationController?.viewControllers {
                        var parentController: PlaylistContentsViewController! = nil
                        for idx in 0..<controllers.count {
                            if controllers[idx] is PracticeViewController {
                                parentController = (controllers[idx] as! PracticeViewController).parentContentViewController
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
                        controller.parentContentViewController = parentController
                        if parentController.practiceBreakTime > 0 {
                            let spentTime = self.playlistViewModel.totalPracticedTime() + self.playlistViewModel.sessionPlayedInPlaylistPage
                            controller.lastPracticeBreakTime = -1 * (spentTime % parentController.practiceBreakTime)
                            controller.practiceBreakTime = parentController.practiceBreakTime
                            ModacityDebugger.debug("Last practice break time - \(controller.lastPracticeBreakTime)")
                            ModacityDebugger.debug("Practice break time - \(controller.practiceBreakTime)")
                        } else {
                            controller.practiceBreakTime = 0
                        }
                        controllers.insert(controller, at: controllers.count - 1)
                        self.navigationController?.viewControllers = controllers
                        self.navigationController?.popToViewController(controller, animated: true)
                    }
                } else {
                    self.storePracticeData()
                    if let controllers = self.navigationController?.viewControllers {
                        for controller in controllers {
                            if controller is PlaylistContentsViewController {
                                (controller as! PlaylistContentsViewController).justLastPracticeItemFinished = true
                                self.navigationController?.popToViewController(controller, animated: true)
                                return
                            }
                        }
                    }
                }
            }
        } else {
            self.navigationController?.dismiss(animated: true, completion: nil)
        }
    }
    
    @IBAction func onBack(_ sender: Any) {
        ModacityAnalytics.LogStringEvent("Pressed Rating Screen Back")
        self.storePracticeData()
        if self.playlistViewModel != nil {
            if let controllers = self.navigationController?.viewControllers {
                for controller in controllers {
                    if controller is PlaylistContentsViewController {
                        (controller as! PlaylistContentsViewController).justLastPracticeItemFinished = true
                        self.navigationController?.popToViewController(controller, animated: true)
                        return
                    }
                }
            }
        } else {
            self.navigationController?.dismiss(animated: true, completion: nil)
        }
    }
    
    func storePracticeData() {
        if self.playlistViewModel != nil {
            let id = PracticingDailyLocalManager.manager.saveNewPracticing(practiceItemId: self.playlistViewModel.currentPracticeEntry.practiceItemId,
                                                                  started: self.playlistViewModel.sessionTimeStarted ?? Date(),
                                                                  duration: self.playlistViewModel.timePracticed[self.playlistViewModel.currentPracticeEntry.entryId] ?? 0,
                                                                  rating: self.rateView.rating,
                                                                  inPlaylist: self.playlistViewModel.playlist.id,
                                                                  forPracticeEntry: self.playlistViewModel.currentPracticeEntry.entryId,
                                                                  improvements: self.playlistViewModel.sessionImproved)
            self.playlistViewModel.playlistPracticeData.practices.append(id)
            self.playlistViewModel.playlistPracticeData.practiceTimeInSeconds = self.playlistViewModel.totalPracticedTime() + self.playlistViewModel.sessionPlayedInPlaylistPage
            PlaylistDailyLocalManager.manager.saveNewPlaylistPracticing(self.playlistViewModel.playlistPracticeData)
            self.playlistViewModel.sessionImproved = [ImprovedRecord]()
        } else {
            let practiceId = PracticingDailyLocalManager.manager.saveNewPracticing(practiceItemId: self.practiceItem.id,
                                                                  started: self.deliverModel.sessionTimeStarted ?? Date(),
                                                                  duration: self.deliverModel.sessionTime,
                                                                  rating: self.rateView.rating,
                                                                  inPlaylist: nil,
                                                                  forPracticeEntry: nil,
                                                                  improvements: self.deliverModel.sessionImproved)
            let playlistDaily = PlaylistDaily()
            playlistDaily.playlistId = "tempplaylist"
            playlistDaily.entryDateString = (self.deliverModel.sessionTimeStarted ?? Date()).toString(format: "yy-MM-dd")
            playlistDaily.fromTime = (self.deliverModel.sessionTimeStarted ?? Date()).toString(format: "HH:mm:ss")
            playlistDaily.started = (self.deliverModel.sessionTimeStarted ?? Date()).timeIntervalSince1970
            playlistDaily.practices = [practiceId]
            playlistDaily.practiceTimeInSeconds = self.deliverModel.sessionTime
            PlaylistDailyLocalManager.manager.saveNewPlaylistPracticing(playlistDaily)
            self.deliverModel.sessionImproved = [ImprovedRecord]()
        }
    }
    
    @IBAction func onNotes(_ sender: Any) {
        ModacityAnalytics.LogStringEvent("Pressed Rating Screen Item Notes")
        
        let detailsViewController = UIStoryboard(name: "details", bundle: nil).instantiateViewController(withIdentifier: "DetailsViewController") as! DetailsViewController
        
        detailsViewController.startTabIdx = 2
        
        if self.playlistViewModel != nil {
            detailsViewController.practiceItemId = self.playlistViewModel.currentPracticeEntry.practiceItemId
        } else {
            detailsViewController.practiceItemId = self.practiceItem.id
        }
        self.navigationController?.pushViewController(detailsViewController, animated: true)
    }
    
    @IBAction func onCloseWalkThrough(_ sender: Any) {
        self.dismissWalkThrough()
    }
    
    func showWalkThrough() {
        ModacityAnalytics.LogStringEvent("Rating Screen - Walkthrough - Displayed")
        self.viewWalkThrough.alpha = 0
        UIView.animate(withDuration: 0.5) {
            self.viewWalkThrough.alpha = 1
        }
    }
    func dismissWalkThrough() {
        ModacityAnalytics.LogStringEvent("Closed Rating Screen Walkthrough")
        if self.viewWalkThrough != nil && self.viewWalkThrough.superview != nil {
            UIView.animate(withDuration: 0.5, animations: {
                self.viewWalkThrough.alpha = 0
            }) { (finished) in
                if finished {
                    self.viewWalkThrough.isHidden = true
                    self.viewWalkThrough.removeFromSuperview()
                    AppOveralDataManager.manager.walkThroughPracticeRatePage()
                }
            }
        }
    }
}

extension PracticeRateViewController: FloatRatingViewDelegate {
    func floatRatingView(_ ratingView: FloatRatingView, isUpdating rating: Double) {
        if !self.walkthroughIsDismissed {
            self.dismissWalkThrough()
            self.walkthroughIsDismissed = true
        }
    }
    
    func floatRatingView(_ ratingView: FloatRatingView, didUpdate rating: Double) {
        
        ModacityAnalytics.LogEvent(.RatedItem, extraParamName: "Rating", extraParamValue: rating)
        
        if self.playlistViewModel != nil {
            if let practiceItem = self.playlistViewModel.currentPracticeEntry.practiceItem() {
                self.playlistViewModel.setRating(for: practiceItem, rating: ratingView.rating)
            }
        } else {
            PracticeItemLocalManager.manager.setRatingValue(forItemId: self.practiceItem.id, rating: rating)
        }
    }
}
