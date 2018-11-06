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
    case iphoneX_xS
    case iphonexR_xSMax
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
        } else if screenHeight <= 812 {
            return .iphoneX_xS
        } else if screenHeight <= 896 {
            return .iphonexR_xSMax
        } else {
            return .unknown
        }
    }
    
    class func iPhoneXorXRorXS() -> Bool {
        return sizeModelOfiPhone() == .iphoneX_xS || sizeModelOfiPhone() == .iphonexR_xSMax
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
    
    class func totalPracticeTimeDisplay(seconds: Int) -> [String:String] {
        
        let formatter = NumberFormatter()
        formatter.minimumFractionDigits = 0
        formatter.maximumFractionDigits = 1
        formatter.numberStyle = .decimal
        
        var results = [String: String]()
        if seconds < 3600 {
            results["value"] = formatter.string(from: (Float(seconds) / 60.0) as NSNumber) ?? "n/a"
            results["unit"] = "MINUTES"
        } else {
            results["value"] = formatter.string(from: (Float(seconds) / 3600.0) as NSNumber) ?? "n/a"
            results["unit"] = "HOURS"
        }
        return results
    }
    
    class func stringFromDateLocale(from date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .short
        formatter.timeStyle = .none
        return formatter.string(from: date)
    }
    
    class func dateFromStringLocale(from string:String) -> Date? {
        let formatter = DateFormatter()
        formatter.dateStyle = .short
        formatter.timeStyle = .none
        return formatter.date(from: string)
    }
}
