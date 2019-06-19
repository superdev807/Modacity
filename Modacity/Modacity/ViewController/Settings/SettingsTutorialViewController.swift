//
//  SettingsTutorialViewController.swift
//  Modacity
//
//  Created by Benjamin Chris on 2/22/18.
//  Copyright © 2018 Modacity, Inc. All rights reserved.
//

import UIKit

class SettingsTutorialViewController: ModacityParentViewController {
    
    @IBOutlet weak var horizontalTableViewTutorial: UITableView!
    @IBOutlet weak var constraintForStartButtonBottomSpace: NSLayoutConstraint!
    @IBOutlet weak var constraintForContentViewLeading: NSLayoutConstraint!
    @IBOutlet weak var constraintForContentViewTrailing: NSLayoutConstraint!
    @IBOutlet weak var pageControl: UIPageControl!
    
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
                      "desc":"Record yourself for instant feedback.\nSave notes on items and lists.\nUse our unique “Improve” button."],
                     ["image":"img_carousel_4",
                      "title1":"TRACK",
                      "title2":"YOUR PROGRESS",
                      "desc":"Know exactly how much time you’ve spent, what improvements you’ve made, and even your level of mastery."]]
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        self.configureTableViewToPageViewLooking()
        self.relayoutForDeviceSizes()
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
    }
    
    @IBAction func onBack(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    
    func configureTableViewToPageViewLooking() {
        self.horizontalTableViewTutorial.transform = CGAffineTransform(rotationAngle:(CGFloat(-1 * Double.pi / 2)))
        self.horizontalTableViewTutorial.isPagingEnabled = true
        self.horizontalTableViewTutorial.showsVerticalScrollIndicator = false
    }
    
    func relayoutForDeviceSizes() {
        switch AppUtils.sizeModelOfiPhone() {
        case .iphone4_35in:
            self.constraintForContentViewLeading.constant = 30
            self.constraintForContentViewTrailing.constant = 30
        default:
            self.constraintForContentViewLeading.constant = 0
            self.constraintForContentViewTrailing.constant = 0
        }
    }
    
    @IBAction func onValueChangedOnPageControl(_ sender: Any) {
        self.horizontalTableViewTutorial.setContentOffset(CGPoint(x: 0, y: horizontalTableViewTutorial.frame.size.width * CGFloat(self.pageControl.currentPage)), animated: true)
    }
    
    @objc func scrollViewRestore() {
        self.horizontalTableViewTutorial.delegate = self
    }
    
    @IBAction func onVideoLink(_ sender: Any) {
        let controller = UIStoryboard(name: "video", bundle: nil).instantiateViewController(withIdentifier: "YoutubeViewController") as! YoutubeViewController
        controller.titleString = "How to Use Modacity"
        controller.videoId = AppConfig.YoutubeVideoIds.appHowToVideoYoutubeId
        self.navigationController?.pushViewController(controller, animated: true)
    }
    
    
}

extension SettingsTutorialViewController: UITableViewDelegate, UITableViewDataSource {
    
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
