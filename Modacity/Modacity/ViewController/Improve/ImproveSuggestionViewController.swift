//
//  ImproveSuggestionViewController.swift
//  Modacity
//
//  Created by Benjamin Chris on 3/13/18.
//  Copyright © 2018 Modacity, Inc. All rights reserved.
//

import UIKit

class ImproveSuggestionViewController: ModacityParentViewController {
    
    var viewModel = ImprovementViewModel()

    var playlistModel: PlaylistContentsViewModel!
    var practiceItem: PracticeItem!
    var deliverModel: PlaylistAndPracticeDeliverModel!
    
    @IBOutlet weak var labelPracticeName: UILabel!
    @IBOutlet weak var textfieldInputBox: UITextField!
    @IBOutlet weak var viewInputBox: UIView!
    @IBOutlet weak var collectionViewMain: UICollectionView!
    @IBOutlet weak var buttonCloseBox: UIButton!
    @IBOutlet weak var constraintForCollectionViewBottomSpace: NSLayoutConstraint!
    @IBOutlet weak var labelHeaderTitle: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        self.textfieldInputBox.attributedPlaceholder = NSAttributedString(string: "Create your own area of improvement", attributes: [NSAttributedStringKey.foregroundColor:Color.white.alpha(0.5)])
        self.viewInputBox.layer.cornerRadius = 5
        self.buttonCloseBox.isHidden = true
        
        if self.playlistModel != nil {
            self.labelPracticeName.text = self.playlistModel.currentPracticeEntry.practiceItem()?.name ?? ""
        } else {
            self.labelPracticeName.text = self.practiceItem.name ?? ""
        }
        
        self.collectionViewLayoutConfigure()
        
        NotificationCenter.default.addObserver(self, selector: #selector(onKeyboardWillShow), name: Notification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(onKeyboardWillHide), name: Notification.Name.UIKeyboardWillHide, object: nil)
        
        // What one thing will you improve now?
        let attributedString = NSMutableAttributedString(string: "What ", attributes: [NSAttributedStringKey.foregroundColor: Color.white, NSAttributedStringKey.font: UIFont(name: AppConfig.UI.Fonts.appFontLatoBold, size: 16)!])
        attributedString.append(NSAttributedString(string: "one ", attributes: [NSAttributedStringKey.foregroundColor: Color.white, NSAttributedStringKey.font: UIFont(name: AppConfig.UI.Fonts.appFontLatoBoldItalic, size: 16)!]))
        attributedString.append(NSAttributedString(string: "thing will you improve now?", attributes: [NSAttributedStringKey.foregroundColor: Color.white, NSAttributedStringKey.font: UIFont(name: AppConfig.UI.Fonts.appFontLatoBold, size: 16)!]))
        self.labelHeaderTitle.attributedText = attributedString
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "sid_next" {
            ModacityAnalytics.LogEvent(.ImprovementChosen, extraParamName: "Improvement", extraParamValue: viewModel.selectedSuggestion)
            
            let controller = segue.destination as! ImproveHypothesisViewController
            controller.viewModel = self.viewModel
            if self.playlistModel != nil {
                controller.playlistModel = self.playlistModel
            } else {
                controller.practiceItem = self.practiceItem
                controller.deliverModel = self.deliverModel
            }
        }
    }

    @IBAction func onClose(_ sender: Any) {
        ModacityAnalytics.LogStringEvent("Closed Improve Screen")
        self.navigationController?.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func onHideKeyboard(_ sender: Any) {
        self.textfieldInputBox.resignFirstResponder()
    }
    
    @IBAction func onDidEndOnExit(_ sender: Any) {
        let suggestion = (self.textfieldInputBox.text ?? "").trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
        if suggestion == "" {
            AppUtils.showSimpleAlertMessage(for: self, title: nil, message: "Please enter a sugestion.")
        } else {
            self.viewModel.selectedSuggestion = suggestion
            self.performSegue(withIdentifier: "sid_next", sender: nil)
        }
    }
    
    @IBAction func onEditingChangedOnField(_ sender: Any) {
        if "" != self.textfieldInputBox.text {
            self.viewModel.selectedSuggestion = self.textfieldInputBox.text ?? ""
        }
    }
    
    @objc func onKeyboardWillShow(notification: Notification) {
        if let keyboardSize = (notification.userInfo?[UIKeyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue {
            self.constraintForCollectionViewBottomSpace.constant = -1 * keyboardSize.height
            self.buttonCloseBox.isHidden = false
        }
    }
    
    @objc func onKeyboardWillHide() {
        self.buttonCloseBox.isHidden = true
        self.constraintForCollectionViewBottomSpace.constant = 0
    }
    
    func collectionViewLayoutConfigure() {
        let flowLayout = self.collectionViewMain.collectionViewLayout as! UICollectionViewFlowLayout
        switch AppUtils.sizeModelOfiPhone() {
        case .iphone4_35in:
            fallthrough
        case .iphone5_4in:
            flowLayout.sectionInset = UIEdgeInsetsMake(30, 10, 20, 10)
        case .iphone6_47in:
            fallthrough
        case .iphone6p_55in:
            fallthrough
        case .iphoneX_xS:
            fallthrough
        case .iphonexR_xSMax:
            flowLayout.sectionInset = UIEdgeInsetsMake(30, 30, 20, 30)
        default:
            return
        }
    }
}

extension ImproveSuggestionViewController: UICollectionViewDelegate, UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.viewModel.suggestionsList.count
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        self.textfieldInputBox.text = ""
        self.viewModel.selectedSuggestionData = self.viewModel.suggestionsList[indexPath.row]
        self.performSegue(withIdentifier: "sid_next", sender: nil)
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "SuggestCell", for: indexPath)
        if let label = cell.viewWithTag(10) as? UILabel {
            label.text = self.viewModel.suggestionsList[indexPath.row].suggestion
        }
        return cell
    }
}
