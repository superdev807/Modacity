//
//  HomeViewController.swift
//  Modacity
//
//  Created by Benjamin Chris on 1/10/18.
//  Copyright © 2018 Modacity, Inc. All rights reserved.
//

import UIKit
import Amplitude_iOS
import Crashlytics
import Intercom
import DGActivityIndicatorView

enum DashboardTime { case Minutes; case Hours; case Default }

class HomeViewController: UIViewController {

    @IBOutlet weak var textfieldTotalHours: UITextField!
    @IBOutlet weak var activityIndicatorTotalHours: DGActivityIndicatorView!
    
    @IBOutlet weak var textfieldDayStreak: UITextField!
    @IBOutlet weak var activityIndicatorDayStreak: DGActivityIndicatorView!
    
    @IBOutlet weak var textfieldImprovements: UITextField!
    @IBOutlet weak var activityIndicatorTotalImprovements: DGActivityIndicatorView!
    
    @IBOutlet weak var viewEmptyPanel: UIView!
    @IBOutlet weak var collectionViewRecentPlaylists: UICollectionView!
    @IBOutlet weak var activityIndicatorRecentList: DGActivityIndicatorView!
    
    @IBOutlet weak var collectionViewFavoritePlaylists: UICollectionView!
    @IBOutlet weak var activityIndicatorFavoriteList: DGActivityIndicatorView!
    
    @IBOutlet weak var labelFavoritesHeader: UILabel!
    @IBOutlet weak var labelRecentHeader: UILabel!
    @IBOutlet weak var labelTotalTimeCaption: UILabel!
    @IBOutlet weak var labelWelcome: UILabel!
    @IBOutlet weak var constraintForHeaderImageViewHeight: NSLayoutConstraint!
    @IBOutlet weak var constraintForContentViewTopSpace: NSLayoutConstraint!
    
    @IBOutlet weak var constraintForRecentsViewHeight: NSLayoutConstraint!
    @IBOutlet weak var constraintForFavoritesViewHeight: NSLayoutConstraint!
    
    @IBOutlet weak var constraintForRecentCollectionViewHeight: NSLayoutConstraint!
    @IBOutlet weak var constraintForFavoritesCollectionViewHeight: NSLayoutConstraint!
    
    private var timeDisplay: DashboardTime = .Default
    private var formatter: NumberFormatter!
    
    var metrodroneView : MetrodroneView!
    var recentPlaylists = [Playlist]()
    var favoriteItems = [[String:Any]]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        self.configureUI()
        self.showCacheValues()
        self.registerNotifications()
        self.configureNameLabels()
        
        ModacityAnalytics.LogStringEvent("Home Screen")
        
        if let appDelegate = UIApplication.shared.delegate as? AppDelegate {
            appDelegate.registerNotifications(UIApplication.shared)
        }
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    func registerNotifications() {
        NotificationCenter.default.addObserver(self, selector: #selector(configureNameLabels), name: AppConfig.appNotificationProfileUpdated, object: nil)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationItem.title = "Home"
        self.refreshDashboardValues()
        self.refreshImprovementDashboardValue()
        self.showList()
    }
    
    func activityIndicatorStyling(_ view: DGActivityIndicatorView) {
        view.size = 20
        view.tintColor = Color.white
        view.type = .ballClipRotate
        
        view.startAnimating()
    }
    
    func configureUI() {
        
        self.activityIndicatorStyling(self.activityIndicatorTotalHours)
        self.activityIndicatorStyling(self.activityIndicatorDayStreak)
        self.activityIndicatorStyling(self.activityIndicatorTotalImprovements)
        self.activityIndicatorStyling(self.activityIndicatorRecentList)
        self.activityIndicatorStyling(self.activityIndicatorFavoriteList)
        
        self.textfieldTotalHours.tintColor = Color.white
        self.textfieldDayStreak.tintColor = Color.white
        self.textfieldImprovements.tintColor = Color.white
        
        self.formatter = NumberFormatter()
        self.formatter.numberStyle = .decimal
        self.formatter.minimum = 0
        
        if AppUtils.sizeModelOfiPhone() == .iphone4_35in {
            self.constraintForHeaderImageViewHeight.constant = 230
            self.constraintForContentViewTopSpace.constant = 220
            self.constraintForRecentCollectionViewHeight.constant = 64
            self.constraintForFavoritesCollectionViewHeight.constant  = 64
        } else if AppUtils.sizeModelOfiPhone() == .iphone5_4in {
            self.constraintForHeaderImageViewHeight.constant = 230
            self.constraintForContentViewTopSpace.constant = 210
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
            
            DispatchQueue.global(qos: .background).async {
                Amplitude.instance().setUserId(me.email)
                Intercom.registerUser(withEmail: me.email)
                let userAttributes = ICMUserAttributes()
                userAttributes.name = me.displayName()
                userAttributes.email = me.email
                Intercom.updateUser(userAttributes)
            }
        } else {
            self.labelWelcome.text = "Welcome!"
        }
    }

    @IBAction func onTotalHours(_ sender: Any) {
        //self.textfieldTotalHours.becomeFirstResponder()
        if (self.timeDisplay == .Default) {
            self.timeDisplay = .Minutes
        }
        else {
            self.timeDisplay = .Default
        }
    }

    @IBAction func onMenu(_ sender: Any) {
        self.sideMenuController?.showLeftViewAnimated()
    }
    
}

extension HomeViewController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if collectionView == self.collectionViewRecentPlaylists {
            return self.recentPlaylists.count
        } else {
            return self.favoriteItems.count
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "PlaylistCell", for: indexPath)
        if let label = cell.viewWithTag(10) as? UILabel {
            if collectionView == self.collectionViewRecentPlaylists {
                label.text = self.recentPlaylists[indexPath.row].name
            } else {
                if let iconView = cell.viewWithTag(11) as? UIImageView {
                    let item = self.favoriteItems[indexPath.row]
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
            deliverViewModel.deliverPlaylist = self.recentPlaylists[indexPath.row]
            let controller = UIStoryboard(name: "playlist", bundle: nil).instantiateViewController(withIdentifier: "PlaylistContentsViewController") as! PlaylistContentsViewController
            controller.parentViewModel = deliverViewModel
            let nav = UINavigationController(rootViewController: controller)
            nav.isNavigationBarHidden = true
            self.tabBarController?.present(nav, animated: true, completion: nil)
        } else {
            
            let item = self.favoriteItems[indexPath.row]
            if (item["type"] as? String ?? "") == "playlist" {
                
                let deliverViewModel = PlaylistAndPracticeDeliverModel()
                deliverViewModel.deliverPlaylist = item["data"] as! Playlist
                let controller = UIStoryboard(name: "playlist", bundle: nil).instantiateViewController(withIdentifier: "PlaylistContentsViewController") as! PlaylistContentsViewController
                controller.parentViewModel = deliverViewModel
                let nav = UINavigationController(rootViewController: controller)
                nav.isNavigationBarHidden = true
                self.tabBarController?.present(nav, animated: true, completion: nil)
                ModacityAnalytics.LogStringEvent("Selected Favorite Playlist", extraParamName: "Name", extraParamValue: deliverViewModel.deliverPlaylist.name)
                
            } else {
                
                let practiceItem = item["data"] as! PracticeItem
                var sceneName = ""
                if AppUtils.sizeModelOfiPhone() == .iphone5_4in || AppUtils.sizeModelOfiPhone() == .iphone4_35in {
                    sceneName = "PracticeSceneForSmallSizes"
                } else {
                    sceneName = "PracticeScene"
                }
                let controller = UIStoryboard(name: "practice", bundle: nil).instantiateViewController(withIdentifier: sceneName) as! UINavigationController
                let practiceViewController = controller.viewControllers[0] as! PracticeViewController
                practiceViewController.practiceItem = practiceItem
                let deliverModel = PlaylistAndPracticeDeliverModel()
                deliverModel.deliverPracticeItem = practiceItem
                deliverModel.sessionTimeStarted = Date()
                deliverModel.sessionImproved = [ImprovedRecord]()
                practiceViewController.deliverModel = deliverModel
                practiceViewController.lastPracticeBreakTime = 0
                practiceViewController.practiceBreakTime = AppOveralDataManager.manager.practiceBreakTime() * 60
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

extension HomeViewController: MetrodroneViewDelegate {
    
    func onTapHeaderBar() {
        self.metrodroneView.isHidden = true
    }
    
    func onSubdivision() {
        self.showSubdivision()
    }
    
    func showSubdivision() {
        let subdivisionSelectView = SubdivisionSelectView()
        self.view.addSubview(subdivisionSelectView)
        let frame = self.view.convert(self.metrodroneView.buttonSubDivision.frame, from: self.metrodroneView.buttonSubDivision.superview)
        subdivisionSelectView.bottomAnchor.constraint(equalTo: self.view.topAnchor, constant: frame.origin.y).isActive = true
        subdivisionSelectView.centerXAnchor.constraint(equalTo: self.view.leadingAnchor, constant: frame.origin.x + frame.size.width / 2).isActive = true
    }
}

extension HomeViewController {
    
    func showCacheValues() {
        
        if let profileName = LocalCacheManager.manager.profileName() {
            self.labelWelcome.text = "Welcome \(profileName)!"
        } else {
            self.labelWelcome.text = "Welcome!"
        }
        
        if let totalSeconds = LocalCacheManager.manager.totalWorkingSeconds() {
            self.displayTotalWorkingSconds(totalSeconds)
        } else {
            self.textfieldTotalHours.text = ""
            self.activityIndicatorTotalHours.startAnimating()
            self.activityIndicatorTotalHours.isHidden = false
        }
        
        if let dayStreak = LocalCacheManager.manager.dayStreak() {
            self.textfieldDayStreak.text = "\(dayStreak)"
            self.activityIndicatorDayStreak.stopAnimating()
            self.activityIndicatorDayStreak.isHidden = true
        } else {
            self.textfieldDayStreak.text = ""
            self.activityIndicatorDayStreak.startAnimating()
            self.activityIndicatorDayStreak.isHidden = false
        }
    }
    
    @objc func refreshImprovementDashboardValue() {
        
        self.activityIndicatorTotalImprovements.isHidden = true
        self.activityIndicatorTotalImprovements.stopAnimating()

        if let viewModel = AppOveralDataManager.manager.viewModel {
            self.textfieldImprovements.text = "\(viewModel.totalImprovementsCount)"
        }
    }
    
    @objc func refreshDashboardValues() {
        if let model = AppOveralDataManager.manager.viewModel {
            self.activityIndicatorDayStreak.stopAnimating()
            self.activityIndicatorDayStreak.isHidden = true
            self.displayTotalWorkingSconds(model.totalPracticeSeconds)
            self.textfieldDayStreak.text = "\(model.dayStreakValues)"
        }
    }
    
    func displayTotalWorkingSconds(_ seconds: Int) {
        
        self.activityIndicatorTotalHours.stopAnimating()
        self.activityIndicatorTotalHours.isHidden = true
        
        var displayMode: DashboardTime = .Default
        if seconds < 30 * 60 {
            displayMode = .Minutes
        } else {
            displayMode = .Hours
        }
        
        if (self.timeDisplay == .Minutes) {
            displayMode = .Minutes
        }
        
        if (displayMode == .Minutes) {
            self.textfieldTotalHours.text = String(format:"%.1f", Double(seconds) / 60.0)
            self.labelTotalTimeCaption.text = "TOTAL MINUTES"
        } else {
            self.textfieldTotalHours.text = String(format:"%.1f", Double(seconds) / 3600.0)
            self.labelTotalTimeCaption.text = "TOTAL HOURS"
        }

    }
    
    @objc func showList() {
        if let viewModel = AppOveralDataManager.manager.viewModel {
            self.activityIndicatorRecentList.stopAnimating()
            self.activityIndicatorFavoriteList.stopAnimating()
            
            self.favoriteItems = viewModel.favoriteItems
            self.collectionViewFavoritePlaylists.reloadData()
            
            self.recentPlaylists = viewModel.recentPlaylists
            self.collectionViewRecentPlaylists.reloadData()
        }
    }
    
}
