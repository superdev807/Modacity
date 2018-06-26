//
//  DetailsViewController.swift
//  Modacity
//
//  Created by BC Engineer on 21/6/18.
//  Copyright © 2018 crossover. All rights reserved.
//

import UIKit

class DetailsViewController: UIViewController {

    @IBOutlet weak var viewIndicatorTab1: UIView!
    @IBOutlet weak var viewIndicatorTab2: UIView!
    @IBOutlet weak var viewIndicatorTab3: UIView!
    @IBOutlet weak var viewIndicatorTab4: UIView!
    @IBOutlet weak var imageViewHeader: UIImageView!
    
    var selectedTabIdx = -1
    
    var statisticsView:StatisticsView! = nil
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        selectTab(0)
        self.attachStatisticsView()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @IBAction func onBack(_ sender: Any) {
        self.navigationController?.dismiss(animated: true, completion: nil)
    }
}

extension DetailsViewController {
    func attachStatisticsView() {
        self.statisticsView = StatisticsView()
        self.view.addSubview(self.statisticsView)
        self.statisticsView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor).isActive = true
        self.statisticsView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor).isActive = true
        self.statisticsView.bottomAnchor.constraint(equalTo: self.view.bottomAnchor).isActive = true
        self.statisticsView.topAnchor.constraint(equalTo: self.imageViewHeader.bottomAnchor).isActive = true
        self.view.bringSubview(toFront: self.statisticsView)
    }
}

extension DetailsViewController {
    
    @IBAction func onTab1(_ sender: Any) {
        selectTab(0)
    }
    
    @IBAction func onTab2(_ sender: Any) {
        selectTab(1)
    }
    
    @IBAction func onTab3(_ sender: Any) {
        selectTab(2)
    }
    
    @IBAction func onTab4(_ sender: Any) {
        selectTab(3)
    }
    
    func selectTab(_ idx: Int) {
        if idx == self.selectedTabIdx {
            return
        }
        self.viewIndicatorTab1.isHidden = true
        self.viewIndicatorTab2.isHidden = true
        self.viewIndicatorTab3.isHidden = true
        self.viewIndicatorTab4.isHidden = true
        self.selectedTabIdx = idx
        switch idx {
        case 0:
            self.viewIndicatorTab1.isHidden = false
        case 1:
            self.viewIndicatorTab2.isHidden = false
        case 2:
            self.viewIndicatorTab3.isHidden = false
        case 3:
            self.viewIndicatorTab4.isHidden = false
        default:
            return
        }
    }
    
}
