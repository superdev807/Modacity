//
//  ModacityAnalytics.swift
//  Modacity
//
//  Created by Perfect Engineer on 4/11/18.
//  Copyright © 2018 crossover. All rights reserved.
//

import UIKit
import Firebase
import FBSDKCoreKit
import Amplitude_iOS
import Intercom

enum ModacityEvent:String {
    //Launch & basic functionality

    case Launch = "Launched App"
    case Terminate = "Terminated App"
    case ResumeActive = "Resumed Active State"
    case Background = "Backgrounded App"
    case SideMenu = "Side Menu"

    // First Launch
    case WelcomeTutorial1 = "WelcomeTutorial Screen 1"
    case WelcomeTutorial2 = "WelcomeTutorial Screen 2"
    case WelcomeTutorial3 = "WelcomeTutorial Screen 3"
    case WelcomeTutorial4 = "WelcomeTutorial Screen 4"
    case PressedGetStarted = "Pressed Get Started"
    //Login
    case CreateAccount = "Create Account Screen"
    case FacebookSignin = "Signed in with Facebook"
    case GoogleSignin = "Signed in with Google"
    case EmailTyped = "Account Create: Typed in email field"
    case PasswordTyped = "Account Create: Typed in password field"
    case EmailCreate = "Pressed \"Create Account\""
    
    //Sign in
    case SigninButton = "User "

    case NewPlaylist = "Created New Playlist"
    case OldPlaylist = "Loaded Existing Playlist"
    case StartPracticeItem = "Started Practicing Item"
    case FinishPracticeItem = "Finished Practicing Item"
    case RatedItem = "Rated Practice Item"
    case PressedImprove = "Pressed Improve"
    case PressedAsk = "Pressed Ask Expert"
    case PressedFeedback = "Pressed Feedback Button"
    case MetrodroneDrawerOpen = "Opened Metrodrone Drawer"
    case MetrodroneDrawerClose = "Closed Metrodrone Drawer"
    case ImprovementChosen = "Chose Area of Improvement"
    case HypothesisChosen = "Chose Hypothesis"
    case RecordStart = "Started Recording"
    case RecordStop = "Stopped Recording"
    
    // Notes
    case OpenNotes = "Opened Item Notes"
}

class ModacityAnalytics: NSObject {
    
    private static func amplitudeLog(_ eventString: String, extraParamName: String? = nil,extraParamValue: AnyHashable? = nil) {
        if (extraParamName != nil) {
            Amplitude.instance().logEvent(eventString, withEventProperties: [extraParamName!: extraParamValue!])
        }
        else {
            Amplitude.instance().logEvent(eventString)
        }
    }
    
    static func LogStringEvent(_ eventString: String, extraParamName: String? = nil, extraParamValue: AnyHashable? = nil) {

        
        if let paramName = extraParamName {
            var value : AnyHashable? = extraParamValue
            if (value == nil) {
                value = "error: nil"
            }
            Analytics.logEvent(eventString, parameters: [paramName: value!])
            FBSDKAppEvents.logEvent(eventString, parameters: [paramName: value!])
            Amplitude.instance().logEvent(eventString, withEventProperties: [paramName: value!])
            Intercom.logEvent(withName: eventString, metaData: [paramName : value!])
            
        } else {
            
            Analytics.logEvent(eventString, parameters: nil)
            FBSDKAppEvents.logEvent(eventString)
            Amplitude.instance().logEvent(eventString)
            Intercom.logEvent(withName: eventString)
        }
    }
    
    static func LogEvent(_ event: ModacityEvent) {
        ModacityAnalytics.LogEvent(event, extraParamName: nil, extraParamValue: nil)
    }
    
    static func LogEvent(_ event: ModacityEvent, extraParamName: String?, extraParamValue: AnyHashable?) {
        LogStringEvent(event.rawValue, extraParamName: extraParamName, extraParamValue: extraParamValue)
    }
}
