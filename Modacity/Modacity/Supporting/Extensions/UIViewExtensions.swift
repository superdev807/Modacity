//
//  UIViewExtensions.swift
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

extension UITableViewRowAction {
    
    func setIcon(iconImage: UIImage, backColor: UIColor, cellHeight: CGFloat, iconSizePercentage: CGFloat)
    {
        let iconHeight = cellHeight * iconSizePercentage
        let margin = (cellHeight - iconHeight) / 2 as CGFloat
        
        UIGraphicsBeginImageContextWithOptions(CGSize(width: cellHeight, height: cellHeight), false, 0)
        let context = UIGraphicsGetCurrentContext()
        
        backColor.setFill()
        context!.fill(CGRect(x:0, y:0, width:cellHeight, height:cellHeight))
        
        iconImage.draw(in: CGRect(x: margin * 1.2, y: margin, width: iconHeight, height: iconHeight))
        
        let actionImage = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
        
        self.backgroundColor = UIColor.init(patternImage: actionImage!)
    }
}

extension UINavigationController {
    override open var supportedInterfaceOrientations : UIInterfaceOrientationMask     {
        return [.portrait, .portraitUpsideDown]
    }
}

extension UITabBarController {
    override open var supportedInterfaceOrientations : UIInterfaceOrientationMask     {
        return [.portrait, .portraitUpsideDown]
    }
}

extension UITextView {
    func alignCenterToVerticalCenter() {
        let size = self.sizeThatFits(CGSize(width: self.bounds.size.width, height: CGFloat.greatestFiniteMagnitude))
        var topoffset = (self.bounds.size.height - size.height * self.zoomScale) / 2.0
        topoffset = topoffset < 0.0 ? 0.0 : topoffset
        self.setContentOffset(CGPoint(x: 0, y: -topoffset), animated: false)
    }
}

class VerticalCenterTextView: UITextView {
    override func layoutSubviews() {
        super.layoutSubviews()
        self.alignCenterToVerticalCenter()
    }
}
