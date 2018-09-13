//
//  GenerateAudio.swift
//  Metrodrone PitchChange
//
//  Created by Marc Gelfo on 8/27/18.
//  Copyright © 2018 modacity. All rights reserved.
//

import Foundation
import AVFoundation

private let RMS = Double(0.707)

enum WaveType { case Sine, Square, Triangle, Sawtooth }


func fillBuffer(buffer: AVAudioPCMBuffer, frequency: Double, seconds: Double, sampleRate: Double, waveType: WaveType = .Triangle) {
    /* fills buffer with waveform
     params:
        buffer - the buffer to fill
        frequency - what frequency
        sampleRate - samples per second
        seconds - number of seconds to create
        wavetype - sine, square, triangle, sawtooth
     */
    
    let samples:Int = Int(seconds * sampleRate)
    var waveFunc: ((Double) -> Double)
    switch(waveType) {
    case .Sine:
        waveFunc = sine
        break
    case .Square:
        waveFunc = square
        break
    case .Triangle:
        waveFunc = triangle
        break
    case .Sawtooth:
        waveFunc = sawtooth
        break
    }

    var theta: Double = 0;
    let theta_increment:Double =
        2.0 * Double.pi * frequency / sampleRate;

    for i in 0..<samples {

        theta += theta_increment;
        if (theta > 2.0 * Double.pi)
        {
            theta -= 2.0 * Double.pi;
        }
        buffer.floatChannelData!.pointee[i] = Float(waveFunc(theta))
    }
}


func mixBuffer(buffer: AVAudioPCMBuffer, frequency: Double, seconds: Double, sampleRate: Double, waveType: WaveType = .Triangle) {
    let samples:Int = Int(seconds * sampleRate)
    var waveFunc: ((Double) -> Double)
    switch(waveType) {
    case .Sine:
        waveFunc = sine
        break
    case .Square:
        waveFunc = square
        break
    case .Triangle:
        waveFunc = triangle
        break
    case .Sawtooth:
        waveFunc = sawtooth
        break
    }
    
    var theta: Double = 0;
    let theta_increment:Double =
        2.0 * Double.pi * frequency / sampleRate;
    
    for i in 0..<samples {
        theta += theta_increment;
        if (theta > 2.0 * Double.pi)
        {
            theta -= 2.0 * Double.pi;
        }
        buffer.floatChannelData!.pointee[i] *= 0.5
        buffer.floatChannelData!.pointee[i] += (Float(waveFunc(theta)) * 0.5)
    }
}

func repeatableDuration(frequency: Double, maxDuration: Double) -> Double {
    // 440 cycles per second = 0.002272 seconds per cycle (1/ frequency)
    let singleCycle:Double = 1.0/frequency
    let numCycles:Double = (maxDuration/singleCycle).rounded(.down)
    let duration = numCycles * singleCycle
    return duration
}

func sine(phase: Double) -> Double {
    return sin(phase)
}

func square(phase: Double) -> Double {
    var amplitude = Double(0.0)
    if sin(phase) > 0 {
        amplitude = RMS
    } else {
        amplitude = -RMS
    }
    return amplitude
}

func triangle(phase: Double) -> Double {
    var amplitude = Double(0.0)
    amplitude = 2 * phase / Double(2.0*Double.pi) // 0.0 ... 2.0
    if amplitude > 1.0 {
        amplitude = 2.0 - amplitude
    }
    amplitude = amplitude * 2.0 - 1.0 // -1.0 ... 1.0
    return amplitude
}

func sawtooth(phase: Double) -> Double {
    var amplitude = Double(0.0)
    amplitude = phase / Double(2*Double.pi) // 0.0 ... 1.0
    amplitude = amplitude * 2.0 - 1.0 // -1.0 ... 1.0
    return amplitude
}

func reverseSawtooth(phase: Double) -> Double {
    var amplitude = Double(0.0)
    amplitude = (2 * Double.pi - phase) / Double(2*Double.pi) // 0.0 ... 1.0
    amplitude = amplitude * 2.0 - 1.0 // -1.0 ... 1.0
    return amplitude
}

func invert(amplitude: Double) -> Double {
    return amplitude * -1.0
}
