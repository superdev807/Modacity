//
//  AppConfig.swift
//  jitensha
//
//  Created by Benjamin Chris on 12/12/17.
//  Copyright © 2017 crossover. All rights reserved.
//

import UIKit

class AppConfig: NSObject {
    
    struct UI {
        struct AppColors {
            static let inputContainerBorderColor = Color(hexString: "#D4D4D4")
            static let tabbarSelectedIconColor = Color(hexString: "#2b67f5")
            static let tabbarNormalIconColor = Color(hexString: "#60637c")
            static let timerGreenColor = Color(hexString: "#1bbcb6")
            static let walkthroughOverlayColor = Color(hexString: "#252738").alpha(0.85)
            static let placeholderTextColorGray = Color(hexString: "#8F9098")
            static let placeholderIconColorGray = Color(hexString: "#AEAEB4")
            static let listHeaderBackgroundColor = Color(hexString: "#393B49")
            static let noteTextColorInPractice = Color(hexString: "#9697A6")
        }
        
        struct AppUIValues {
            static let viewPanelCornerRadius:CGFloat = 4
            static let viewPanelBorderWidth:CGFloat = 1
        }
        
        struct Fonts {
            static let appFontLatoRegular = "Lato-Regular"
            static let appFontLatoBold = "Lato-Bold"
            static let appFontLatoBlack = "Lato-Black"
            static let appFontLatoBoldItalic = "Lato-BoldItalic"
            static let appFontLatoItalic = "Lato-Italic"
            static let appFontLatoLight = "Lato-Light"
            
            static func latoRegular(with size: CGFloat) -> UIFont {
                return UIFont(name: appFontLatoRegular, size: size)!
            }
            
            static func latoBold(with size: CGFloat) -> UIFont {
                return UIFont(name: appFontLatoBold, size: size)!
            }
            
            static func latoBlack(with size: CGFloat) -> UIFont {
                return UIFont(name: appFontLatoBlack, size: size)!
            }
            
            static func latoLight(with size: CGFloat) -> UIFont {
                return UIFont(name: appFontLatoLight, size: size)!
            }
            
            static func latoItalic(with size: CGFloat) -> UIFont {
                return UIFont(name: appFontLatoItalic, size: size)!
            }
            
            static func latoBoldItalic(with size: CGFloat) -> UIFont {
                return UIFont(name: appFontLatoBoldItalic, size: size)!
            }
        }
    }
    
    struct ThirdParty {
        
        static let appIdOnAppStore = "1351617981"
        static let appIntercomApiKey = "ios_sdk-f447e55f2c171cec792a026f22b81c2188765217"
        static let appIntercomAppId = "q5zl4zj8"
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
        static let appMintApiKey = "b2ee2ef2"
        
        static let appsFlyerDevKey = "PymGGsKXsSAVgTAiy4ewa6"
        static let appsFlyerAppId = "1351617981"
    }
    
    struct Links {
        static let appConfigHomeUrlLink = "https://www.modacity.co/?utm_source=app&utm_medium=link&utm_campaign=about-us"
        static let appConfigPrivacyUrlLink = "https://www.modacity.co/legal/#privacy"
        static let appConfigTermsUrlLink = "https://www.modacity.co/legal/#terms"
        static let appConfigShareTheAppUrlLink = "https://modacity.co/?utm_source=app&utm_medium=app&utm_campaign=share"
        static let appConfigTwitterLink = "https://twitter.com/ModacityApp"
        static let appConfigInstagramLink = "http://instagram.com/modacityapp"
        static let appConfigFacebookLink = "https://www.facebook.com/ModacityApp/"
        static let appConfigWebsiteLink = "https://www.modacity.co"
        
        static let appDeliberatePracticeTutorialYoutubeId = "6WfMEMJ0VPk"
        static let appDeliberatePracticeTutorialYoutubeLink = "youtube://\(appDeliberatePracticeTutorialYoutubeId)"
        static let appDeliberatePracticeTutorialLink = "https://www.youtube.com/watch?v=\(appDeliberatePracticeTutorialYoutubeId)"
    }
    
    struct YoutubeVideoIds {
        static let appHowToVideoYoutubeId = "XVUGnexvAMs"
        static let appDeliberatePracticeTutorialYoutubeId = "6WfMEMJ0VPk"
    }
    
    struct NotificationNames {
        static let appNotificationOverallAppDataLoadedFromServer = Notification.Name(rawValue: "appNotificationOverallAppDataLoadedFromServer")
        static let appNotificationPracticeLoadedFromServer = Notification.Name(rawValue: "appNotificationPracticeLoadedFromServer")
        static let appNotificationPlaylistLoadedFromServer = Notification.Name(rawValue: "appNotificationPlaylistLoadedFromServer")
        static let appNotificationRecentSessionsLoadedFromServer = Notification.Name(rawValue: "appNotificationRecentSessionsLoadedFromServer")
        static let appNotificationPlaylistUpdated = Notification.Name(rawValue: "appNotificationPlaylistUpdated")
        static let appNotificationPlaylistPracticeDataFetched = Notification.Name(rawValue: "appNotificationPlaylistPracticeDataFetched")
        static let appNotificationPracticeDataFetched = Notification.Name(rawValue: "appNotificationPracticeDataFetched")
        static let appNotificationProfileUpdated = Notification.Name(rawValue: "appNotificationProfileUpdated")
        static let appNotificationPremiumStatusChanged = Notification.Name(rawValue: "appNotificationPremiumStatusChanged")
        static let appNotificationMetrodroneAudioEnginePrepared = Notification.Name(rawValue: "appNotificationMetrodroneAudioEnginePrepared")
        static let appNotificationSyncStatusUpdated = Notification.Name(rawValue: "appNotificationSyncStatusUpdated")
        static let appNotificationWalkthroughSynchronized = Notification.Name(rawValue: "appNotificationWalkthroughSynchronized")
        static let appNotificationHomePageValuesLoaded = Notification.Name(rawValue: "appNotificationHomePageValuesLoaded")
        static let appNotificationMetrodroneParametersUpdated = Notification.Name(rawValue: "appNotificationMetrodroneParametersUpdated")
        static let appNotificationGuestAccountSwitched = Notification.Name(rawValue: "appNotificationGuestAccountSwitched")
        static let appNotificationGuestSignUpCanceled = Notification.Name(rawValue: "appNotificationGuestSignUpCanceled")
    }
    
    struct Constants {
        static let appMaxNumberForRecentPlaylists = 10
        static let appFreeTrialDays = 14
        
        static let appConstantTempPlaylistId = "tempplaylist"
        static let appConstantMiscPracticeItemId = "MISC-PRACTICE"
        static let appConstantMiscPracticeItemName = "Misc. Practice"
        
        static let appGuestUserPlaylistLimit = 3
        static let appGuestUserStandalonePracticeLimit = 10
        
        static let appRecordingStartFileName = "/recording.m4a"
        static let appSavedAudioFileExtension = ".m4a"
        
        static let appRecentQueueMaxSessionsCount = 50
    }
    
    static let devVersion: Bool = {
        let appBundleId = Bundle.main.infoDictionary![kCFBundleIdentifierKey as String] as! String
        if appBundleId.contains("dev") {
            return true
        } else {
            return false
        }
    }()
    
    static let production : Bool = {
        #if RELEASE
        ModacityDebugger.debug("RELEASE")
        return true
        #else
        ModacityDebugger.debug("DEBUG")
        return false
        #endif
    }()
}
