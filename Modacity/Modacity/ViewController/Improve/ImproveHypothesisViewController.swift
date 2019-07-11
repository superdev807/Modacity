//
//  ImproveHypothesisViewController.swift
//  Modacity
//
//  Created by Benjamin Chris on 3/13/18.
//  Copyright © 2018 Modacity, Inc. All rights reserved.
//

import UIKit

class ImproveHypothesisViewController: ModacityParentViewController {
    
    var viewModel: ImprovementViewModel!
    var playlistModel: PlaylistContentsViewModel!
    var practiceItem: PracticeItem!
    var deliverModel: PlaylistAndPracticeDeliverModel!
    
    var viewPracticeBreakPrompt: PracticeBreakPromptView! = nil
    
    @IBOutlet weak var tableViewHypothesis: UITableView!
    @IBOutlet weak var labelPracticeName: UILabel!
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
        self.buttonTryAgain.isHidden = true
        self.bindViewModel()
        
        let attributedString = NSMutableAttributedString(string: "What ", attributes: [NSAttributedStringKey.foregroundColor: Color.white, NSAttributedStringKey.font: UIFont(name: AppConfig.UI.Fonts.appFontLatoBold, size: 16)!])
        attributedString.append(NSAttributedString(string: "strategy ", attributes: [NSAttributedStringKey.foregroundColor: Color.white, NSAttributedStringKey.font: UIFont(name: AppConfig.UI.Fonts.appFontLatoBoldItalic, size: 16)!]))
        attributedString.append(NSAttributedString(string: "will you try\nto make this improvement??", attributes: [NSAttributedStringKey.foregroundColor: Color.white, NSAttributedStringKey.font: UIFont(name: AppConfig.UI.Fonts.appFontLatoBold, size: 16)!]))
        self.labelHeaderNote.attributedText = attributedString
        
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
                controller.deliverModel = self.deliverModel
            }
        }
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if self.viewModel.alreadyTried {
            self.labelHeaderNote.attributedText = NSAttributedString(string: "Try again! or attempt\nsomething different.", attributes: [NSAttributedStringKey.foregroundColor: Color.white, NSAttributedStringKey.font: UIFont(name: AppConfig.UI.Fonts.appFontLatoRegular, size: 16)!])
            self.textfieldInputBox.text = self.viewModel.selectedHypothesis
        }
        
        self.configurePracticeBreakTimeNotifications()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.removePracticeBreakTimeNotification()
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
        
        let hypothesis = (self.textfieldInputBox.text ?? "").trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
        if hypothesis == "" {
            AppUtils.showSimpleAlertMessage(for: self, title: nil, message: "Please enter a hypothesis.")
        } else {
            if let hypo = self.viewModel.hypoethsisExistCheck(hypothesis) {
                self.viewModel.selectedHypothesis = hypo
                self.viewModel.isNewHypo = false
            } else {
                self.viewModel.selectedHypothesis = hypothesis
                self.viewModel.isNewHypo = true
            }
            
            if AppUtils.sizeModelOfiPhone() == .iphone5_4in || AppUtils.sizeModelOfiPhone() == .iphone4_35in {
                self.performSegue(withIdentifier: "sid_next_small_sizes", sender: nil)
            } else {
                self.performSegue(withIdentifier: "sid_next", sender: nil)
            }
        }
    }
    
    @IBAction func onEditingChanged(_ sender: Any) {
//        if "" != self.textfieldInputBox.text {
//            self.viewModel.selectedHypothesis = self.textfieldInputBox.text ?? ""
//        }
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
            
            if self.viewModel.alreadyTried {
                
            }
        }
    }
}

extension ImproveHypothesisViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.viewModel.hypothesisList().count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "HypothesisCell") as! HypothesisCell
        let hypothesis = self.viewModel.hypothesisList()[indexPath.row]
        cell.configure(text: hypothesis, on: indexPath, isDefault: self.viewModel.hypothesisIsDefault(hypothesis))
        cell.delegate = self
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 64
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.viewModel.selectedHypothesis = self.viewModel.hypothesisList()[indexPath.row]
        self.viewModel.isNewHypo = false
        if AppUtils.sizeModelOfiPhone() == .iphone5_4in || AppUtils.sizeModelOfiPhone() == .iphone4_35in {
            self.performSegue(withIdentifier: "sid_next_small_sizes", sender: nil)
        } else {
            self.performSegue(withIdentifier: "sid_next", sender: nil)
        }
    }
}

protocol HypothesisCellDelegate {
    func tapMenuOnCell(_ cell: HypothesisCell, on indexPath:IndexPath)
}

class HypothesisCell: UITableViewCell {
    
    @IBOutlet weak var buttonCellMenu: UIButton!
    @IBOutlet weak var labelCaption: UILabel!
    
    var indexPath: IndexPath!
    var delegate: HypothesisCellDelegate?
    
    @IBAction func onCellMenu(_ sender: Any) {
        if let delegate = self.delegate {
            delegate.tapMenuOnCell(self, on: self.indexPath)
        }
    }
    
    func configure(text: String, on indexPath: IndexPath, isDefault: Bool) {
        self.indexPath = indexPath
        self.labelCaption.text = text
        
        self.buttonCellMenu.isHidden = isDefault
    }
    
}

extension ImproveHypothesisViewController: HypothesisCellDelegate {
    
    func tapMenuOnCell(_ cell: HypothesisCell, on indexPath: IndexPath) {
        DropdownMenuView.instance.show(in: self.view,
                                       on: cell.buttonCellMenu,
                                       rows: [["icon":"icon_row_delete", "text":"Delete"]]) { (_) in
                                        
                                        let alert = UIAlertController(title: nil, message: "Are you sure to delete this hypothesis?", preferredStyle: .alert)
                                        alert.addAction(UIAlertAction(title: "Confirm", style: .default, handler: { (_) in
                                            let hypothesis = self.viewModel.hypothesisList()[indexPath.row]
                                            self.viewModel.deleteHypothesis(hypothesis, at: indexPath.row)
                                            self.tableViewHypothesis.reloadData()
                                        }))
                                        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
                                        self.present(alert, animated: true, completion: nil)
                                        
        }
    }
    
}

extension ImproveHypothesisViewController: PracticeBreakPromptViewDelegate {
    
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
