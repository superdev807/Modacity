//
//  ImprovementWalkthroughViewController.swift
//  Modacity Inc
//
//  Created by Benjamin Chris on 8/11/18.
//  Copyright © 2018 Modacity, Inc. All rights reserved.
//

import UIKit

class ImprovementWalkthroughViewController: ModacityParentViewController {

    @IBOutlet weak var viewInstructionPanel: UIView!
    @IBOutlet weak var buttonGotIt: UIButton!
    
    @IBOutlet weak var labelHeaderInstruction: UILabel!
    
    @IBOutlet weak var constraintPanelTopSpace: NSLayoutConstraint!
    @IBOutlet weak var constraintPanelBottomSpace: NSLayoutConstraint!
    @IBOutlet weak var labelInstructionHeader: UILabel!
    @IBOutlet weak var labelInstructionBody: UILabel!
    @IBOutlet weak var constraintInstructionBodyTopSpace: NSLayoutConstraint!
    @IBOutlet weak var constraintInstructionBodyBottomSpace: NSLayoutConstraint!
    @IBOutlet weak var buttonLearnMoreAbout: UIButton!
    @IBOutlet weak var constraintHeaderInstructionTopSpace: NSLayoutConstraint!
    
    var playlistModel: PlaylistContentsViewModel!
    var practiceItem: PracticeItem!
    var deliverModel: PlaylistAndPracticeDeliverModel!
    
    var fromSettings = false
    
//    let instruction = "1. Pick one aspect of your piece you’d like  to improve most. Keep it simple.\n\n2.  Identify one thing you can try to in order to achieve that improvment.\n\n3. Record yourself while trying out your theory, and listen to your results.\n\n4. If it works - great! Keeping going until  it’s solid. If not, no problem - try again or test something else."
    
    let instruction = "1. Pick one thing you’d like to improve most. Keep it simple.\n\n2.  Identify one strategy you will try in order to make that improvment.\n\n3. Record yourself while trying your strategy, and listen to the results.\n\n4. If it works - great! Keep going until it’s solid. If not, no problem - try again or test a different strategy."
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        self.configureUI()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "sid_main" {
            let controller = segue.destination as! ImproveSuggestionViewController
            controller.playlistModel = self.playlistModel
            controller.practiceItem = self.practiceItem
            controller.deliverModel = self.deliverModel
        }
    }
    
    @IBAction func onGotIt(_ sender: Any) {
        if self.fromSettings {
            self.navigationController?.popViewController(animated: true)
        } else {
            AppOveralDataManager.manager.walkthroughSetFlag(key: "walkthrough_improvement", value: true)
            self.performSegue(withIdentifier: "sid_main", sender: nil)
        }
    }
    
    @IBAction func onLearnMore(_ sender: Any) {
        let controller = UIStoryboard(name: "video", bundle: nil).instantiateViewController(withIdentifier: "YoutubeViewController") as! YoutubeViewController
        controller.titleString = "How To Deliberate Practice"
        controller.videoId = AppConfig.YoutubeVideoIds.appDeliberatePracticeTutorialYoutubeId
        self.navigationController?.pushViewController(controller, animated: true)
    }
    
    @IBAction func onBack(_ sender: Any) {
        if self.fromSettings {
            self.navigationController?.popViewController(animated: true)
        } else {
            self.navigationController?.dismiss(animated: true, completion: nil)
        }
    }
    
    func configureUI() {
        
        self.buttonGotIt.layer.cornerRadius = 25
        self.viewInstructionPanel.layer.cornerRadius = 10
        
        self.viewInstructionPanel.layer.shadowColor = Color.black.cgColor
        self.viewInstructionPanel.layer.shadowOffset = CGSize(width: 3, height: 3)
        self.viewInstructionPanel.layer.shadowOpacity = 0.7
        self.viewInstructionPanel.layer.shadowRadius = 4.0
        
        var instructionBodySize: CGFloat = 15
        
        switch AppUtils.sizeModelOfiPhone() {
        case .iphonexR_xSMax:
            self.labelHeaderInstruction.font = UIFont(name: AppConfig.UI.Fonts.appFontLatoRegular, size: 14)
            self.constraintPanelTopSpace.constant = 40
            self.constraintPanelBottomSpace.constant = 30
            self.labelInstructionHeader.font = UIFont(name: AppConfig.UI.Fonts.appFontLatoBlack, size: 15)
            self.labelInstructionBody.font = UIFont(name: AppConfig.UI.Fonts.appFontLatoRegular, size: 15)
            instructionBodySize = 15
            self.constraintInstructionBodyTopSpace.constant = 50
            self.constraintInstructionBodyBottomSpace.constant = 50
            self.buttonLearnMoreAbout.titleLabel?.font = UIFont(name: AppConfig.UI.Fonts.appFontLatoRegular, size: 12)
            self.constraintHeaderInstructionTopSpace.constant = 20
        case .iphoneX_xS:
            self.labelHeaderInstruction.font = UIFont(name: AppConfig.UI.Fonts.appFontLatoRegular, size: 14)
            self.constraintPanelTopSpace.constant = 40
            self.constraintPanelBottomSpace.constant = 30
            self.labelInstructionHeader.font = UIFont(name: AppConfig.UI.Fonts.appFontLatoBlack, size: 15)
            self.labelInstructionBody.font = UIFont(name: AppConfig.UI.Fonts.appFontLatoRegular, size: 13)
            instructionBodySize = 13
            self.constraintInstructionBodyTopSpace.constant = 50
            self.constraintInstructionBodyBottomSpace.constant = 50
            self.buttonLearnMoreAbout.titleLabel?.font = UIFont(name: AppConfig.UI.Fonts.appFontLatoRegular, size: 12)
            self.constraintHeaderInstructionTopSpace.constant = 20
        case .iphone6p_55in:
            self.labelHeaderInstruction.font = UIFont(name: AppConfig.UI.Fonts.appFontLatoRegular, size: 14)
            self.constraintPanelTopSpace.constant = 40
            self.constraintPanelBottomSpace.constant = 30
            self.labelInstructionHeader.font = UIFont(name: AppConfig.UI.Fonts.appFontLatoBlack, size: 15)
            self.labelInstructionBody.font = UIFont(name: AppConfig.UI.Fonts.appFontLatoRegular, size: 13)
            instructionBodySize = 13
            self.constraintInstructionBodyTopSpace.constant = 50
            self.constraintInstructionBodyBottomSpace.constant = 50
            self.buttonLearnMoreAbout.titleLabel?.font = UIFont(name: AppConfig.UI.Fonts.appFontLatoRegular, size: 12)
            self.constraintHeaderInstructionTopSpace.constant = 20
        case .iphone6_47in:
            self.labelHeaderInstruction.font = UIFont(name: AppConfig.UI.Fonts.appFontLatoRegular, size: 14)
            self.constraintPanelTopSpace.constant = 40
            self.constraintPanelBottomSpace.constant = 30
            self.labelInstructionHeader.font = UIFont(name: AppConfig.UI.Fonts.appFontLatoBlack, size: 13)
            self.labelInstructionBody.font = UIFont(name: AppConfig.UI.Fonts.appFontLatoRegular, size: 13)
            instructionBodySize = 13
            self.constraintInstructionBodyTopSpace.constant = 25
            self.constraintInstructionBodyBottomSpace.constant = 30
            self.buttonLearnMoreAbout.titleLabel?.font = UIFont(name: AppConfig.UI.Fonts.appFontLatoRegular, size: 12)
            self.constraintHeaderInstructionTopSpace.constant = 20
        case .iphone5_4in:
            self.labelHeaderInstruction.font = UIFont(name: AppConfig.UI.Fonts.appFontLatoRegular, size: 12)
            self.constraintPanelTopSpace.constant = 20
            self.constraintPanelBottomSpace.constant = 10
            self.labelInstructionHeader.font = UIFont(name: AppConfig.UI.Fonts.appFontLatoBlack, size: 13)
            self.labelInstructionBody.font = UIFont(name: AppConfig.UI.Fonts.appFontLatoRegular, size: 10)
            instructionBodySize = 10
            self.constraintInstructionBodyTopSpace.constant = 20
            self.constraintInstructionBodyBottomSpace.constant = 20
            self.buttonLearnMoreAbout.titleLabel?.font = UIFont(name: AppConfig.UI.Fonts.appFontLatoRegular, size: 10)
            self.constraintHeaderInstructionTopSpace.constant = 20
        case .iphone4_35in:
            self.labelHeaderInstruction.font = UIFont(name: AppConfig.UI.Fonts.appFontLatoRegular, size: 11)
            self.constraintPanelTopSpace.constant = 10
            self.constraintPanelBottomSpace.constant = 5
            self.labelInstructionHeader.font = UIFont(name: AppConfig.UI.Fonts.appFontLatoBlack, size: 15)
            self.labelInstructionBody.font = UIFont(name: AppConfig.UI.Fonts.appFontLatoRegular, size: 10)
            instructionBodySize = 10
            self.constraintInstructionBodyTopSpace.constant = 10
            self.constraintInstructionBodyBottomSpace.constant = 10
            self.buttonLearnMoreAbout.titleLabel?.font = UIFont(name: AppConfig.UI.Fonts.appFontLatoRegular, size: 9)
            self.constraintHeaderInstructionTopSpace.constant = 0
        case .unknown:
            break
        }
        
        let attributedInstruction = NSMutableAttributedString(string: instruction, attributes: [NSAttributedStringKey.font: UIFont(name: AppConfig.UI.Fonts.appFontLatoRegular, size: instructionBodySize)!])
        attributedInstruction.addAttribute(NSAttributedStringKey.font, value: UIFont(name: AppConfig.UI.Fonts.appFontLatoBoldItalic, size: instructionBodySize)!, range: NSMakeRange(8, 3))
        attributedInstruction.addAttribute(NSAttributedStringKey.font, value: UIFont(name: AppConfig.UI.Fonts.appFontLatoBoldItalic, size: instructionBodySize)!, range: NSMakeRange(76, 3))
        self.labelInstructionBody.attributedText = attributedInstruction
    }
}
