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

public enum ModacityEvent:String {
    case Launch = "Launched App"
    case Terminate = "Terminated App"
    case ResumeActive = "Resumed Active State"
    case Background = "Backgrounded App"
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
    }
}
