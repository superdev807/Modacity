//
//  MusicalFrequencies.swift
//  Metrodrone PitchChange
//
//  Created by Marc Gelfo on 8/28/18.
//  Copyright © 2018 modacity. All rights reserved.
//

import Foundation

extension Int {
    
    /// Calculate frequency from a MIDI Note Number
    ///
    /// - parameter aRef: Reference frequency of A Note (Default: 440Hz)
    ///
    public func midiNoteToFrequency(_ aRef: Double = 440.0) -> Double {
        return Double(self).midiNoteToFrequency(aRef)
    }
}

extension Double {
    /// Calculate frequency from a floating point MIDI Note Number
    ///
    /// - parameter aRef: Reference frequency of A Note (Default: 440Hz)
    ///
    public func midiNoteToFrequency(_ aRef: Double = 440.0) -> Double {
        return pow(2.0, (self - 69.0) / 12.0) * aRef
    }

}
public func frequencyForNote(noteName: String, octave: Int, aRef:Double = 440.0) -> Double {
    // octave ranges from 0 to 7
    if ((octave < 0) || (octave > 7)) {
        ModacityDebugger.debug("frequencyForNote: Octave \(octave) not supported")
        return -1
    }
    
    let noteNum:Int =  midiNote(forNoteName: noteName, octave: octave)
    
    return noteNum.midiNoteToFrequency(aRef)
}

func midiNote(forNoteName: String, octave: Int) -> Int {
    // c0 = midi note 24
    var midiNote: Int = 0
    switch(forNoteName.uppercased()) {
    case "C":
        midiNote = 24
    case "C#":
        midiNote = 25
    case "D":
        midiNote = 26
    case "D#":
        midiNote = 27
    case "E":
        midiNote = 28
    case "F":
        midiNote = 29
    case "F#":
        midiNote = 30
    case "G":
        midiNote = 31
    case "G#":
        midiNote = 32
    case "A":
        midiNote = 33
    case "A#":
        midiNote = 34
    case "B":
        midiNote = 35
    default:
        midiNote = 0
    }
    midiNote += (octave * 12)
    return midiNote
}

