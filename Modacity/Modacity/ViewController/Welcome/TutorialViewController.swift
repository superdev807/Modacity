//
//  TutorialViewController.swift
//  Modacity
//
//  Created by Benjamin Chris on 2/22/18.
//  Copyright © 2018 Modacity, Inc. All rights reserved.
//

import UIKit
import MBProgressHUD

class TutorialCell: UITableViewCell {
    
    @IBOutlet weak var imageViewImage: UIImageView!
    @IBOutlet weak var labelTitle: UILabel!
    @IBOutlet weak var labelDescription: UILabel!
    @IBOutlet weak var labelTitlePart1: UILabel!
    @IBOutlet weak var labelTitlePart2: UILabel!
    @IBOutlet weak var constraintForImageWidth: NSLayoutConstraint!
    
    @IBOutlet weak var constraintSpace1: NSLayoutConstraint!
    @IBOutlet weak var constraintSpace2: NSLayoutConstraint!
    @IBOutlet weak var constraintForContainerViewCentering: NSLayoutConstraint!
    
    func configure(imageName: String, title1: String, title2: String, desc: String) {
        self.imageViewImage.image = UIImage(named: imageName)
        self.labelTitlePart1.text = title1
        self.labelTitlePart2.text = title2
        self.labelDescription.text = desc
        
        switch AppUtils.sizeModelOfiPhone() {
        case .iphone4_35in:
            self.constraintSpace1.constant = 10
            self.constraintSpace2.constant = 10
            self.constraintForImageWidth.constant = 200
            self.constraintForContainerViewCentering.constant = -10
        case .iphone5_4in:
            self.constraintForImageWidth.constant = 300
            self.constraintSpace1.constant = 15
            self.constraintSpace2.constant = 15
            self.constraintForContainerViewCentering.constant = 20
        case .iphonexR_xSMax:
            self.constraintForImageWidth.constant = 414
            self.constraintSpace1.constant = 30
            self.constraintSpace2.constant = 30
            self.constraintForContainerViewCentering.constant = 10
        default:
            self.constraintForImageWidth.constant = 375
            self.constraintSpace1.constant = 15
            self.constraintSpace2.constant = 15
            self.constraintForContainerViewCentering.constant = 0
        }
    }
    
}

class TutorialViewController: ModacityParentViewController {
    
    @IBOutlet weak var horizontalTableViewTutorial: UITableView!
    @IBOutlet weak var constraintForStartButtonBottomSpace: NSLayoutConstraint!
    @IBOutlet weak var constraintForContentViewLeading: NSLayoutConstraint!
    @IBOutlet weak var constraintForContentViewTrailing: NSLayoutConstraint!
    @IBOutlet weak var pageControl: UIPageControl!
    @IBOutlet weak var labelVersionChecking: UILabel!
    
    @IBOutlet weak var constraintForBottomBarHeight: NSLayoutConstraint!
    
    let tutorials = [["image":"img_carousel_1",
                      "title1":"WELCOME",
                      "title2":"TO MODACITY",
                      "desc":"Modacity combines all the tools you need into one easy-to-use music practice app."],
                     ["image":"img_carousel_2",
                      "title1":"ORGANIZE",
                      "title2":"YOUR PRACTICE",
                      "desc":"Add the pieces you’re working on and create practice lists - saving you time and increasing retention."],
                     ["image":"img_carousel_3",
                      "title1":"PRACTICE",
                      "title2":"WELL",
                      "desc":"Record yourself for instant feedback.\nSave notes on items and sessions.\nUse our unique “Improve” button."],
                     ["image":"img_carousel_4",
                      "title1":"TRACK",
                      "title2":"YOUR PROGRESS",
                      "desc":"Know exactly how much time you’ve spent, what improvements you’ve made, and even your level of mastery."]]
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        self.configureTableViewToPageViewLooking()
        self.relayoutForDeviceSizes()
        
        switch AppConfig.appVersion {
        case .dev:
            self.labelVersionChecking.text = "(Dev Version)"
        case .staging:
            self.labelVersionChecking.text = "(Staging Version)"
        case .live:
            self.labelVersionChecking.text = ""
        }
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "sid_get_started" {
            AppOveralDataManager.manager.didReadTutorial()
        }
    }
    
    @IBAction func onSkip(_ sender: Any) {
        AppOveralDataManager.manager.didReadTutorial()
        ModacityAnalytics.LogStringEvent("Welcome - Pressed 'SKIP'")
        self.openNext()
    }
    
    @IBAction func onNext(_ sender: Any) {
        AppOveralDataManager.manager.didReadTutorial()
        ModacityAnalytics.LogStringEvent("Welcome - Pressed 'NEXT'")
        if let visibleRows = self.horizontalTableViewTutorial.indexPathsForVisibleRows {
            let currentPageNum = visibleRows[0].row
            if currentPageNum < 3 {
                self.horizontalTableViewTutorial.setContentOffset(CGPoint(x: 0, y: horizontalTableViewTutorial.frame.size.width * CGFloat(currentPageNum + 1)), animated: true)
                self.pageControl.currentPage = currentPageNum + 1
            } else {
                self.openNext()
//                self.performSegue(withIdentifier: "sid_get_started", sender: nil)
            }
        }
    }
    
    func configureTableViewToPageViewLooking() {
        self.horizontalTableViewTutorial.transform = CGAffineTransform(rotationAngle:(CGFloat(-Double.pi / 2)))
        self.horizontalTableViewTutorial.isPagingEnabled = true
        self.horizontalTableViewTutorial.showsVerticalScrollIndicator = false
    }
    
    func relayoutForDeviceSizes() {
        switch AppUtils.sizeModelOfiPhone() {
        case .iphone4_35in:
            self.constraintForContentViewLeading.constant = 30
            self.constraintForContentViewTrailing.constant = 30
            self.constraintForBottomBarHeight.constant = 44
        case .iphone5_4in:
            self.constraintForBottomBarHeight.constant = 44
        default:
            self.constraintForContentViewLeading.constant = 0
            self.constraintForContentViewTrailing.constant = 0
            self.constraintForBottomBarHeight.constant = 74
        }
    }
    
    @IBAction func onValueChangedOnPageControl(_ sender: Any) {
        self.horizontalTableViewTutorial.setContentOffset(CGPoint(x: 0, y: horizontalTableViewTutorial.frame.size.width * CGFloat(self.pageControl.currentPage)), animated: true)
    }
    
    @objc func scrollViewRestore() {
        self.horizontalTableViewTutorial.delegate = self
    }
    
}

extension TutorialViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.tutorials.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return tableView.frame.size.width
    }
    
    func tableView(_ tableView: UITableView!, widthForRowAt indexPath: IndexPath!) -> CGFloat {
        return tableView.frame.size.height
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "TutorialCell") as! TutorialCell
        cell.transform = CGAffineTransform(rotationAngle:(CGFloat(Double.pi / 2)))
        let tutorial = self.tutorials[indexPath.row]
        cell.configure(imageName: tutorial["image"] ?? "", title1: tutorial["title1"] ?? "", title2: tutorial["title2"] ?? "", desc: tutorial["desc"] ?? "")
        return cell
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        cell.transform = CGAffineTransform(rotationAngle:(CGFloat(Double.pi / 2)))
    }
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        if let visibleRows = self.horizontalTableViewTutorial.indexPathsForVisibleRows {
            let pageNum = visibleRows[0].row
            self.pageControl.currentPage = pageNum
        }
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
    }
}

extension TutorialViewController {
    func openNext() {
        self.performSegue(withIdentifier: "sid_startup", sender: nil)
    }
    
    @objc func showHomePage() {
        DispatchQueue.main.async {
            MBProgressHUD.hide(for: self.view, animated: true)
            NotificationCenter.default.removeObserver(self, name: AppConfig.NotificationNames.appNotificationHomePageValuesLoaded, object: nil)
            let controller = UIStoryboard(name: "sidemenu", bundle: nil).instantiateViewController(withIdentifier: "SideMenuController") as! SideMenuController
            self.navigationController?.pushViewController(controller, animated: true)
        }
    }
}
