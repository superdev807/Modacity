//
//  SortOptionsViewController.swift
//  Modacity
//
//  Created by Benjamin Chris on 10/8/18.
//  Copyright © 2018 Modacity, Inc. All rights reserved.
//

import UIKit

enum SortKeyOption: String {
    case name = "name"
    case lastPracticedTime = "last_practiced_time"
    case rating = "rating"
    case favorites = "favorites"
    case random = "random"
    case manual = "manual"
}

enum SortOption: String {
    case ascending = "ascending"
    case descending = "descending"
}

struct SortKeyData {
    let key: SortKeyOption = .name
    let ascendingText: String = "Ascending"
    let descendingText: String = "Descending"
}

protocol SortOptionsViewControllerDelegate {
    func changeOptions(key: SortKeyOption, option: SortOption)
}

class SortOptionsViewController: ModacityParentViewController {
    
    @IBOutlet weak var constraintSortListHeight: NSLayoutConstraint!
    @IBOutlet weak var constraintSortOptionsBoxHeight: NSLayoutConstraint!
    
    @IBOutlet weak var imageViewCheckDescending: UIImageView!
    @IBOutlet weak var imageViewCheckAscending: UIImageView!
    
    @IBOutlet weak var labelOption1: UILabel!
    @IBOutlet weak var labelOption2: UILabel!
    @IBOutlet weak var buttonOption1: UIButton!
    @IBOutlet weak var buttonOption2: UIButton!
    
    @IBOutlet weak var tableViewSortOptions: UITableView!
    
    var sortKey = SortKeyOption.name
    var sortOption = SortOption.ascending
    var delegate: SortOptionsViewControllerDelegate?
    
    var sortKeys:[SortKeyOption] = [.name, .lastPracticedTime, .rating, .favorites]
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
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
        self.constraintSortListHeight.constant = 64 * self.sortKeys.count
        self.tableViewSortOptions.reloadData()
        self.deselectAllOptions()
        
        if self.sortKey == .random {
            self.imageViewCheckAscending.alpha = 0.5
            self.imageViewCheckDescending.alpha = 0.5
            self.labelOption1.alpha = 0.5
            self.labelOption2.alpha = 0.5
            self.buttonOption1.isEnabled = false
            self.buttonOption2.isEnabled = false
        } else {
            self.imageViewCheckAscending.alpha = 1
            self.imageViewCheckDescending.alpha = 1
            self.labelOption1.alpha = 1
            self.labelOption2.alpha = 1
            self.buttonOption1.isEnabled = true
            self.buttonOption2.isEnabled = true
        }
        
        switch self.sortKey {
        case .name:
            self.labelOption1.text = "A-Z"
            self.labelOption2.text = "Z-A"
            self.constraintSortOptionsBoxHeight.constant = 46
            switch sortOption {
            case .descending:
                self.imageViewCheckAscending.isHidden = false
            case .ascending:
                self.imageViewCheckDescending.isHidden = false
            }
        case .favorites:
            self.labelOption1.text = "Favorite"
            self.labelOption2.text = "Not Favorite"
            self.constraintSortOptionsBoxHeight.constant = 46
            switch sortOption {
            case .ascending:
                self.imageViewCheckAscending.isHidden = false
            case .descending:
                self.imageViewCheckDescending.isHidden = false
            }
        case .lastPracticedTime:
            self.labelOption1.text = "Most Recent"
            self.labelOption2.text = "Least Recent"
            self.constraintSortOptionsBoxHeight.constant = 46
            switch sortOption {
            case .ascending:
                self.imageViewCheckAscending.isHidden = false
            case .descending:
                self.imageViewCheckDescending.isHidden = false
            }
        case .rating:
            self.labelOption1.text = "High to Low"
            self.labelOption2.text = "Low to High"
            self.constraintSortOptionsBoxHeight.constant = 46
            switch sortOption {
            case .ascending:
                self.imageViewCheckAscending.isHidden = false
            case .descending:
                self.imageViewCheckDescending.isHidden = false
            }
        case .manual:
            self.labelOption1.text = "Most Recent"
            self.labelOption2.text = "Least Recent"
            self.constraintSortOptionsBoxHeight.constant = 0
            switch sortOption {
            case .ascending:
                self.imageViewCheckAscending.isHidden = false
            case .descending:
                self.imageViewCheckDescending.isHidden = false
            }
        case .random:
            self.constraintSortOptionsBoxHeight.constant = 0
            return
        }
    }
    
    func deselectAllOptions() {
        self.imageViewCheckAscending.isHidden = true
        self.imageViewCheckDescending.isHidden = true
    }
}

extension SortOptionsViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.sortKeys.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "SortOptionCell") as! SortOptionCell
        cell.configure(self.sortKeys[indexPath.row], isChecked: self.isChecked(self.sortKeys[indexPath.row]))
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 64
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.tableViewSortOptions.deselectRow(at: indexPath, animated: true)
        self.sortKey = self.sortKeys[indexPath.row]
        if self.sortKey == .lastPracticedTime || self.sortKey == .rating || self.sortKey == .name {
            self.sortOption = .ascending
        } else {
            self.sortOption = .descending
        }
        self.callDelegate()
        self.configureOptions()
        self.close()
    }
    
    private func isChecked(_ sortKey: SortKeyOption) -> Bool {
        return sortKey == self.sortKey
    }
}

class SortOptionCell: UITableViewCell {
    
    @IBOutlet weak var imageViewChecked: UIImageView!
    @IBOutlet weak var imageViewIcon: UIImageView!
    @IBOutlet weak var labelSortOption: UILabel!
    
    func configure(_ sortOption: SortKeyOption, isChecked: Bool) {
        self.imageViewChecked.isHidden = !isChecked
        switch sortOption {
        case .name:
            self.labelSortOption.text = "Sort by Name"
            self.imageViewIcon.image = UIImage(named: "icon_sort_name")
        case .favorites:
            self.labelSortOption.text = "Favorites"
            self.imageViewIcon.image = UIImage(named: "icon_sort_heart")
        case .lastPracticedTime:
            self.labelSortOption.text = "Sort by Last Practiced"
            self.imageViewIcon.image = UIImage(named: "icon_sort_last_practiced")
        case .rating:
            self.labelSortOption.text = "Sort by Rating"
            self.imageViewIcon.image = UIImage(named: "icon_sort_rating")
        case .random:
            self.labelSortOption.text = "Shuffle"
            self.imageViewIcon.image = UIImage(named: "icon_sort_random")
        case .manual:
            self.labelSortOption.text = "Manual Order"
            self.imageViewIcon.image = UIImage(named: "icon_sort_last_practiced")
        }
    }
    
}
