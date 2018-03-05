//
//  MetrodoneViewController.swift
//  Modacity
//
//  Created by Perfect Engineer on 2/24/18.
//  Copyright © 2018 crossover. All rights reserved.
//

import UIKit

class MetrodoneViewController: UIViewController {

    @IBOutlet weak var constraintForSubdivisionButtonWidth: NSLayoutConstraint!
    @IBOutlet weak var constraintForDroneViewLeading: NSLayoutConstraint!
    @IBOutlet weak var constraintForDroneViewTrailing: NSLayoutConstraint!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        self.configureLayout()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func onMenu(_ sender: Any) {
        self.sideMenuController?.showLeftViewAnimated()
    }
    
    func configureLayout() {
        if AppUtils.sizeModelOfiPhone() == .iphone5_4in {
            self.constraintForSubdivisionButtonWidth.constant = 90
        } else {
            self.constraintForSubdivisionButtonWidth.constant = 112
        }
        
        if AppUtils.sizeModelOfiPhone() == .iphone4_35in {
            self.constraintForDroneViewLeading.constant = 60
            self.constraintForDroneViewTrailing.constant = 60
        } else {
            self.constraintForDroneViewLeading.constant = 20
            self.constraintForDroneViewTrailing.constant = 20
        }
    }

}
