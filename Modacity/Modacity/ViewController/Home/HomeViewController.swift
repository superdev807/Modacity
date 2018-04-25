//
//  HomeViewController.swift
//  Modacity
//
//  Created by Perfect Engineer on 1/10/18.
//  Copyright © 2018 crossover. All rights reserved.
//

import UIKit
import Amplitude_iOS
class HomeViewController: UIViewController {

    @IBOutlet weak var textfieldTotalHours: UITextField!
    @IBOutlet weak var textfieldDayStreak: UITextField!
    @IBOutlet weak var textfieldImprovements: UITextField!
    @IBOutlet weak var viewEmptyPanel: UIView!
    @IBOutlet weak var collectionViewRecentPlaylists: UICollectionView!
    @IBOutlet weak var collectionViewFavoritePlaylists: UICollectionView!
    @IBOutlet weak var labelFavoritesHeader: UILabel!
    @IBOutlet weak var labelRecentHeader: UILabel!
    @IBOutlet weak var labelTotalTimeCaption: UILabel!
    @IBOutlet weak var labelWelcome: UILabel!
    @IBOutlet weak var labelEmpty: UILabel!
    @IBOutlet weak var constraintForHeaderImageViewHeight: NSLayoutConstraint!
    @IBOutlet weak var constraintForContentViewTopSpace: NSLayoutConstraint!
    
    @IBOutlet weak var constraintForRecentCollectionViewHeight: NSLayoutConstraint!
    @IBOutlet weak var constraintForFavoritesCollectionViewHeight: NSLayoutConstraint!
    
    private var formatter: NumberFormatter!
    
    private var viewModel = HomeViewModel()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        NotificationCenter.default.addObserver(self, selector: #selector(configureNameLabels), name: AppConfig.appNotificationProfileUpdated, object: nil)
        self.configureUI()
        self.bindViewModel()
        ModacityAnalytics.LogStringEvent("Home Screen")
        
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationItem.title = "Home"
        self.viewModel.loadRecentPlaylists()
    }
    
    func bindViewModel() {
        
        self.viewModel.subscribe(to: "dashboardPlaylistsCount") { _, _, count in
            if let count = count as? Int {
                if count > 0 {
                    self.viewEmptyPanel.isHidden = true
                    self.labelRecentHeader.isHidden = false
                    return
                }
            }
            self.labelRecentHeader.isHidden = true
            self.viewEmptyPanel.isHidden = false
        }
        
        self.viewModel.subscribe(to: "recentPlaylists") { (_, _, _) in
            self.collectionViewRecentPlaylists.reloadData()
        }
        
        self.viewModel.subscribe(to: "favoriteItems") { (_, _, favoriteItems) in
            if let playlists = favoriteItems as? [[String:Any]] {
                if playlists.count > 0 {
                    self.labelFavoritesHeader.isHidden = false
                } else {
                    self.labelFavoritesHeader.isHidden = true
                }
                self.collectionViewFavoritePlaylists.reloadData()
                return
            }
            self.labelFavoritesHeader.isHidden = true
        }
        
        self.viewModel.subscribe(to: "totalWorkingSeconds") { (_, _, totalWorkingSeconds) in
            if let seconds = totalWorkingSeconds as? Int {
                if seconds < 30 * 60 {
                    self.textfieldTotalHours.text = String(format:"%.1f", Double(seconds) / 60.0)
                    self.labelTotalTimeCaption.text = "TOTAL MINUTES"
                } else {
                    self.textfieldTotalHours.text = String(format:"%.1f", Double(seconds) / 3600.0)
                    self.labelTotalTimeCaption.text = "TOTAL HOURS"
                }
            } else {
                self.textfieldTotalHours.text = "0"
                self.labelTotalTimeCaption.text = "TOTAL HOURS"
            }
        }
        
        self.viewModel.subscribe(to: "totalImprovements") { (_, _, totalImprovements) in
            self.textfieldImprovements.text = "\(totalImprovements as? Int ?? 0)"
        }
        
        self.viewModel.subscribe(to: "streakDays") { (_, _, streakDays) in
            self.textfieldDayStreak.text = "\(streakDays as? Int ?? 0)"
        }
    }
    
    func configureUI() {
        self.textfieldTotalHours.delegate = self
        self.textfieldTotalHours.tintColor = Color.white
        
        self.textfieldDayStreak.delegate = self
        self.textfieldDayStreak.tintColor = Color.white
        
        self.textfieldImprovements.delegate = self
        self.textfieldImprovements.tintColor = Color.white
        
        self.formatter = NumberFormatter()
        self.formatter.numberStyle = .decimal
        self.formatter.minimum = 0
        
        self.labelFavoritesHeader.isHidden = true
        
        if AppUtils.sizeModelOfiPhone() == .iphone4_35in {
            self.constraintForHeaderImageViewHeight.constant = 250
            self.constraintForContentViewTopSpace.constant = 220
            self.constraintForRecentCollectionViewHeight.constant = 80
            self.constraintForFavoritesCollectionViewHeight.constant  = 80
        } else if AppUtils.sizeModelOfiPhone() == .iphone5_4in {
            self.constraintForHeaderImageViewHeight.constant = 250
            self.constraintForContentViewTopSpace.constant = 220
            self.constraintForRecentCollectionViewHeight.constant = 120
            self.constraintForFavoritesCollectionViewHeight.constant  = 120
        } else {
            self.constraintForHeaderImageViewHeight.constant = 270
            self.constraintForContentViewTopSpace.constant = 266
            self.constraintForRecentCollectionViewHeight.constant = 120
            self.constraintForFavoritesCollectionViewHeight.constant  = 120
        }
        
        configureNameLabels()
        
    }
    
    @objc func configureNameLabels() {
        if let me = MyProfileLocalManager.manager.me {
            self.labelWelcome.text = "Welcome \(me.displayName())!"
            self.labelEmpty.text = "Hi \(me.displayName()), it looks like you’re new here."
            Amplitude.instance().setUserId(me.email)
        } else {
            self.labelWelcome.text = "Welcome!"
            self.labelEmpty.text = "It looks like you're new here."
        }
    }

    @IBAction func onTotalHours(_ sender: Any) {
        self.textfieldTotalHours.becomeFirstResponder()
    }
    
    @IBAction func onEditingChangedOnTotalHours(_ sender:UITextField) {
        if sender.text!.contains(".") {
        } else {
            sender.text = "\(Int(sender.text ?? "") ?? 0)"
        }
    }
    
    @IBAction func onDidEndOnExitOnFields(_ sender: UITextField) {
        if sender == self.textfieldTotalHours {
            self.textfieldDayStreak.becomeFirstResponder()
        } else if sender == self.textfieldDayStreak {
            self.textfieldImprovements.becomeFirstResponder()
        } else {
            self.textfieldImprovements.resignFirstResponder()
        }
    }
    
    @IBAction func onMenu(_ sender: Any) {
        self.sideMenuController?.showLeftViewAnimated()
    }
    
}

extension HomeViewController: UITextFieldDelegate {
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        if string == "\n" {
            return true
        }
        return formatter.number(from:"\(textField.text ?? "")\(string)") != nil
    }
}

extension HomeViewController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if collectionView == self.collectionViewRecentPlaylists {
            return self.viewModel.recentPlaylists.count
        } else {
            return self.viewModel.favoriteItems.count
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "PlaylistCell", for: indexPath)
        if let label = cell.viewWithTag(10) as? UILabel {
            if collectionView == self.collectionViewRecentPlaylists {
                label.text = self.viewModel.recentPlaylists[indexPath.row].name
            } else {
                if let iconView = cell.viewWithTag(11) as? UIImageView {
                    let item = self.viewModel.favoriteItems[indexPath.row]
                    let typeLabel = cell.viewWithTag(12) as! UILabel
                    if let type = item["type"] as? String {
                        if type == "playlist" {
                            if let playlist = item["data"] as? Playlist {
                                label.text = playlist.name
                                typeLabel.text = "PLAYLIST"
                            }
                            iconView.image = UIImage(named: "icon_playlist_blue")
                        } else {
                            if let practiceItem = item["data"] as? PracticeItem {
                                label.text = practiceItem.name
                                typeLabel.text = "MUSIC"
                            }
                            iconView.image = UIImage(named: "icon_music_pink")
                        }
                    }
                }
            }
        }
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        if collectionView == self.collectionViewRecentPlaylists {
            let deliverViewModel = PlaylistAndPracticeDeliverModel()
            deliverViewModel.deliverPlaylist = self.viewModel.recentPlaylists[indexPath.row]
            let controller = UIStoryboard(name: "playlist", bundle: nil).instantiateViewController(withIdentifier: "PlaylistDetailsViewController") as! PlaylistDetailsViewController
            controller.parentViewModel = deliverViewModel
            let nav = UINavigationController(rootViewController: controller)
            nav.isNavigationBarHidden = true
            self.tabBarController?.present(nav, animated: true, completion: nil)
        } else {
            
            let item = self.viewModel.favoriteItems[indexPath.row]
            if (item["type"] as? String ?? "") == "playlist" {
                
                let deliverViewModel = PlaylistAndPracticeDeliverModel()
                deliverViewModel.deliverPlaylist = item["data"] as! Playlist
                let controller = UIStoryboard(name: "playlist", bundle: nil).instantiateViewController(withIdentifier: "PlaylistDetailsViewController") as! PlaylistDetailsViewController
                controller.parentViewModel = deliverViewModel
                let nav = UINavigationController(rootViewController: controller)
                nav.isNavigationBarHidden = true
                self.tabBarController?.present(nav, animated: true, completion: nil)
                ModacityAnalytics.LogStringEvent("Selected Favorite Playlist", extraParamName: "Name", extraParamValue: deliverViewModel.deliverPlaylist.name)
                
            } else {
                
                let practiceItem = item["data"] as! PracticeItem
                let controller = UIStoryboard(name: "practice", bundle: nil).instantiateViewController(withIdentifier: "PracticeScene") as! UINavigationController
                let practiceViewController = controller.viewControllers[0] as! PracticeViewController
                practiceViewController.practiceItem = practiceItem
                self.tabBarController?.present(controller, animated: true, completion: nil)
                
                ModacityAnalytics.LogStringEvent("Selected Favorite Item", extraParamName: "Name", extraParamValue: practiceItem.name)
                
            }
        }
        
        
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        if AppUtils.sizeModelOfiPhone() == .iphone4_35in {
            return CGSize(width: 80, height: 70)
        }
        return CGSize(width: 130, height: 115)
    }
    
}
