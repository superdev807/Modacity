//
//  HomeViewController.swift
//  Modacity
//
//  Created by Perfect Engineer on 1/10/18.
//  Copyright © 2018 crossover. All rights reserved.
//

import UIKit

class HomeViewController: UIViewController {

    @IBOutlet weak var textfieldTotalHours: UITextField!
    @IBOutlet weak var textfieldDayStreak: UITextField!
    @IBOutlet weak var textfieldImprovements: UITextField!
    
    private var formatter: NumberFormatter!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        self.textfieldTotalHours.delegate = self
        self.textfieldTotalHours.tintColor = Color.white
        
        self.textfieldDayStreak.delegate = self
        self.textfieldDayStreak.tintColor = Color.white
        
        self.textfieldImprovements.delegate = self
        self.textfieldImprovements.tintColor = Color.white
        
        self.formatter = NumberFormatter()
        self.formatter.numberStyle = .decimal
        self.formatter.minimum = 0
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationItem.title = "Home"
    }

    @IBAction func onTotalHours(_ sender: Any) {
        self.textfieldTotalHours.becomeFirstResponder()
    }
    
    @IBAction func onEditingChangedOnTotalHours(_ sender:UITextField) {
        if sender.text!.contains(".") {
        } else {
            sender.text = "\(Int(sender.text ?? "") ?? 0)"
        }
    }
    
    @IBAction func onDidEndOnExitOnFields(_ sender: UITextField) {
        if sender == self.textfieldTotalHours {
            self.textfieldDayStreak.becomeFirstResponder()
        } else if sender == self.textfieldDayStreak {
            self.textfieldImprovements.becomeFirstResponder()
        } else {
            self.textfieldImprovements.resignFirstResponder()
        }
    }
    
    @IBAction func onMenu(_ sender: Any) {
        self.sideMenuController?.showLeftViewAnimated()
    }
    
}

extension HomeViewController: UITextFieldDelegate {
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        if string == "\n" {
            return true
        }
        return formatter.number(from:"\(textField.text ?? "")\(string)") != nil
    }
}
