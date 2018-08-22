//
//  AppUtils.swift
//
//
//  Created by Benjamin Chris on 2017/03/27.
//

import UIKit

#if os(iOS)
    import UIKit
    public typealias Color = UIColor
    public typealias Image = UIImage
#elseif os(OSX)
    import Cocoa
    public typealias Color = NSColor
    public typealias Image = NSImage
#endif

enum DeviceSizeModel {
    case iphone4_35in
    case iphone5_4in
    case iphone6_47in
    case iphone6p_55in
    case unknown
}

class AppUtils: NSObject {
    
    class func showSimpleAlertMessage(for controller:UIViewController, title:String?, message : String?, handler: ((UIAlertAction) -> Swift.Void)? = nil) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: handler))
        controller.present(alert, animated: true, completion: nil)
    }
    
    class func sizeModelOfiPhone() -> DeviceSizeModel {
        let screenHeight = max(UIScreen.main.bounds.size.height, UIScreen.main.bounds.size.width)
        if screenHeight <= 480 {
            return .iphone4_35in
        } else if screenHeight <= 568 {
            return .iphone5_4in
        } else if screenHeight <= 667 {
            return .iphone6_47in
        } else if screenHeight <= 736 {
            return .iphone6p_55in
        } else {
            return .unknown
        }
    }
    
    class func iphoneIsXModel() -> Bool {
        if max(UIScreen.main.nativeBounds.size.height, UIScreen.main.nativeBounds.size.width) == 2436 {
            return true
        }
        return false
    }
    
    class func weekDaysString(withShortMode : Bool, fromSunday : Bool, lowercaseMode: Int = 0) -> [String] {
        
        // lowercasemode : 0 : SUN
        // lowercasemode : 1 : sun
        // lowercasemode : 2 : Sun
        
        if withShortMode {
            if fromSunday {
                if lowercaseMode == 0 {
                    return ["SUN", "MON", "TUE", "WED", "THU", "FRI", "SAT"]
                } else if lowercaseMode == 1 {
                    return ["sun", "mon", "tue", "wed", "thu", "fri", "sat"]
                } else {
                    return ["Sun", "Mon", "Tue", "Wed", "Thu", "Fri", "Sat"]
                }
            } else {
                return ["MON", "TUE", "WED", "THU", "FRI", "SAT", "SUN"]
            }
        } else {
            if fromSunday {
                if lowercaseMode == 0 {
                    return ["SUNDAY", "MONDAY", "TUESDAY", "WEDNESDAY", "THURSDAY", "FRIDAY", "SATURDAY"]
                } else if lowercaseMode == 1 {
                    return ["sunday", "monday", "tuesday", "wednesday", "thursday", "friday", "saturday"]
                } else {
                    return ["Sunday", "Monday", "Tuesday", "Wednesday", "Thursday", "Friday", "Saturday"]
                }
            } else {
                if lowercaseMode == 0 {
                    return ["MONDAY", "TUESDAY", "WEDNESDAY", "THURSDAY", "FRIDAY", "SATURDAY", "SUNDAY"]
                } else if lowercaseMode == 1 {
                    return ["monday", "tuesday", "wednesday", "thursday", "friday", "saturday", "sunday"]
                } else {
                    return ["Monday", "Tuesday", "Wednesday", "Thursday", "Friday", "Saturday", "Sunday"]
                }
            }
        }
    }
    
    class func cleanDuplicatedEntries(in array:[String])->[String] {
        var dicts = [String:Bool]()
        var newArray = [String]()
        for string in array {
            if dicts[string] == nil {
                dicts[string] = true
                newArray.append(string)
            }
        }
        return newArray
    }
}

public extension Color {
    
    public convenience init(_ hexString: String) {
        self.init(hexString: hexString, alpha: 1.0)
    }
    
    public convenience init(hexString: String, alpha: Float = 1.0) {
        var red: CGFloat = 0
        var green: CGFloat = 0
        var blue: CGFloat = 0
        var mAlpha: CGFloat = CGFloat(alpha)
        var minusLength = 0
        
        let scanner = Scanner(string: hexString)
        
        if hexString.hasPrefix("#") {
            scanner.scanLocation = 1
            minusLength = 1
        }
        if hexString.hasPrefix("0x") {
            scanner.scanLocation = 2
            minusLength = 2
        }
        var hexValue: UInt64 = 0
        scanner.scanHexInt64(&hexValue)
        switch hexString.characters.count - minusLength {
        case 3:
            red = CGFloat((hexValue & 0xF00) >> 8) / 15.0
            green = CGFloat((hexValue & 0x0F0) >> 4) / 15.0
            blue = CGFloat(hexValue & 0x00F) / 15.0
        case 4:
            red = CGFloat((hexValue & 0xF000) >> 12) / 15.0
            green = CGFloat((hexValue & 0x0F00) >> 8) / 15.0
            blue = CGFloat((hexValue & 0x00F0) >> 4) / 15.0
            mAlpha = CGFloat(hexValue & 0x00F) / 15.0
        case 6:
            red = CGFloat((hexValue & 0xFF0000) >> 16) / 255.0
            green = CGFloat((hexValue & 0x00FF00) >> 8) / 255.0
            blue = CGFloat(hexValue & 0x0000FF) / 255.0
        case 8:
            red = CGFloat((hexValue & 0xFF000000) >> 24) / 255.0
            green = CGFloat((hexValue & 0x00FF0000) >> 16) / 255.0
            blue = CGFloat((hexValue & 0x0000FF00) >> 8) / 255.0
            mAlpha = CGFloat(hexValue & 0x000000FF) / 255.0
        default:
            break
        }
        self.init(red: red, green: green, blue: blue, alpha: mAlpha)
    }
    
    /// color components value between 0 to 255
    public convenience init(byteRed red: Int, green: Int, blue: Int, alpha: Float = 1.0) {
        self.init(red: CGFloat(red) / 255.0, green: CGFloat(green) / 255.0, blue: CGFloat(blue) / 255.0, alpha: CGFloat(alpha))
    }
    
    public func alpha(_ value: Float) -> Color {
        let (red, green, blue, _) = colorComponents()
        return Color(red: red, green: green, blue: blue, alpha: CGFloat(value))
    }
    
    public func red(_ value: Int) -> Color {
        let (_, green, blue, alpha) = colorComponents()
        return Color(red: CGFloat(value)/255.0, green: green, blue: blue, alpha: alpha)
    }
    
    public func green(_ value: Int) -> Color {
        let (red, _, blue, alpha) = colorComponents()
        return Color(red: red, green: CGFloat(value)/255.0, blue: blue, alpha: alpha)
    }
    
    public func blue(_ value: Int) -> Color {
        let (red, green, _, alpha) = colorComponents()
        return Color(red: red, green: green, blue: CGFloat(value)/255.0, alpha: alpha)
    }
    
    public func colorComponents() -> (CGFloat, CGFloat, CGFloat, CGFloat) {
        var red: CGFloat = 0
        var green: CGFloat = 0
        var blue: CGFloat = 0
        var alpha: CGFloat = 0
        #if os(iOS)
            self.getRed(&red, green: &green, blue: &blue, alpha: &alpha)
        #elseif os(OSX)
            self.usingColorSpaceName(NSCalibratedRGBColorSpace)!.getRed(&red, green: &green, blue: &blue, alpha: &alpha)
        #endif
        return (red, green, blue, alpha)
    }
    
    public func toHexString() -> String {
        let components = self.cgColor.components!
        
        let r = components[0]
        let g = components[1]
        let b = components[2]
        
        return String(format: "0x%02lX%02lX%02lX", lroundf(Float(r * 255)), lroundf(Float(g * 255)), lroundf(Float(b * 255)))
    }
}

public extension String {
    
    func isValidDouble(maxDecimalPlaces: Int) -> Bool {
        let formatter = NumberFormatter()
        formatter.allowsFloats = true
        let decimalSeparator = formatter.decimalSeparator ?? "."
        
        if formatter.number(from: self) != nil {
            let split = self.components(separatedBy: decimalSeparator)
            let digits = split.count == 2 ? split.last ?? "" : ""
            return digits.count <= maxDecimalPlaces
        }
        
        return false
    }
    
    func measureSize(for font: UIFont, constraindTo size: CGSize) -> CGSize {
        let attributedDictionary = [NSAttributedStringKey.font: font]
        let frame = self.boundingRect(with: size, options: .usesLineFragmentOrigin, attributes: attributedDictionary, context: nil)
        return CGSize(width: CGFloat(ceilf(Float(frame.size.width))), height: CGFloat(ceilf(Float(frame.size.height))))
    }
    
    func isValidEmail() -> Bool {
        
        let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
        let emailTest = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
        return emailTest.evaluate(with:self)
    }
    
    func toJSON() -> Any? {
        guard let data = self.data(using: .utf8, allowLossyConversion: false) else { return nil }
        return try? JSONSerialization.jsonObject(with: data, options: .mutableContainers)
    }
    
    func capitalizingFirstLetter() -> String {
        return prefix(1).uppercased() + dropFirst()
    }
    
    mutating func capitalizeFirstLetter() {
        self = self.capitalizingFirstLetter()
    }

    subscript(_ range: CountableRange<Int>) -> String {
        let idx1 = index(startIndex, offsetBy: max(0, range.lowerBound))
        let idx2 = index(startIndex, offsetBy: min(self.count, range.upperBound))
        return String(self[idx1..<idx2])
    }
}

public extension UIImage {
    
    func resizeWith(percentage: CGFloat) -> UIImage? {
        let imageView = UIImageView(frame: CGRect(origin: .zero, size: CGSize(width: size.width * percentage, height: size.height * percentage)))
        imageView.contentMode = .scaleAspectFit
        imageView.image = self
        UIGraphicsBeginImageContextWithOptions(imageView.bounds.size, false, scale)
        guard let context = UIGraphicsGetCurrentContext() else { return nil }
        imageView.layer.render(in: context)
        guard let result = UIGraphicsGetImageFromCurrentImageContext() else { return nil }
        UIGraphicsEndImageContext()
        return result
    }
    
    func resizeWith(width: CGFloat) -> UIImage? {
        let imageView = UIImageView(frame: CGRect(origin: .zero, size: CGSize(width: width, height: CGFloat(ceil(width/size.width * size.height)))))
        imageView.contentMode = .scaleAspectFit
        imageView.image = self
        UIGraphicsBeginImageContextWithOptions(imageView.bounds.size, false, scale)
        guard let context = UIGraphicsGetCurrentContext() else { return nil }
        imageView.layer.render(in: context)
        guard let result = UIGraphicsGetImageFromCurrentImageContext() else { return nil }
        UIGraphicsEndImageContext()
        return result
    }
    
    func resizeWith(height: CGFloat) -> UIImage? {
        let imageView = UIImageView(frame: CGRect(origin: .zero, size: CGSize(width: CGFloat(ceil(height/size.height * size.width)), height: height)))
        imageView.contentMode = .scaleAspectFit
        imageView.image = self
        UIGraphicsBeginImageContextWithOptions(imageView.bounds.size, false, scale)
        guard let context = UIGraphicsGetCurrentContext() else { return nil }
        imageView.layer.render(in: context)
        guard let result = UIGraphicsGetImageFromCurrentImageContext() else { return nil }
        UIGraphicsEndImageContext()
        return result
    }
    
    func isSquare() -> Bool {
        let delta = fabs(self.size.width - self.size.height)
        return delta / self.size.width < 0.005
    }
    
    func isLandsacpe() -> Bool {
        if self.isSquare() {
            return true
        }
        
        return self.size.width >= self.size.height
    }
    
    func mask(with color: UIColor) -> UIImage? {
        let maskImage = cgImage!
        
        let width = size.width
        let height = size.height
        let bounds = CGRect(x: 0, y: 0, width: width, height: height)
        
        let colorSpace = CGColorSpaceCreateDeviceRGB()
        let bitmapInfo = CGBitmapInfo(rawValue: CGImageAlphaInfo.premultipliedLast.rawValue)
        let context = CGContext(data: nil, width: Int(width), height: Int(height), bitsPerComponent: 8, bytesPerRow: 0, space: colorSpace, bitmapInfo: bitmapInfo.rawValue)!
        
        context.clip(to: bounds, mask: maskImage)
        context.setFillColor(color.cgColor)
        context.fill(bounds)
        
        if let cgImage = context.makeImage() {
            let coloredImage = UIImage(cgImage: cgImage)
            return coloredImage
        } else {
            return nil
        }

    }
    
    class func image(for view:UIView) -> UIImage {
        UIGraphicsBeginImageContextWithOptions(view.bounds.size, view.isOpaque, 0.0)
        view.layer.render(in: UIGraphicsGetCurrentContext()!)
        let img = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return img!
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

extension UIView {
    class func fromNib<T: UIView>(_ nib:String) -> T {
        return Bundle.main.loadNibNamed(nib, owner: nil, options: nil)![0] as! T
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
