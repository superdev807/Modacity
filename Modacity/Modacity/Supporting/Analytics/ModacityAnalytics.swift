//
//  ModacityAnalytics.swift
//  Modacity
//
//  Created by Benjamin Chris on 4/11/18.
//  Copyright © 2018 Modacity, Inc. All rights reserved.
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
    
    // Debug for IAP
    case PurchaseFailed = "Purchase Failed"
    
    // Manual practices
    case PressedAddTime = "Pressed Add Time"
    case PressedAddEntry = "Pressed Add Entry"
    case BackFromAddTime = "Back from Add Time"
    
    case PressedDeleteItemTime = "Pressed Delete Item Time"
    case PressedDeleteItemCanceled = "Pressed Delete Item Canceled"
    case PressedDeleteItemConfirmed = "Pressed Delete Item Confirmed"
    
    case PressedEditItemTime = "Pressed Edit Item Time"
    case PressedUpdateTime = "Pressed Update Time"
    case BackFromEditTime = "Back from Edit Time"
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

        let debugPrefix: String = "::::: "
        
        if let paramName = extraParamName {
            var value : AnyHashable? = extraParamValue
            if (value == nil) {
                value = "error: nil"
            }
            
        
            if (!debugPrefix.isEmpty) {
                ModacityDebugger.debug(debugPrefix + "\(eventString), \(paramName) = \(value!)")
            }

            FBSDKAppEvents.logEvent(eventString, parameters: [paramName: value!])
            Amplitude.instance().logEvent(eventString, withEventProperties: [paramName: value!])
            Intercom.logEvent(withName: eventString, metaData: [paramName : value!])
 
        } else {
            if (!debugPrefix.isEmpty) {
                ModacityDebugger.debug(debugPrefix + eventString)
            }
            
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
    
    static func LogEvent(_ event: ModacityEvent, params: [String:Any]?) {
        FBSDKAppEvents.logEvent(event.rawValue, parameters: params)
        Amplitude.instance().logEvent(event.rawValue, withEventProperties: params)
        Intercom.logEvent(withName: event.rawValue, metaData: params ?? [String:Any]())
    }
}
