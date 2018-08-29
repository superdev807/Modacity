//
//  AppUtils.swift
//
//
//  Created by Benjamin Chris on 2017/03/27.
//

import UIKit

extension UIView {
    class func fromNib<T: UIView>(_ nib:String) -> T {
        return Bundle.main.loadNibNamed(nib, owner: nil, options: nil)![0] as! T
    }
    
    func styling(cornerRadius: CGFloat? = 0, borderColor: UIColor? = Color.clear, borderWidth: CGFloat? = 0) {
        self.layer.cornerRadius = cornerRadius ?? 0
        self.layer.borderWidth = borderWidth ?? 0
        self.layer.borderColor = borderColor?.cgColor ?? Color.clear.cgColor
    }
}
