//
//  ImproveHypothesisViewController.swift
//  Modacity
//
//  Created by Perfect Engineer on 3/13/18.
//  Copyright © 2018 crossover. All rights reserved.
//

import UIKit

class ImproveHypothesisViewController: UIViewController {
    
    var viewModel: ImprovementViewModel!
    var playlistModel: PlaylistDetailsViewModel!
    var practiceItem: PracticeItem!
    
    @IBOutlet weak var tableViewHypothesis: UITableView!
    @IBOutlet weak var labelPracticeName: UILabel!
    @IBOutlet weak var labelSuggestionName: UILabel!
    @IBOutlet weak var labelHeaderNote: UILabel!
    @IBOutlet weak var textfieldInputBox: UITextField!
    @IBOutlet weak var viewInputBox: UIView!
    @IBOutlet weak var collectionViewMain: UICollectionView!
    @IBOutlet weak var buttonCloseBox: UIButton!
    @IBOutlet weak var buttonTryAgain: UIButton!
    @IBOutlet weak var constraintForTryAgainButtonBottomSpace: NSLayoutConstraint!
    @IBOutlet weak var constraintForTableViewBottomSpace: NSLayoutConstraint!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        self.textfieldInputBox.attributedPlaceholder = NSAttributedString(string: "Type here or choose a suggestion", attributes: [NSAttributedStringKey.foregroundColor:Color.white.alpha(0.5)])
        self.viewInputBox.layer.cornerRadius = 5
        self.buttonCloseBox.isHidden = true
        if self.playlistModel != nil {
            self.labelPracticeName.text = self.playlistModel.currentPracticeEntry.practiceItem()?.name ?? ""
        } else {
            self.labelPracticeName.text = self.practiceItem.name ?? ""
        }
        self.labelSuggestionName.text = self.viewModel.selectedSuggestion
        self.buttonTryAgain.isHidden = true
        self.bindViewModel()
        
        NotificationCenter.default.addObserver(self, selector: #selector(onKeyboardWillShow), name: Notification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(onKeyboardWillChangeFrame), name: Notification.Name.UIKeyboardWillChangeFrame, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(onKeyboardWillHide), name: Notification.Name.UIKeyboardWillHide, object: nil)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "sid_next" || segue.identifier == "sid_next_small_sizes" {
            
            ModacityAnalytics.LogEvent(.HypothesisChosen, extraParamName: "Hypothesis", extraParamValue: self.viewModel.selectedHypothesis)
            
            let controller = segue.destination as! ImprovementViewController
            controller.viewModel = self.viewModel
            if self.playlistModel != nil {
                controller.playlistViewModel = self.playlistModel
            } else {
                controller.practiceItem = self.practiceItem
            }
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if self.viewModel.alreadyTried {
            self.labelHeaderNote.text = "Try your hypothesis again or set a new one."
            self.textfieldInputBox.text = self.viewModel.selectedHypothesis
        }
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }

    @IBAction func onClose(_ sender: Any) {
         ModacityAnalytics.LogStringEvent("Closed Hypothesis Screen")
        self.navigationController?.popViewController(animated: true)
        self.viewModel.alreadyTried = false
    }

    @IBAction func onHideKeyboard(_ sender: Any) {
        self.textfieldInputBox.resignFirstResponder()
    }
    
    @IBAction func onDidEndOnExit(_ sender: Any) {
        self.viewModel.selectedHypothesis = self.textfieldInputBox.text ?? ""
        if AppUtils.sizeModelOfiPhone() == .iphone5_4in || AppUtils.sizeModelOfiPhone() == .iphone4_35in {
            self.performSegue(withIdentifier: "sid_next_small_sizes", sender: nil)
        } else {
            self.performSegue(withIdentifier: "sid_next", sender: nil)
        }
    }
    
    @IBAction func onEditingChanged(_ sender: Any) {
        if "" != self.textfieldInputBox.text {
            self.viewModel.selectedHypothesis = self.textfieldInputBox.text ?? ""
        }
    }
    
    @objc func onKeyboardWillChangeFrame(notification: Notification) {
        if let keyboardSize = (notification.userInfo?[UIKeyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue {
            if AppUtils.iphoneIsXModel() {
                self.constraintForTryAgainButtonBottomSpace.constant = keyboardSize.height - 34 + 20
            } else {
                self.constraintForTryAgainButtonBottomSpace.constant = keyboardSize.height
            }
        }
    }
    
    @objc func onKeyboardWillShow(notification: Notification) {
        if let keyboardSize = (notification.userInfo?[UIKeyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue {
            self.constraintForTableViewBottomSpace.constant = keyboardSize.height
            self.buttonCloseBox.isHidden = false
        }
    }
    
    @objc func onKeyboardWillHide() {
        self.buttonCloseBox.isHidden = true
        self.constraintForTableViewBottomSpace.constant = 0
        self.constraintForTryAgainButtonBottomSpace.constant = 20
    }
    
    @IBAction func onTryAgain(_ sender: Any) {
        if AppUtils.sizeModelOfiPhone() == .iphone4_35in || AppUtils.sizeModelOfiPhone() == .iphone5_4in {
            self.performSegue(withIdentifier: "sid_next_small_sizes", sender: nil)
        } else {
            self.performSegue(withIdentifier: "sid_next", sender: nil)
        }
    }
    
    func bindViewModel() {
        self.viewModel.subscribe(to: "alreadyTried") { (_, _, _) in
            self.buttonTryAgain.isHidden = !self.viewModel.alreadyTried
        }
    }
}

extension ImproveHypothesisViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.viewModel.hypothesisList().count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "HypothesisCell")!
        if let label = cell.viewWithTag(10) as? UILabel {
            label.text = self.viewModel.hypothesisList()[indexPath.row]
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 55
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.viewModel.selectedHypothesis = self.viewModel.hypothesisList()[indexPath.row]
        if AppUtils.sizeModelOfiPhone() == .iphone5_4in || AppUtils.sizeModelOfiPhone() == .iphone4_35in {
            self.performSegue(withIdentifier: "sid_next_small_sizes", sender: nil)
        } else {
            self.performSegue(withIdentifier: "sid_next", sender: nil)
        }
    }
}
