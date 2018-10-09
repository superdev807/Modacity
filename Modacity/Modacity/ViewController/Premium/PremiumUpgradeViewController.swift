//
//  PremiumUpgradeViewController.swift
//  Modacity
//
//  Created by Benjamin Chris on 19/7/18.
//  Copyright © 2018 Modacity, Inc. All rights reserved.
//

import UIKit
import MBProgressHUD

class PremiumUpgradeViewController: UIViewController {
    
    let sliderData = [["image": "premium_slider_chart",
                       "title1":"YOUR",
                       "title2":"PRACTICE STATS",
                       "desc":"For each item and playlist, see statistics on overall time, average duration, and frequency. See your personal learning curve with the star ratings graph, and get an overview of all improvements."],
                      ["image": "premium_slider_history",
                       "title1":"HISTORICAL",
                       "title2":"EXCELLENCE",
                       "desc":"Unlock a full journal-style log of your practice activity, viewable by practice item, playlist, or overall activity. Includes time spent, improvements made, and star ratings."],
                      ["image": "premium_slider_take_break",
                       "title1":"EFFECTIVE",
                       "title2":"RELAXATION",
                       "desc":"Stay mindful. Avoid getting hurt over-practicing. Set how often you want practice breaks, and Modacity will take care of the rest!"],
                      ["image": "premium_slider_note",
                       "title1":"TAKE",
                       "title2":"UNLIMITED NOTES",
                       "desc":"Unlock full note taking ability with unlimited notes per item."],
                      ]
    
    @IBOutlet weak var constraintForHeaderViewHeight: NSLayoutConstraint!
    @IBOutlet weak var labelUnlockTitle: UILabel!
    
    @IBOutlet weak var imageViewBackground: UIImageView!
    @IBOutlet weak var viewFirstPanel: UIView!
    @IBOutlet weak var viewSlidingPanel: UIView!
    @IBOutlet weak var viewSlidingContentContainer: UIView!
    @IBOutlet weak var pageControlSlider: UIPageControl!
    @IBOutlet weak var buttonFreeTrialStart: UIButton!
    @IBOutlet weak var constraintForPurchaseButtonHeight: NSLayoutConstraint!
    
    @IBOutlet weak var viewSubscriptionTermsPanel: UIView!
    @IBOutlet weak var constraintForSubscriptionTermsPanelTopSpace: NSLayoutConstraint!
    @IBOutlet weak var viewContentPanel: UIView!
    @IBOutlet weak var viewContentPanelTopSpace: NSLayoutConstraint!
    
    var resized = false
    var constraintContentPanelHeight: NSLayoutConstraint!
    var heightOfTermsPanel: CGFloat = 0
    var termsPanelSlided = false
    
    @IBOutlet weak var viewContainerPanel: UIView!
    
    var currentSlideContentView: UIView!
    
    var sliding = false
    
    var currentIdx = 0
    var indexNames: [String] = ["Stats", "History", "Breaks", "Notes", "Coming Soon"]
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        let attributed = NSMutableAttributedString(string: "UNLOCK YOUR ", attributes: [NSAttributedStringKey.font: UIFont(name: AppConfig.UI.Fonts.appFontLatoLight, size: 24)!])
        attributed.append(NSAttributedString(string: "FULL POTENTIAL", attributes: [NSAttributedStringKey.font: UIFont(name: AppConfig.UI.Fonts.appFontLatoBold, size: 24)!]))
        attributed.append(NSAttributedString(string: " WITH MODACITY PREMIUM", attributes: [NSAttributedStringKey.font: UIFont(name: AppConfig.UI.Fonts.appFontLatoLight, size: 24)!]))
        self.labelUnlockTitle.attributedText = attributed
     
        self.pageControlSlider.numberOfPages = self.sliderData.count + 1
        
        self.viewFirstPanel.isHidden = false
        self.viewSlidingPanel.isHidden = true
        
        self.buttonFreeTrialStart.layer.borderColor = Color(hexString: "#908FE6").cgColor
        self.buttonFreeTrialStart.layer.borderWidth = 1
        
        if AppUtils.iphoneIsXModel() {
            self.constraintForHeaderViewHeight.constant = 84
        } else {
            self.constraintForHeaderViewHeight.constant = 64
        }
        
        if AppUtils.sizeModelOfiPhone() == .iphone4_35in {
            self.constraintForPurchaseButtonHeight.constant = 40
        } else if AppUtils.sizeModelOfiPhone() == .iphone5_4in {
            self.constraintForPurchaseButtonHeight.constant = 50
        } else {
            self.constraintForPurchaseButtonHeight.constant = 60
        }
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if !self.resized {
            let height = self.viewContentPanel.frame.size.height
            if self.viewContentPanelTopSpace != nil {
                self.viewContainerPanel.removeConstraint(self.viewContentPanelTopSpace)
                self.constraintContentPanelHeight = self.viewContentPanel.heightAnchor.constraint(equalToConstant: height)
                self.constraintContentPanelHeight.isActive = true
                self.heightOfTermsPanel = self.viewSubscriptionTermsPanel.frame.size.height
            }
            self.resized = true
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @IBAction func onBack(_ sender: Any) {
        if self.sliding {
            ModacityAnalytics.LogStringEvent("Premium - Back from Value Prop")
            self.stopSliding()
        } else {
            ModacityAnalytics.LogStringEvent("Went Back to App")
            self.navigationController?.dismiss(animated: true, completion: nil)
        }
    }
    
    @IBAction func onStartSliding(_ sender: Any) {
        self.startSliding()
    }
    
    func startSliding() {
        
        self.showFirstSlide()
        
        UIView.transition(with: self.imageViewBackground, duration: 0.5, options: .transitionCrossDissolve, animations: {
            self.imageViewBackground.image = UIImage(named: "bg_premium")
        }, completion: nil)
        
        self.viewFirstPanel.alpha = 1
        self.viewSlidingPanel.alpha = 0
        self.viewSlidingPanel.isHidden = false
        UIView.animate(withDuration: 0.5, animations: {
            self.viewFirstPanel.alpha = 0
            self.viewSlidingPanel.alpha = 1
        }) { (finished) in
            if finished {
                self.viewFirstPanel.isHidden = true
                self.sliding = true
            }
        }
    }
    
    func stopSliding() {
        UIView.transition(with: self.imageViewBackground, duration: 0.5, options: .transitionCrossDissolve, animations: {
            self.imageViewBackground.image = UIImage(named: "bg_premium_firstpage")
        }, completion: nil)
        
        self.viewSlidingPanel.alpha = 1
        self.viewFirstPanel.alpha = 0
        self.viewFirstPanel.isHidden = false
        UIView.animate(withDuration: 0.5, animations: {
            self.viewFirstPanel.alpha = 1
            self.viewSlidingPanel.alpha = 0
        }) { (finished) in
            if finished {
                self.viewSlidingPanel.isHidden = true
                self.sliding = false
            }
        }
    }
    
    func showFirstSlide() {
        self.viewSlidingContentContainer.subviews.forEach { $0.removeFromSuperview() }
        let slideView = PremiumUpgradeSlideView()
        slideView.delegate = self
        self.viewSlidingContentContainer.addSubview(slideView)
        self.viewSlidingContentContainer.topAnchor.constraint(equalTo: slideView.topAnchor).isActive = true
        self.viewSlidingContentContainer.leadingAnchor.constraint(equalTo: slideView.leadingAnchor).isActive = true
        self.viewSlidingContentContainer.trailingAnchor.constraint(equalTo: slideView.trailingAnchor).isActive = true
        self.viewSlidingContentContainer.bottomAnchor.constraint(equalTo: slideView.bottomAnchor).isActive = true
        self.currentSlideContentView = slideView
        self.pageControlSlider.currentPage = 0
    }
    
    @IBAction func onStartFreeTrial(_ sender: Any) {
        ModacityAnalytics.LogStringEvent("Processing Free Trial", extraParamName: "currentView", extraParamValue: self.pageControlSlider.currentPage)
        
        self.buttonFreeTrialStart.setTitle("PROCESSING...", for: .normal)
        self.view.isUserInteractionEnabled = false
        NotificationCenter.default.addObserver(self, selector: #selector(onUpgradedSucceeded), name: IAPHelper.appNotificationSubscriptionSucceeded, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(onUpgradeFailed), name: IAPHelper.appNotificationSubscriptionFailed, object: nil)
        PremiumDataManager.manager.upgrade()
    }
    
    @IBAction func onRestorePayment(_ sender: Any) {
        ModacityAnalytics.LogStringEvent("Initiated Restore Subscription")
        MBProgressHUD.showAdded(to: self.view, animated: true)
        NotificationCenter.default.addObserver(self, selector: #selector(onUpgradedSucceeded), name: IAPHelper.appNotificationSubscriptionSucceeded, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(onUpgradeFailed), name: IAPHelper.appNotificationSubscriptionFailed, object: nil)
        IAPHelper.helper.restore()
    }
    
    @objc func onUpgradedSucceeded(_ notification: Notification) {
        ModacityAnalytics.LogStringEvent("Upgrade Succeeded")
        MBProgressHUD.hide(for: self.view, animated: true)
        NotificationCenter.default.removeObserver(self, name: IAPHelper.appNotificationSubscriptionSucceeded, object: nil)
        NotificationCenter.default.removeObserver(self, name: IAPHelper.appNotificationSubscriptionFailed, object: nil)
        
        self.view.isUserInteractionEnabled = true
        
        self.performSegue(withIdentifier: "sid_done", sender: nil)
    }
    
    @objc func onUpgradeFailed(_ notification:Notification) {
        ModacityAnalytics.LogStringEvent(" Upgrade Failed")
        MBProgressHUD.hide(for: self.view, animated: true)
        NotificationCenter.default.removeObserver(self, name: IAPHelper.appNotificationSubscriptionSucceeded, object: nil)
        NotificationCenter.default.removeObserver(self, name: IAPHelper.appNotificationSubscriptionFailed, object: nil)
        
        self.view.isUserInteractionEnabled = true
        self.buttonFreeTrialStart.setTitle("TRY 2 WEEKS FREE", for: .normal)
        if let userInfo = notification.userInfo,
            let error = userInfo["error"] as? String {
            AppUtils.showSimpleAlertMessage(for: self, title: nil, message: error)
        }
    }
    
    @IBAction func onTerms(_ sender: Any) {
        if #available(iOS 10.0, *) {
            UIApplication.shared.open(URL(string:AppConfig.Links.appConfigTermsUrlLink)!, options: [:], completionHandler: nil)
        } else {
            UIApplication.shared.openURL(URL(string:AppConfig.Links.appConfigTermsUrlLink)!)
        }
    }
    
    @IBAction func onPrivacy(_ sender: Any) {
        if #available(iOS 10.0, *) {
            UIApplication.shared.open(URL(string:AppConfig.Links.appConfigPrivacyUrlLink)!, options: [:], completionHandler: nil)
        } else {
            UIApplication.shared.openURL(URL(string:AppConfig.Links.appConfigPrivacyUrlLink)!)
        }
    }
}

extension PremiumUpgradeViewController: PremiumUpgradeSlideViewDelegate {
    func onSlideNext() {
        if currentIdx < sliderData.count {
            slide(next: true, idx: currentIdx + 1)
        }
    }
    
    func onSlidePrev() {
        if self.currentIdx == 0 {
            self.stopSliding()
            return
        }
        if currentIdx > 0 {
            slide(next: false, idx: currentIdx - 1)
        }
    }
    
    func slide(next: Bool, idx : Int) {
        ModacityAnalytics.LogStringEvent("Upgrade - Swiped Value Prop", extraParamName: "Slide", extraParamValue: indexNames[idx])
        
        let slideView = self.nextSlideNormalView(idx: idx)
        
        DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(100)) {
            let orgFrame = slideView.frame
            slideView.frame = CGRect(x: (next ? 1 : -1) * orgFrame.size.width, y: orgFrame.origin.y, width: orgFrame.size.width, height: orgFrame.size.height)
            
            let currentOrgFrame = self.currentSlideContentView.frame
            
            UIView.animate(withDuration: 0.5, animations: {
                slideView.frame = orgFrame
                slideView.alpha = 1
                self.currentSlideContentView.alpha = 0
                self.currentSlideContentView.frame = CGRect(x:(next ? -1 : 1) * currentOrgFrame.size.width, y: currentOrgFrame.origin.y, width: currentOrgFrame.size.width, height: currentOrgFrame.size.height)
            }) { (finished) in
                if finished {
                    self.currentSlideContentView.removeFromSuperview()
                    self.currentSlideContentView = slideView
                    self.currentIdx = idx
                    self.pageControlSlider.currentPage = idx
                }
            }
        }
    }
    
    func nextSlideNormalView(idx: Int) -> UIView {
        if idx == 4 {
            let slideView = PremiumUpgradeSlideComingSoonView()
            slideView.alpha = 0
            slideView.delegate = self
            self.viewSlidingContentContainer.addSubview(slideView)
            self.viewSlidingContentContainer.topAnchor.constraint(equalTo: slideView.topAnchor).isActive = true
            self.viewSlidingContentContainer.leadingAnchor.constraint(equalTo: slideView.leadingAnchor).isActive = true
            self.viewSlidingContentContainer.trailingAnchor.constraint(equalTo: slideView.trailingAnchor).isActive = true
            self.viewSlidingContentContainer.bottomAnchor.constraint(equalTo: slideView.bottomAnchor).isActive = true
            return slideView
        } else {
            let slideView = PremiumUpgradeSlideView()
            slideView.alpha = 0
            slideView.delegate = self
            self.viewSlidingContentContainer.addSubview(slideView)
            self.viewSlidingContentContainer.topAnchor.constraint(equalTo: slideView.topAnchor).isActive = true
            self.viewSlidingContentContainer.leadingAnchor.constraint(equalTo: slideView.leadingAnchor).isActive = true
            self.viewSlidingContentContainer.trailingAnchor.constraint(equalTo: slideView.trailingAnchor).isActive = true
            self.viewSlidingContentContainer.bottomAnchor.constraint(equalTo: slideView.bottomAnchor).isActive = true
            
            slideView.imageViewImage.image = UIImage(named: self.sliderData[idx]["image"]!)
            slideView.labelTitlePart1.text = self.sliderData[idx]["title1"]!
            slideView.labelTitlePart2.text = self.sliderData[idx]["title2"]!
            slideView.labelDescription.text = self.sliderData[idx]["desc"]
            return slideView
        }
    }
}

extension PremiumUpgradeViewController {
    @IBAction func onSlideTermsPanel(_ sender: Any) {
        if !self.termsPanelSlided {
            self.constraintForSubscriptionTermsPanelTopSpace.constant = self.heightOfTermsPanel
        } else {
            self.constraintForSubscriptionTermsPanelTopSpace.constant = 70
        }
        UIView.animate(withDuration: 0.5) {
            self.view.layoutIfNeeded()
        }
        self.termsPanelSlided = !self.termsPanelSlided
    }
}
