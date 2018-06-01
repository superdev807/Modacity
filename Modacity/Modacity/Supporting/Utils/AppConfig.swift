//
//  AppConfig.swift
//  jitensha
//
//  Created by Benjamin Chris on 12/12/17.
//  Copyright © 2017 crossover. All rights reserved.
//

import UIKit

class AppConfig: NSObject {
    
    static var appAmplitudeApiKey: String! {
        get {
            let appBundleId = Bundle.main.infoDictionary![kCFBundleIdentifierKey as String] as! String
            if appBundleId.contains("dev") {
                return "03977994819768a709d41a9d0a729de2"
            } else {
                return "91054e0297cb647ebb3a32443f33c2db"
            }
        }
    }
    static let appGoogleAnalyticsTrackingId = "111435557"
    
    static let appFontLatoRegular = "Lato-Regular"
    static let appFontLatoBold = "Lato-Bold"
    static let appFontLatoBoldItalic = "Lato-BoldItalic"
    static let appFontLatoItalic = "Lato-Italic"
    static let appFontLatoLight = "Lato-Light"
    
    static let appConfigTabbarSelectedIconColor = Color(hexString: "#2b67f5")
    static let appConfigTabbarNormalIconColor = Color(hexString: "#60637c")
    static let appConfigTimerGreenColor = Color(hexString: "#1bbcb6")
    static let appConfigWalkthroughOverlayColor = Color(hexString: "#252738").alpha(0.85)
    
    static let appConfigHomeUrlLink = "https://www.modacity.co/?utm_source=app&utm_medium=link&utm_campaign=about-us"
    static let appConfigPrivacyUrlLink = "https://www.modacity.co/legal/#privacy/?utm_source=app&utm_medium=link&utm_campaign=about-us"
    static let appConfigTermsUrlLink = "https://www.modacity.co/legal/#terms/?utm_source=app&utm_medium=link&utm_campaign=about-us"
    static let appConfigShareTheAppUrlLink = "https://modacity.co/?utm_source=app&utm_medium=app&utm_campaign=share"
    static let appConfigTwitterLink = "https://twitter.com/ModacityApp"
    static let appConfigInstagramLink = "http://instagram.com/modacityapp"
    static let appConfigFacebookLink = "https://www.facebook.com/ModacityApp/"
    static let appConfigWebsiteLink = "https://www.modacity.co"
    
    static let appNotificationPracticeLoadedFromServer = Notification.Name(rawValue: "appNotificationPracticeLoadedFromServer")
    static let appNotificationPlaylistLoadedFromServer = Notification.Name(rawValue: "appNotificationPlaylistLoadedFromServer")
    static let appNotificationPlaylistUpdated = Notification.Name(rawValue: "appNotificationPlaylistUpdated")
    static let appNotificationProfileUpdated = Notification.Name(rawValue: "appNotificationProfileUpdated")
    
    static let appMaxNumberForRecentPlaylists = 10
    
    static let appIdOnAppStore = "1351617981"
}
