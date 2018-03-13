//
//  TabBarViewController.swift
//  Modacity
//
//  Created by Perfect Engineer on 1/8/18.
//  Copyright © 2018 crossover. All rights reserved.
//

import UIKit

class TabBarViewController: UITabBarController {
    
    var viewTabbar: UIView!
    var viewTabbarButtonsContainer: UIView!
    
    // Tabbar buttons
    let buttonHome = UIButton()
    let buttonPlaylist = UIButton()
    let buttonRecord = UIButton()
    
    var configured = false
    
    var startingTabIndex = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        self.tabBar.isHidden = true
    }
    
    deinit {
        for subview in view.subviews {
            subview.removeFromSuperview()
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func tabBar(_ tabBar: UITabBar, didSelect item: UITabBarItem) {
        self.processButtonsSelection()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if !self.configured {
            self.configureOverlayView()
            self.configureChildViews()
            self.configured = true
            
            if self.startingTabIndex == 1 {
                self.onTabPlaylist()
            } else if self.startingTabIndex == 2 {
                self.onTabRecord()
            }
        }
    }
    
    // ==========
    // In order to implement pixel-perfect design, we should configure tab bar as a customized view
    // ==========
    
    func configureOverlayView() {
//        self.addBackground()
        self.addTabbarView()
        self.addButtons()
    }
    
    // Add background image view
    
    func addBackground() {
        let imageViewBackground = UIImageView(image: UIImage(named: "bg_common"))
        self.view.insertSubview(imageViewBackground, at: 0)
        
        imageViewBackground.translatesAutoresizingMaskIntoConstraints = false
        let constraintTop = NSLayoutConstraint(item: imageViewBackground, attribute: .top, relatedBy: .equal, toItem: self.view, attribute: .top, multiplier: 1, constant: 0)
        self.view.addConstraint(constraintTop)
        
        let constraintBottom = NSLayoutConstraint(item: imageViewBackground, attribute: .bottom, relatedBy: .equal, toItem: self.view, attribute: .bottom, multiplier: 1, constant: 0)
        self.view.addConstraint(constraintBottom)
        
        let constraintLeading = NSLayoutConstraint(item: imageViewBackground, attribute: .leading, relatedBy: .equal, toItem: self.view, attribute: .leading, multiplier: 1, constant: 0)
        self.view.addConstraint(constraintLeading)
        
        let constraintTrailing = NSLayoutConstraint(item: imageViewBackground, attribute: .trailing, relatedBy: .equal, toItem: self.view, attribute: .trailing, multiplier: 1, constant: 0)
        self.view.addConstraint(constraintTrailing)
    }
    
    // Add tabbar view with background image
    
    func addTabbarView() {
        self.viewTabbar = UIView()
        let backgroundImageView = UIImageView(image: UIImage(named: "bg_tabbar"))
        self.viewTabbar.addSubview(backgroundImageView)
        self.view.addSubview(self.viewTabbar)
        
        self.viewTabbar.translatesAutoresizingMaskIntoConstraints = false
        backgroundImageView.translatesAutoresizingMaskIntoConstraints = false
        
        let constraintTabbarViewBottom = NSLayoutConstraint(item: self.viewTabbar, attribute: .bottom, relatedBy: .equal, toItem: self.view, attribute: .bottom, multiplier: 1, constant: 0)
        self.view.addConstraint(constraintTabbarViewBottom)
        let constraintTabbarViewLeading = NSLayoutConstraint(item: self.viewTabbar, attribute: .leading, relatedBy: .equal, toItem: self.view, attribute: .leading, multiplier: 1, constant: 0)
        self.view.addConstraint(constraintTabbarViewLeading)
        let constraintTabbarViewTrailing = NSLayoutConstraint(item: self.viewTabbar, attribute: .trailing, relatedBy: .equal, toItem: self.view, attribute: .trailing, multiplier: 1, constant: 0)
        self.view.addConstraint(constraintTabbarViewTrailing)
        
        let constraintTop = NSLayoutConstraint(item: backgroundImageView, attribute: .top, relatedBy: .equal, toItem: self.viewTabbar, attribute: .top, multiplier: 1, constant: 0)
        self.viewTabbar.addConstraint(constraintTop)
        let constraintBottom = NSLayoutConstraint(item: backgroundImageView, attribute: .bottom, relatedBy: .equal, toItem: self.viewTabbar, attribute: .bottom, multiplier: 1, constant: 0)
        self.viewTabbar.addConstraint(constraintBottom)
        let constraintLeading = NSLayoutConstraint(item: backgroundImageView, attribute: .leading, relatedBy: .equal, toItem: self.viewTabbar, attribute: .leading, multiplier: 1, constant: 0)
        self.viewTabbar.addConstraint(constraintLeading)
        let constraintTrailing = NSLayoutConstraint(item: backgroundImageView, attribute: .trailing, relatedBy: .equal, toItem: self.viewTabbar, attribute: .trailing, multiplier: 1, constant: 0)
        self.viewTabbar.addConstraint(constraintTrailing)
        var tabbarHeight = CGFloat(64)
        if AppUtils.iphoneIsXModel() {
            tabbarHeight = 84
        }
        let constraintTabbarViewHeight = NSLayoutConstraint(item: backgroundImageView, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1, constant: tabbarHeight)
        backgroundImageView.addConstraint(constraintTabbarViewHeight)
        
    }
    
    // Add tabbar buttons
    
    func addButtons() {
        self.addTabbarButtonsContainer()
        self.addTabbarButtons()
        self.addNewPlaylistButton()
    }
    
    func addTabbarButtonsContainer() {
        self.viewTabbarButtonsContainer = UIView()
        self.viewTabbar.addSubview(self.viewTabbarButtonsContainer)
        
        self.viewTabbarButtonsContainer.translatesAutoresizingMaskIntoConstraints = false
        let constraintTop = NSLayoutConstraint(item: self.viewTabbarButtonsContainer, attribute: .top, relatedBy: .equal, toItem: self.viewTabbar, attribute: .top, multiplier: 1, constant: 0)
        self.viewTabbar.addConstraint(constraintTop)
        
        var bottomConstraint = CGFloat(0)
        if AppUtils.iphoneIsXModel() {
            bottomConstraint = -20
        }
        let constraintBottom = NSLayoutConstraint(item: self.viewTabbarButtonsContainer, attribute: .bottom, relatedBy: .equal, toItem: self.viewTabbar, attribute: .bottom, multiplier: 1, constant: bottomConstraint)
        self.viewTabbar.addConstraint(constraintBottom)
        
        let constraintLeading = NSLayoutConstraint(item: self.viewTabbarButtonsContainer, attribute: .leading, relatedBy: .equal, toItem: self.viewTabbar, attribute: .leading, multiplier: 1, constant: 15)
        self.viewTabbar.addConstraint(constraintLeading)
        
        let constraintTrailing = NSLayoutConstraint(item: self.viewTabbarButtonsContainer, attribute: .trailing, relatedBy: .equal, toItem: self.viewTabbar, attribute: .trailing, multiplier: 1, constant: -15)
        self.viewTabbar.addConstraint(constraintTrailing)
    }
    
    func addTabbarButtons() {
        
        self.buttonHome.setImage(UIImage(named: "icon_tab_home_gray"), for: .normal)
        self.buttonHome.setImage(UIImage(named: "icon_tab_home_blue"), for: .highlighted)
        self.buttonHome.setImage(UIImage(named: "icon_tab_home_blue"), for: .selected)
        self.buttonHome.translatesAutoresizingMaskIntoConstraints = false
        self.buttonHome.isSelected = true
        self.buttonHome.addTarget(self, action: #selector(onTabHome), for: .touchUpInside)
        self.viewTabbarButtonsContainer.addSubview(self.buttonHome)
        
        let constraintHomeLeading = NSLayoutConstraint(item: self.buttonHome, attribute: .leading, relatedBy: .equal, toItem: self.viewTabbarButtonsContainer, attribute: .leading, multiplier: 1, constant: 0)
        self.viewTabbarButtonsContainer.addConstraint(constraintHomeLeading)
        let constraintHomeTop = NSLayoutConstraint(item: self.buttonHome, attribute: .top, relatedBy: .equal, toItem: self.viewTabbarButtonsContainer, attribute: .top, multiplier: 1, constant: 0)
        self.viewTabbarButtonsContainer.addConstraint(constraintHomeTop)
        let constraintHomeBottom = NSLayoutConstraint(item: self.buttonHome, attribute: .bottom, relatedBy: .equal, toItem: self.viewTabbarButtonsContainer, attribute: .bottom, multiplier: 1, constant: 0)
        self.viewTabbarButtonsContainer.addConstraint(constraintHomeBottom)
        let constraintHomeWidth = NSLayoutConstraint(item: self.buttonHome, attribute: .width, relatedBy: .equal, toItem: self.viewTabbarButtonsContainer, attribute: .width, multiplier: 0.25, constant: 0)
        self.viewTabbarButtonsContainer.addConstraint(constraintHomeWidth)
        
        self.buttonPlaylist.setImage(UIImage(named: "icon_tab_playlist_gray"), for: .normal)
        self.buttonPlaylist.setImage(UIImage(named: "icon_tab_playlist_blue"), for: .highlighted)
        self.buttonPlaylist.setImage(UIImage(named: "icon_tab_playlist_blue"), for: .selected)
        self.buttonPlaylist.translatesAutoresizingMaskIntoConstraints = false
        self.buttonPlaylist.addTarget(self, action: #selector(onTabPlaylist), for: .touchUpInside)
        self.viewTabbarButtonsContainer.addSubview(self.buttonPlaylist)
        
        let constraintPlaylistLeading = NSLayoutConstraint(item: self.buttonHome, attribute: .trailing, relatedBy: .equal, toItem: self.buttonPlaylist, attribute: .leading, multiplier: 1, constant: 0)
        self.viewTabbarButtonsContainer.addConstraint(constraintPlaylistLeading)
        let constraintPlaylistTop = NSLayoutConstraint(item: self.buttonPlaylist, attribute: .top, relatedBy: .equal, toItem: self.viewTabbarButtonsContainer, attribute: .top, multiplier: 1, constant: 0)
        self.viewTabbarButtonsContainer.addConstraint(constraintPlaylistTop)
        let constraintPlaylistBottom = NSLayoutConstraint(item: self.buttonPlaylist, attribute: .bottom, relatedBy: .equal, toItem: self.viewTabbarButtonsContainer, attribute: .bottom, multiplier: 1, constant: 0)
        self.viewTabbarButtonsContainer.addConstraint(constraintPlaylistBottom)
        let constraintPlaylistWidth = NSLayoutConstraint(item: self.buttonPlaylist, attribute: .width, relatedBy: .equal, toItem: self.viewTabbarButtonsContainer, attribute: .width, multiplier: 0.25, constant: 0)
        self.viewTabbarButtonsContainer.addConstraint(constraintPlaylistWidth)
        
        self.buttonRecord.setImage(UIImage(named: "icon_tab_recording_gray"), for: .normal)
        self.buttonRecord.setImage(UIImage(named: "icon_tab_recording_blue"), for: .highlighted)
        self.buttonRecord.setImage(UIImage(named: "icon_tab_recording_blue"), for: .selected)
        self.buttonRecord.translatesAutoresizingMaskIntoConstraints = false
        self.buttonRecord.addTarget(self, action: #selector(onTabRecord), for: .touchUpInside)
        self.viewTabbarButtonsContainer.addSubview(self.buttonRecord)
        
        let constraintRecordLeading = NSLayoutConstraint(item: self.buttonPlaylist, attribute: .trailing, relatedBy: .equal, toItem: self.buttonRecord, attribute: .leading, multiplier: 1, constant: 0)
        self.viewTabbarButtonsContainer.addConstraint(constraintRecordLeading)
        let constraintRecordTop = NSLayoutConstraint(item: self.buttonRecord, attribute: .top, relatedBy: .equal, toItem: self.viewTabbarButtonsContainer, attribute: .top, multiplier: 1, constant: 0)
        self.viewTabbarButtonsContainer.addConstraint(constraintRecordTop)
        let constraintRecordBottom = NSLayoutConstraint(item: self.buttonRecord, attribute: .bottom, relatedBy: .equal, toItem: self.viewTabbarButtonsContainer, attribute: .bottom, multiplier: 1, constant: 0)
        self.viewTabbarButtonsContainer.addConstraint(constraintRecordBottom)
        let constraintRecordWidth = NSLayoutConstraint(item: self.buttonRecord, attribute: .width, relatedBy: .equal, toItem: self.viewTabbarButtonsContainer, attribute: .width, multiplier: 0.25, constant: 0)
        self.viewTabbarButtonsContainer.addConstraint(constraintRecordWidth)
        
    }
    
    func addNewPlaylistButton() {
        let buttonAddPlaylist = UIButton()
        buttonAddPlaylist.setImage(UIImage(named: "btn_new_playlist"), for: .normal)
        buttonAddPlaylist.addTarget(self, action: #selector(onNewPlaylist), for: .touchUpInside)
        self.view.addSubview(buttonAddPlaylist)
        
        buttonAddPlaylist.translatesAutoresizingMaskIntoConstraints = false
        
        var bottomConstraing = CGFloat(10)
        if AppUtils.iphoneIsXModel() {
            bottomConstraing = 30
        }
        let constraintBottom = NSLayoutConstraint(item:self.view , attribute: .bottom, relatedBy: .equal, toItem: buttonAddPlaylist, attribute: .bottom, multiplier: 1, constant: bottomConstraing)
        self.view.addConstraint(constraintBottom)
        let constraintTrailing = NSLayoutConstraint(item: self.view, attribute: .trailing, relatedBy: .equal, toItem: buttonAddPlaylist, attribute: .trailing, multiplier: 1, constant: 10)
        self.view.addConstraint(constraintTrailing)
    }
    
    func processButtonsSelection() {
        self.buttonHome.isSelected = false
        self.buttonRecord.isSelected = false
        self.buttonPlaylist.isSelected = false
        
        if self.selectedIndex == 0 {
            self.buttonHome.isSelected = true
        } else if self.selectedIndex == 1 {
            self.buttonPlaylist.isSelected = true
        } else if self.selectedIndex == 2 {
            self.buttonRecord.isSelected = true
        }
    }
    
    func configureChildViews() {
        let homeScene = UIStoryboard(name: "home", bundle: nil).instantiateViewController(withIdentifier: "HomeScene")
        let playlistScene = UIStoryboard(name: "playlist", bundle: nil).instantiateViewController(withIdentifier: "PlaylistScene")
        let recordingScene = UIStoryboard(name: "recording", bundle: nil).instantiateViewController(withIdentifier: "RecordingScene")
        self.viewControllers = [homeScene, playlistScene, recordingScene]
    }
    
    @objc func onTabHome() {
        self.selectedIndex = 0
        self.processButtonsSelection()
    }
    
    @objc func onTabPlaylist() {
        self.selectedIndex = 1
        self.processButtonsSelection()
    }
    
    @objc func onTabRecord() {
        self.selectedIndex = 2
        self.processButtonsSelection()
    }

    @objc func onNewPlaylist() {
        let playlistCreateNew = UIStoryboard(name:"playlist", bundle: nil).instantiateViewController(withIdentifier: "playlist_control_scene")
//        let practiceScene = UIStoryboard(name: "practice", bundle: nil).instantiateViewController(withIdentifier: "PracticeScene")
        self.present(playlistCreateNew, animated: true, completion: nil)
    }

}
