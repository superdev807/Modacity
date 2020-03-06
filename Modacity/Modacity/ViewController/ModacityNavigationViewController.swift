//
//  ModacityNavigationViewController.swift
//  Modacity
//
//  Created by Benjamin Chris on 16/11/18.
//  Copyright © 2018 Modacity, Inc. All rights reserved.
//

import UIKit

class ModacityNavigationViewController: UINavigationController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    override func present(_ viewControllerToPresent: UIViewController, animated flag: Bool, completion: (() -> Void)? = nil) {
        viewControllerToPresent.modalPresentationStyle = .fullScreen
        super.present(viewControllerToPresent, animated: flag, completion: completion)
    }
}
