//
//  AmplitudeTracking.swift
//  Modacity
//
//  Created by Marc Gelfo on 3/21/18.
//  Copyright © 2018 crossover. All rights reserved.
//

import Foundation
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



class AmplitudeTracker {
    
    private static func amplitudeLog(_ eventString: String, extraParamName: String? = nil,extraParamValue: AnyHashable? = nil) {
        if (extraParamName != nil) {
            Amplitude.instance().logEvent(eventString, withEventProperties: [extraParamName!: extraParamValue!])
        }
        else {
            Amplitude.instance().logEvent(eventString)
        }
    }
    
    static func LogStringEvent(_ eventString: String, extraParamName: String? = nil, extraParamValue: AnyHashable? = nil) {
        AmplitudeTracker.amplitudeLog(eventString, extraParamName: extraParamName, extraParamValue: extraParamValue)
    }
    
    static func LogEvent(_ event: ModacityEvent) {
        AmplitudeTracker.LogEvent(event, extraParamName: nil, extraParamValue: nil)
    }
    
    static func LogEvent(_ event: ModacityEvent, extraParamName: String?, extraParamValue: AnyHashable?) {
        AmplitudeTracker.amplitudeLog(event.rawValue, extraParamName: extraParamName, extraParamValue: extraParamValue)
    }
}
