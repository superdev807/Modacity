//
//  DropdownMenuView.swift
//  Modacity
//
//  Created by Benjamin Chris on 4/12/18.
//  Copyright © 2018 Modacity, Inc. All rights reserved.
//

import UIKit

class DropdownMenuView {
    
    static let instance = DropdownMenuView()
    
    let widthOfDropdownView = CGFloat(143)
    let heightOf1RowDropdownView = CGFloat(81)
    let heightOf2RowsDropdownView = CGFloat(123)
    let heightOf3RowsDropdownView = CGFloat(161)
    
    var currentView: UIView? = nil
    
    var onClick: ((Int)->())? = nil
    
    func dismiss(_ callbackClick: Bool, row: Int) {
        
        UIView.animate(withDuration: 0.2, animations: {
            self.currentView!.alpha = 0
        }) { (finished) in
            if finished {
                if callbackClick {
                    self.currentView!.removeFromSuperview()
                    if let onClick = self.onClick {
                        onClick(row)
                    }
                }
            }
        }
        
    }
    
    func show(in view:UIView, on anchorView:UIView, rows:[[String:String]], onClick: @escaping (Int)->()) {
        
        if let currentView = currentView {
            currentView.removeFromSuperview()
        }
        
        let menuView = self.createView(with: rows, in: view)
        
        let imageView = menuView.viewWithTag(10) as! UIImageView
        
        let anchorRect = anchorView.convert(anchorView.frame, to: view)
        
        var anchorPoint: CGPoint!
        
        var to = 0
        
        let menuPopupView = menuView.viewWithTag(11)!
        if rows.count == 1 {
            if anchorRect.origin.y + anchorRect.size.height / 2 + heightOf1RowDropdownView  + 40 < view.frame.size.height {
                to = 0
                imageView.image = UIImage(named: "bg_popmenu_1_row_to_down")
                anchorPoint = anchorView.convert(CGPoint(x: anchorView.frame.size.width / 2, y: anchorView.frame.size.height / 2 + 5), to: view)
                menuPopupView.frame = CGRect(x: anchorPoint.x - 118, y: anchorPoint.y, width: widthOfDropdownView, height: heightOf1RowDropdownView)
            } else {
                to = 1
                imageView.image = UIImage(named: "bg_popmenu_1_row_to_up")
                anchorPoint = anchorView.convert(CGPoint(x: anchorView.frame.size.width / 2, y: anchorView.frame.size.height / 2 - 5), to: view)
                menuPopupView.frame = CGRect(x: anchorPoint.x - 118, y: anchorPoint.y - heightOf1RowDropdownView, width: widthOfDropdownView, height: heightOf1RowDropdownView)
            }
        } else if rows.count == 2 {
            if anchorRect.origin.y + anchorRect.size.height / 2 + heightOf2RowsDropdownView + 40 < view.frame.size.height {
                to = 0
                imageView.image = UIImage(named: "bg_popmenu_2_rows_to_down")
                anchorPoint = anchorView.convert(CGPoint(x: anchorView.frame.size.width / 2, y: anchorView.frame.size.height / 2 + 5), to: view)
                menuPopupView.frame = CGRect(x: anchorPoint.x - 118, y: anchorPoint.y, width: widthOfDropdownView, height: heightOf2RowsDropdownView)
            } else {
                to = 1
                imageView.image = UIImage(named: "bg_popmenu_2_rows_to_up")
                anchorPoint = anchorView.convert(CGPoint(x: anchorView.frame.size.width / 2, y: anchorView.frame.size.height / 2 - 5), to: view)
                menuPopupView.frame = CGRect(x: anchorPoint.x - 118, y: anchorPoint.y - heightOf2RowsDropdownView, width: widthOfDropdownView, height: heightOf2RowsDropdownView)
            }
        } else if rows.count == 3 {
            if anchorRect.origin.y + anchorRect.size.height / 2 + heightOf3RowsDropdownView  + 40 < view.frame.size.height {
                to = 0
                imageView.image = UIImage(named: "bg_popmenu_3_rows_to_down")
                anchorPoint = anchorView.convert(CGPoint(x: anchorView.frame.size.width / 2, y: anchorView.frame.size.height / 2 + 5), to: view)
                menuPopupView.frame = CGRect(x: anchorPoint.x - 118, y: anchorPoint.y, width: widthOfDropdownView, height: heightOf3RowsDropdownView)
            } else {
                to = 1
                imageView.image = UIImage(named: "bg_popmenu_3_rows_to_up")
                anchorPoint = anchorView.convert(CGPoint(x: anchorView.frame.size.width / 2, y: anchorView.frame.size.height / 2 - 5), to: view)
                menuPopupView.frame = CGRect(x: anchorPoint.x - 118, y: anchorPoint.y - heightOf3RowsDropdownView, width: widthOfDropdownView, height: heightOf3RowsDropdownView)
            }
        }
        
        self.onClick = onClick
        self.addRows(rows, into: menuView.viewWithTag(11)!, to: to)
        
        view.addSubview(menuView)
        
        view.bringSubview(toFront: menuView)
        
        currentView = menuView
    }
    
    func createView(with rows:[[String:String]], in view: UIView) -> UIView {
        
        let viewContainer = UIView(frame: CGRect(x: 0, y: 0, width: view.frame.size.width, height: view.frame.size.height))
        
        viewContainer.isUserInteractionEnabled = true
        
        let viewPopup = UIView()
        viewPopup.isUserInteractionEnabled = true
        viewPopup.tag = 11
        
        var height = CGFloat(0)
        if rows.count == 1 {
            height = heightOf1RowDropdownView
        } else if rows.count == 2 {
            height = heightOf2RowsDropdownView
        } else {
            height = heightOf3RowsDropdownView
        }
        let imageView = UIImageView(frame: CGRect(x: 0, y: 0, width: widthOfDropdownView, height: height))
        imageView.tag = 10
        viewPopup.addSubview(imageView)
        
        let button = UIButton(frame: CGRect(x:0, y:0, width: view.frame.size.width, height: view.frame.size.height))
        button.addTarget(self, action: #selector(onClose), for: .touchDown)
        viewContainer.addSubview(button)
        
        viewContainer.addSubview(viewPopup)
        
        return viewContainer
        
    }
    
    func addRows(_ rows:[[String:String]], into viewPopup: UIView, to: Int) {
        
        let rowHeight = (to == 0) ? CGFloat(40) : CGFloat(40)
        let rowMargin = CGFloat(5)
        var y = (to == 0) ? CGFloat(24) : CGFloat(12)
        
        for idx in 0..<rows.count {
            
            let row = rows[idx]
            
            let button = UIButton(frame: CGRect(x: 4, y: y, width: widthOfDropdownView - 4 * 2, height: rowHeight))
            button.tag = idx + 100
            button.addTarget(self, action: #selector(onDown), for: .touchDown)
            button.addTarget(self, action: #selector(onTouchUpOutside), for: .touchUpOutside)
            button.addTarget(self, action: #selector(onTap), for: .touchUpInside)
            viewPopup.addSubview(button)
            
            let icon = row["icon"]
            let imageViewIcon = UIImageView(image: UIImage(named: icon!)!)
            imageViewIcon.frame = CGRect(x: rowMargin, y: y, width: rowHeight, height: rowHeight)
            imageViewIcon.contentMode = .center
            viewPopup.addSubview(imageViewIcon)
            
            let text = row["text"]
            let labelText = UILabel(frame: CGRect(x: rowMargin + rowHeight + 5, y: y, width: widthOfDropdownView - (rowMargin * 2 + rowHeight + 5) - 10, height: rowHeight))
            labelText.textColor = Color.white
            labelText.text = text
            viewPopup.addSubview(labelText)
            
            y = y + rowHeight
        }
    }
    
    @objc func onDown(_ sender: UIButton) {
        sender.backgroundColor = Color.white.alpha(0.3)
    }
    
    @objc func onTouchUpOutside(_ sender: UIButton) {
        sender.backgroundColor = Color.clear
    }
    
    @objc func onClose() {
        self.dismiss(false, row:0)
    }
    
    @objc func onTap(_ sender: UIButton) {
        sender.backgroundColor = Color.clear
        self.dismiss(true, row: sender.tag - 100)
        
    }
    
}
