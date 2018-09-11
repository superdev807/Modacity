//
//  SortOptionsViewController.swift
//  Modacity
//
//  Created by Benjamin Chris on 10/8/18.
//  Copyright © 2018 Modacity, Inc. All rights reserved.
//

import UIKit

enum SortKeyOption: String {
    case name = "name";
    case lastPracticedTime = "last_practiced_time";
    case rating = "rating";
    case favorites = "favorites";
}

enum SortOption: String {
    case ascending = "ascending";
    case descending = "descending";
}

protocol SortOptionsViewControllerDelegate {
    func changeOptions(key: SortKeyOption, option: SortOption)
}

class SortOptionsViewController: UIViewController {
    
    @IBOutlet weak var imageViewCheckDescending: UIImageView!
    @IBOutlet weak var imageViewCheckAscending: UIImageView!
    
    @IBOutlet weak var imageViewCheckByName: UIImageView!
    @IBOutlet weak var imageViewCheckByLastPracticeTime: UIImageView!
    @IBOutlet weak var imageViewCheckByRating: UIImageView!
    @IBOutlet weak var imageViewCheckByFavorites: UIImageView!
    
    @IBOutlet weak var labelOption1: UILabel!
    @IBOutlet weak var labelOption2: UILabel!
    
    var sortKey = SortKeyOption.name
    var sortOption = SortOption.ascending
    var delegate: SortOptionsViewControllerDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        self.view.backgroundColor = Color.black.alpha(0.2)
        self.configureOptions()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func onBack(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    func callDelegate() {
        if let delegate = self.delegate {
            delegate.changeOptions(key: self.sortKey, option: self.sortOption)
        }
    }
    
    func close() {
//        DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(500)) {
//            self.dismiss(animated: true, completion: nil)
//        }
    }
    
    @IBAction func onSelectOptionName(_ sender: Any) {
        self.sortKey = .name
        self.callDelegate()
        self.configureOptions()
        self.close()
    }
    
    @IBAction func onSelectOptionLastPracticed(_ sender: Any) {
        self.sortKey = .lastPracticedTime
        self.callDelegate()
        self.configureOptions()
        self.close()
    }
    
    @IBAction func onSelectOptionRating(_ sender: Any) {
        self.sortKey = .rating
        self.callDelegate()
        self.configureOptions()
        self.close()
    }
    
    @IBAction func onSelectOptionFavorites(_ sender: Any) {
        self.sortKey = .favorites
        self.callDelegate()
        self.configureOptions()
        self.close()
    }
    
    @IBAction func onSelectOptionDescending(_ sender: Any) {
        if self.sortKey == .name {
            self.sortOption = .ascending
        } else {
            self.sortOption = .descending
        }
        self.callDelegate()
        self.configureOptions()
        self.close()
    }
    
    @IBAction func onSelectOptionAscending(_ sender: Any) {
        if self.sortKey == .name {
            self.sortOption = .descending
        } else {
            self.sortOption = .ascending
        }
        self.callDelegate()
        self.configureOptions()
        self.close()
    }
    
    func configureOptions() {
        self.deselectAllKeys()
        self.deselectAllOptions()
        
        switch sortKey {
        case .name:
            self.imageViewCheckByName.isHidden = false
            self.labelOption1.text = "A-Z"
            self.labelOption2.text = "Z-A"
            switch sortOption {
            case .descending:
                self.imageViewCheckAscending.isHidden = false
            case .ascending:
                self.imageViewCheckDescending.isHidden = false
            }
        case .favorites:
            self.imageViewCheckByFavorites.isHidden = false
            self.labelOption1.text = "Favorite"
            self.labelOption2.text = "Not Favorite"
            switch sortOption {
            case .ascending:
                self.imageViewCheckAscending.isHidden = false
            case .descending:
                self.imageViewCheckDescending.isHidden = false
            }
        case .lastPracticedTime:
            self.imageViewCheckByLastPracticeTime.isHidden = false
            self.labelOption1.text = "Most Recent"
            self.labelOption2.text = "Least Recent"
            switch sortOption {
            case .ascending:
                self.imageViewCheckAscending.isHidden = false
            case .descending:
                self.imageViewCheckDescending.isHidden = false
            }
        case .rating:
            self.imageViewCheckByRating.isHidden = false
            self.labelOption1.text = "High to Low"
            self.labelOption2.text = "Low to High"
            switch sortOption {
            case .ascending:
                self.imageViewCheckAscending.isHidden = false
            case .descending:
                self.imageViewCheckDescending.isHidden = false
            }
        }
        
        
    }
    
    func deselectAllKeys() {
        self.imageViewCheckByName.isHidden = true
        self.imageViewCheckByRating.isHidden = true
        self.imageViewCheckByLastPracticeTime.isHidden = true
        self.imageViewCheckByFavorites.isHidden = true
    }
    
    func deselectAllOptions() {
        self.imageViewCheckAscending.isHidden = true
        self.imageViewCheckDescending.isHidden = true
    }
}
