//
//  UITextField+DoneCancelToolbar.swift
//  Modacity
//
//  Created by Marc Gelfo on 9/10/18.
//  Copyright © 2018 Modacity, Inc. All rights reserved.
//

import UIKit

class UINumberPadWithDoneCancel : UITextField {
    var doneFunction: ((Any, Selector))?
    var cancelFunction: ((Any, Selector))?
    
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)!
        addDoneCancelToolbar()
    }
    
    func addDoneCancelToolbar(onDone: (target: Any, action: Selector)? = nil, onCancel: (target: Any, action: Selector)? = nil) {
        let onCancel = onCancel ?? (target: self, action: #selector(cancelButtonTapped))
        let onDone = onDone ?? (target: self, action: #selector(doneButtonTapped))
        
        let buttonCancel = UIBarButtonItem(title: "Cancel", style: .plain, target: onCancel.target, action: onCancel.action)
        let buttonDone = UIBarButtonItem(title: "Done", style: .done, target: onDone.target, action: onDone.action)
        
        buttonCancel.setTitleTextAttributes([NSAttributedStringKey.foregroundColor: Color(hexString: "#5311CA")], for: .normal)
        buttonDone.setTitleTextAttributes([NSAttributedStringKey.foregroundColor: Color(hexString: "#5311CA")], for: .normal)
        
        let toolbar: UIToolbar = UIToolbar()
        toolbar.barStyle = .default
        toolbar.items = [
            //buttonCancel,
            UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: self, action: nil),
            buttonDone
        ]
        toolbar.sizeToFit()
        
        self.inputAccessoryView = toolbar
    }
    
    // Default actions:
    @objc func doneButtonTapped() { self.resignFirstResponder() }
    @objc func cancelButtonTapped() { self.resignFirstResponder() }
}
