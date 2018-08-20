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
    
    func configure(imageName: String, title: String, desc: String) {
        self.imageViewImage.image = UIImage(named: imageName)
        self.labelTitle.text = title
        self.labelDescription.text = desc
    }
    
}

class TutorialViewController: UIViewController {
    
    @IBOutlet weak var horizontalTableViewTutorial: UITableView!
    @IBOutlet weak var constraintForStartButtonBottomSpace: NSLayoutConstraint!
    @IBOutlet weak var constraintForContentViewLeading: NSLayoutConstraint!
    @IBOutlet weak var constraintForContentViewTrailing: NSLayoutConstraint!
    @IBOutlet weak var pageControl: UIPageControl!
    
    let tutorials = [["image":"img_tutorial_1",
                      "title":"Practice Better",
                      "desc":"Record your practice sessions, track your time spent, and use Modacity's scientific improvement process to achieve positive results, faster."],
                     ["image":"img_tutorial_2",
                      "title":"Learn Faster",
                      "desc":"Organize, focus, and reflect on your practice - saving you time and increasing retention. We help you stay motivated & positive so your brain learns better."],
                     ["image":"img_tutorial_3",
                      "title":"Expert Assistance",
                      "desc":"Get human help from Modacity’s team of music learning experts. Our expert help will propel you past any obstacles with feedback tailored just for you."],
                     ["image":"img_tutorial_4",
                      "title":"Get Results",
                      "desc":"Track your improvements, time spent, and mastery for everything you practice. Compare recordings from different dates and you’ll be amazed with your results."]]
    
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
            self.constraintForStartButtonBottomSpace.constant = 10
        default:
            self.constraintForContentViewLeading.constant = 0
            self.constraintForContentViewTrailing.constant = 0
            self.constraintForStartButtonBottomSpace.constant = 30
        }
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
        return tableView.frame.size.width
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "TutorialCell") as! TutorialCell
        cell.transform = CGAffineTransform(rotationAngle:(CGFloat(Double.pi / 2)))
        let tutorial = self.tutorials[indexPath.row]
        cell.configure(imageName: tutorial["image"] ?? "", title: tutorial["title"] ?? "", desc: tutorial["desc"] ?? "")
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
