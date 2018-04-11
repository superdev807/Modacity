//
//  ImproveSuggestionViewController.swift
//  Modacity
//
//  Created by Perfect Engineer on 3/13/18.
//  Copyright © 2018 crossover. All rights reserved.
//

import UIKit

class ImproveSuggestionViewController: UIViewController {
    
    var viewModel = ImprovementViewModel()

    var playlistModel: PlaylistDetailsViewModel!
    
    @IBOutlet weak var labelPracticeName: UILabel!
    @IBOutlet weak var textfieldInputBox: UITextField!
    @IBOutlet weak var viewInputBox: UIView!
    @IBOutlet weak var collectionViewMain: UICollectionView!
    @IBOutlet weak var buttonCloseBox: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        self.textfieldInputBox.attributedPlaceholder = NSAttributedString(string: "Type here or choose a suggestion", attributes: [NSAttributedStringKey.foregroundColor:Color.white.alpha(0.5)])
        self.viewInputBox.layer.cornerRadius = 5
        self.buttonCloseBox.isHidden = true
        self.labelPracticeName.text = self.playlistModel.currentPracticeEntry.practiceItem()?.name ?? ""
        
        NotificationCenter.default.addObserver(self, selector: #selector(onKeyboardWillShow), name: Notification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(onKeyboardWillHide), name: Notification.Name.UIKeyboardWillHide, object: nil)
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "sid_next" {
            AmplitudeTracker.LogEvent(.ImprovementChosen, extraParamName: "Improvement", extraParamValue: viewModel.selectedSuggestion)
            let controller = segue.destination as! ImproveHypothesisViewController
            controller.viewModel = self.viewModel
            controller.playlistModel = self.playlistModel
        }
    }

    @IBAction func onClose(_ sender: Any) {
        AmplitudeTracker.LogStringEvent("Closed Improve Screen")
        self.navigationController?.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func onHideKeyboard(_ sender: Any) {
//        self.textfieldInputBox.resignFirstResponder()
    }
    
    @IBAction func onDidEndOnExit(_ sender: Any) {
        self.viewModel.selectedSuggestion = self.textfieldInputBox.text ?? ""
        self.performSegue(withIdentifier: "sid_next", sender: nil)
    }
    
    @objc func onKeyboardWillShow() {
        self.buttonCloseBox.isHidden = false
    }
    
    @objc func onKeyboardWillHide() {
        self.buttonCloseBox.isHidden = true
    }
}

extension ImproveSuggestionViewController: UICollectionViewDelegate, UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.viewModel.suggestions.count
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        self.viewModel.selectedSuggestion = self.viewModel.suggestions[indexPath.row]
        self.performSegue(withIdentifier: "sid_next", sender: nil)
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "SuggestCell", for: indexPath)
        if let label = cell.viewWithTag(10) as? UILabel {
            label.text = self.viewModel.suggestions[indexPath.row]
        }
        return cell
    }
}
