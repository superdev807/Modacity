//
//  TutorialViewController.swift
//  Modacity
//
//  Created by Benjamin Chris on 2/22/18.
//  Copyright © 2018 Modacity, Inc. All rights reserved.
//

import UIKit

class TutorialCell: UITableViewCell {
    
    @IBOutlet weak var imageViewImage: UIImageView!
    @IBOutlet weak var labelTitle: UILabel!
    @IBOutlet weak var labelDescription: UILabel!
    @IBOutlet weak var labelTitlePart1: UILabel!
    @IBOutlet weak var labelTitlePart2: UILabel!
    
    func configure(imageName: String, title1: String, title2: String, desc: String) {
        self.imageViewImage.image = UIImage(named: imageName)
        self.labelTitlePart1.text = title1
        self.labelTitlePart2.text = title2
        self.labelDescription.text = desc
    }
    
}

class TutorialViewController: UIViewController {
    
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
                      "desc":"Add the pieces you’re working on and create practice sessions - saving you time and increasing retention."],
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
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "sid_get_started" {
            AppOveralDataManager.manager.didReadTutorial()
            ModacityAnalytics.LogStringEvent("Welcome - Pressed 'Get Started'")
        }
    }
    
    @IBAction func onNext(_ sender: Any) {
        if let visibleRows = self.horizontalTableViewTutorial.indexPathsForVisibleRows {
            let currentPageNum = visibleRows[0].row
            if currentPageNum < 3 {
                self.horizontalTableViewTutorial.setContentOffset(CGPoint(x: UIScreen.main.bounds.size.width * CGFloat(currentPageNum + 1), y: 0), animated: true)
            }
        }
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
//            self.constraintForStartButtonBottomSpace.constant = 10
        default:
            self.constraintForContentViewLeading.constant = 0
            self.constraintForContentViewTrailing.constant = 0
//            self.constraintForStartButtonBottomSpace.constant = 30
        }
    }

}

extension TutorialViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.tutorials.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return tableView.frame.size.height
    }
    
    func tableView(_ tableView: UITableView!, widthForRowAt indexPath: IndexPath!) -> CGFloat {
        return tableView.frame.size.width
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
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if let visibleRows = self.horizontalTableViewTutorial.indexPathsForVisibleRows {
            let pageNum = visibleRows[0].row
            self.pageControl.currentPage = pageNum
            ModacityAnalytics.LogStringEvent("Welcome Screen - Scrolled to Page \(pageNum)")
        }
    }
}
