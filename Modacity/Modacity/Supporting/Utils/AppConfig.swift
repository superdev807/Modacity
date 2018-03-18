//
//  AppConfig.swift
//  jitensha
//
//  Created by Benjamin Chris on 12/12/17.
//  Copyright © 2017 crossover. All rights reserved.
//

import UIKit

class AppConfig: NSObject {
    
    static let appFontLatoRegular = "Lato-Regular"
    static let appFontLatoBold = "Lato-Bold"
    
    static let appConfigTabbarSelectedIconColor = Color(hexString: "#2b67f5")
    static let appConfigTabbarNormalIconColor = Color(hexString: "#60637c")
    static let appConfigTimerGreenColor = Color(hexString: "#1bbcb6")
    
    static let appConfigHomeUrlLink = "https://www.modacity.co/?utm_source=app&utm_medium=link&utm_campaign=about-us"
    static let appConfigPrivacyUrlLink = "https://www.modacity.co/legal/#privacy/?utm_source=app&utm_medium=link&utm_campaign=about-us"
    static let appConfigTermsUrlLink = "https://www.modacity.co/legal/#terms/?utm_source=app&utm_medium=link&utm_campaign=about-us"
    static let appConfigShareTheAppUrlLink = "https://modacity.co/?utm_source=app&utm_medium=app&utm_campaign=share"
    static let appConfigTwitterLink = "https://twitter.com/ModacityApp"
    static let appConfigFacebookLink = "https://www.facebook.com/ModacityApp/"
    static let appConfigWebsiteLink = "https://www.modacity.co"
    
    static let appNotificationPlaylistUpdated = Notification.Name(rawValue: "appNotificationPlaylistUpdated")
    static let appNotificationProfileUpdated = Notification.Name(rawValue: "appNotificationProfileUpdated")
    
    static let appMaxNumberForRecentPlaylists = 2
}
