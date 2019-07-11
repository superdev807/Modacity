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
    
    var viewPracticeBreakPrompt: PracticeBreakPromptView! = nil
    
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
        
        self.bindViewModel()
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.configurePracticeBreakTimeNotifications()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.removePracticeBreakTimeNotification()
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
    
    func bindViewModel() {
        self.viewModel.loadSuggestions()
        self.collectionViewMain.reloadData()
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
            if let sugg = DeliberatePracticeManager.manager.isExistingSuggestion(suggestion) {
                self.viewModel.selectedSuggestionData = sugg
            } else {
                self.viewModel.selectedSuggestion = suggestion
            }
            self.performSegue(withIdentifier: "sid_next", sender: nil)
        }
    }
    
    @IBAction func onEditingChangedOnField(_ sender: Any) {
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
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "SuggestCell", for: indexPath) as! SuggestCell
        let suggestion = self.viewModel.suggestionsList[indexPath.row]
        cell.configure(withText: suggestion.suggestion, indexPath: indexPath, isDefault: self.viewModel.suggestionIsDefault(suggestion))
        cell.delegate = self
        return cell
    }
}

protocol SuggestCellDelegate {
    func menuTapOn(cell: SuggestCell, on indexPath: IndexPath)
}

class SuggestCell: UICollectionViewCell {
    
    @IBOutlet weak var labelCaption: UILabel!
    @IBOutlet weak var buttonMenu: UIButton!
    
    var indexPath: IndexPath!
    var delegate: SuggestCellDelegate?
    
    @IBAction func onCellMenu(_ sender: Any) {
        if let delegate = self.delegate {
            delegate.menuTapOn(cell: self, on: self.indexPath)
        }
    }
    
    func configure(withText: String, indexPath: IndexPath, isDefault: Bool) {
        self.labelCaption.text = withText
        self.indexPath = indexPath
        
        self.buttonMenu.isHidden = isDefault
    }
    
}

extension ImproveSuggestionViewController: SuggestCellDelegate {
    
    func menuTapOn(cell: SuggestCell, on indexPath: IndexPath) {
        
        DropdownMenuView.instance.show(in: self.view,
                                       on: cell.buttonMenu,
                                       rows: [["icon":"icon_row_delete", "text":"Delete"]]) { (_) in
                                        
                                        let suggestion = self.viewModel.suggestionsList[indexPath.row]
                                        let alert = UIAlertController(title: nil, message: "Are you sure to delete this suggestion?", preferredStyle: .alert)
                                        alert.addAction(UIAlertAction(title: "Confirm", style: .default, handler: { (_) in
                                            self.viewModel.deleteSuggestion(suggestion, at: indexPath.row)
                                            self.bindViewModel()
                                        }))
                                        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
                                        self.present(alert, animated: true, completion: nil)

        }
    }
}

extension ImproveSuggestionViewController: PracticeBreakPromptViewDelegate {
    
    func configurePracticeBreakTimeNotifications() {
        NotificationCenter.default.addObserver(self, selector: #selector(needToShowPracticeBreakTimePrompt), name: .needToPromptPracticeBreakTime, object: nil)
    }
    
    func removePracticeBreakTimeNotification() {
        NotificationCenter.default.removeObserver(self, name: .needToPromptPracticeBreakTime, object: nil)
    }
    
    func dismiss(practiceBreakPromptView: PracticeBreakPromptView) {
        if self.viewPracticeBreakPrompt != nil {
            self.viewPracticeBreakPrompt.removeFromSuperview()
            self.viewPracticeBreakPrompt = nil
            NotificationCenter.default.post(name: .practiceBreakTimePromptDismissed, object: nil)
        }
    }
    
    @objc func needToShowPracticeBreakTimePrompt(notification: Notification) {
        if let userInfo = notification.userInfo {
            if let time = userInfo["time"] as? Int {
                self.showPracticeBreakPrompt(with: time)
            }
        }
    }
    
    func showPracticeBreakPrompt(with time: Int) {
        if self.viewPracticeBreakPrompt != nil {
            self.viewPracticeBreakPrompt.removeFromSuperview()
        }
        self.viewPracticeBreakPrompt = PracticeBreakPromptView()
        self.viewPracticeBreakPrompt.delegate = self
        self.view.addSubview(self.viewPracticeBreakPrompt)
        self.view.topAnchor.constraint(equalTo: self.viewPracticeBreakPrompt.topAnchor).isActive = true
        self.view.leadingAnchor.constraint(equalTo: self.viewPracticeBreakPrompt.leadingAnchor).isActive = true
        self.view.trailingAnchor.constraint(equalTo: self.viewPracticeBreakPrompt.trailingAnchor).isActive = true
        if #available(iOS 11.0, *) {
            self.view.safeAreaLayoutGuide.bottomAnchor.constraint(equalTo: self.viewPracticeBreakPrompt.bottomAnchor).isActive = true
        } else {
            self.view.bottomAnchor.constraint(equalTo: self.viewPracticeBreakPrompt.bottomAnchor).isActive = true
        }
        self.view.bringSubview(toFront: self.viewPracticeBreakPrompt)
        self.viewPracticeBreakPrompt.showPracticeTime(time)
        self.viewPracticeBreakPrompt.startCountUpTimer()
    }
}
