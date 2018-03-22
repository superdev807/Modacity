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



class AmplitudeTracker {
    static func LogEvent(_ event: ModacityEvent) {
        AmplitudeTracker.LogEvent(event, extraParamName: nil, extraParamValue: nil)
    }
    
    static func LogEvent(_ event: ModacityEvent, extraParamName: String?, extraParamValue: AnyHashable?) {
        
        if (extraParamName != nil) {
            Amplitude.instance().logEvent(event.rawValue, withEventProperties: [extraParamName!: extraParamValue!])
        }
        else {
            Amplitude.instance().logEvent(event.rawValue)
        }
        
    }
}
