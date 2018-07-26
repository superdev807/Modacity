//
//  PremiumUpgradeViewController.swift
//  Modacity
//
//  Created by BC Engineer on 19/7/18.
//  Copyright © 2018 crossover. All rights reserved.
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
                       "desc":"Unlock a full journal-style log of your practice acitivty, viewable by practice item, playlist, or overall activity. Includes time spent, improvements made, and star ratings."],
                      ["image": "premium_slider_take_break",
                       "title1":"EFFECTIVE",
                       "title2":"RELAXATION",
                       "desc":"Stay mindful. Avoid getting hurt over-practicing. Set how often you want practice breaks, and Modacity will take care of the rest!"],
                      ["image": "premium_slider_note",
                       "title1":"TAKE",
                       "title2":"UNLIMITED NOTES",
                       "desc":"Unlock full note taking ability with unlimited notes per item. "],
                      ]
    
    @IBOutlet weak var constraintForHeaderViewHeight: NSLayoutConstraint!
    @IBOutlet weak var labelUnlockTitle: UILabel!
    
    @IBOutlet weak var imageViewBackground: UIImageView!
    @IBOutlet weak var viewFirstPanel: UIView!
    @IBOutlet weak var viewSlidingPanel: UIView!
    @IBOutlet weak var viewSlidingContentContainer: UIView!
    @IBOutlet weak var pageControlSlider: UIPageControl!
    @IBOutlet weak var buttonFreeTrialStart: UIButton!
    
    var currentSlideContentView: UIView!
    
    var sliding = false
    
    var currentIdx = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        let attributed = NSMutableAttributedString(string: "UNLOCK YOUR ", attributes: [NSAttributedStringKey.font: UIFont(name: AppConfig.appFontLatoLight, size: 24)!])
        attributed.append(NSAttributedString(string: "FULL POTENTIAL", attributes: [NSAttributedStringKey.font: UIFont(name: AppConfig.appFontLatoBold, size: 24)!]))
        attributed.append(NSAttributedString(string: " WITH MODACITY PREMIUM", attributes: [NSAttributedStringKey.font: UIFont(name: AppConfig.appFontLatoLight, size: 24)!]))
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
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @IBAction func onBack(_ sender: Any) {
        if self.sliding {
            self.stopSliding()
        } else {
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
        self.buttonFreeTrialStart.setTitle("PROCESSING...", for: .normal)
        self.view.isUserInteractionEnabled = false
        NotificationCenter.default.addObserver(self, selector: #selector(onUpgradedSucceeded), name: IAPHelper.appNotificationSubscriptionSucceeded, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(onUpgradeFailed), name: IAPHelper.appNotificationSubscriptionFailed, object: nil)
        PremiumDataManager.manager.upgrade()
    }
    
    @IBAction func onRestorePayment(_ sender: Any) {
        MBProgressHUD.showAdded(to: self.view, animated: true)
        NotificationCenter.default.addObserver(self, selector: #selector(onUpgradedSucceeded), name: IAPHelper.appNotificationSubscriptionSucceeded, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(onUpgradeFailed), name: IAPHelper.appNotificationSubscriptionFailed, object: nil)
        IAPHelper.helper.restore()
    }
    
    @objc func onUpgradedSucceeded(_ notification: Notification) {
        MBProgressHUD.hide(for: self.view, animated: true)
        NotificationCenter.default.removeObserver(self, name: IAPHelper.appNotificationSubscriptionSucceeded, object: nil)
        NotificationCenter.default.removeObserver(self, name: IAPHelper.appNotificationSubscriptionFailed, object: nil)
        
        self.view.isUserInteractionEnabled = true
        
        self.performSegue(withIdentifier: "sid_done", sender: nil)
    }
    
    @objc func onUpgradeFailed(_ notification:Notification) {
        MBProgressHUD.hide(for: self.view, animated: true)
        NotificationCenter.default.removeObserver(self, name: IAPHelper.appNotificationSubscriptionSucceeded, object: nil)
        NotificationCenter.default.removeObserver(self, name: IAPHelper.appNotificationSubscriptionFailed, object: nil)
        
        self.view.isUserInteractionEnabled = true
        self.buttonFreeTrialStart.setTitle("START MY FREE 2-WEEK TRIAL NOW", for: .normal)
        if let userInfo = notification.userInfo,
            let error = userInfo["error"] as? String {
            AppUtils.showSimpleAlertMessage(for: self, title: nil, message: error)
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
