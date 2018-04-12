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


enum ModacityEvent:String {
    //Launch & basic functionality

    case Launch = "Launched App"
    case Terminate = "Terminated App"
    case ResumeActive = "Resumed Active State"
    case Background = "Backgrounded App"
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
  /*  case foobar = "foobar"
    case foobar = "foobar"
    case foobar = "foobar"
    case foobar = "foobar"
    case foobar = "foobar"

    
    
    case foobar = "foobar"
    case foobar = "foobar"
    case foobar = "foobar"
    case foobar = "foobar"
    case foobar = "foobar"
    case foobar = "foobar"
    case foobar = "foobar"
    case foobar = "foobar"
    */
    
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
//        ModacityAnalytics.amplitudeLog(eventString, extraParamName: extraParamName, extraParamValue: extraParamValue)
        if let paramName = extraParamName {
            Analytics.logEvent(eventString, parameters: [paramName: extraParamValue!])
            FBSDKAppEvents.logEvent(eventString, parameters: [paramName: extraParamValue!])
            Amplitude.instance().logEvent(eventString, withEventProperties: [paramName: extraParamValue!])
        } else {
            Analytics.logEvent(eventString, parameters: nil)
            FBSDKAppEvents.logEvent(eventString)
            Amplitude.instance().logEvent(eventString)
        }
    }
    
    static func LogEvent(_ event: ModacityEvent) {
        ModacityAnalytics.LogEvent(event, extraParamName: nil, extraParamValue: nil)
    }
    
    static func LogEvent(_ event: ModacityEvent, extraParamName: String?, extraParamValue: AnyHashable?) {
        if let paramName = extraParamName {
            Analytics.logEvent(event.rawValue, parameters: [paramName: extraParamValue!])
            FBSDKAppEvents.logEvent(event.rawValue, parameters: [paramName: extraParamValue!])
            Amplitude.instance().logEvent(event.rawValue, withEventProperties: [paramName: extraParamValue!])
        } else {
            Analytics.logEvent(event.rawValue, parameters: nil)
            FBSDKAppEvents.logEvent(event.rawValue)
            Amplitude.instance().logEvent(event.rawValue)
        }
//=======
//        ModacityAnalytics.amplitudeLog(event.rawValue, extraParamName: extraParamName, extraParamValue: extraParamValue)
//>>>>>>> 26ebd2c8fe63718fa635d1c64195f90ec132b1dd:Modacity/Modacity/Model/AmplitudeTracking.swift
    }
}
