//
//  Metronome.swift
//  MetronomeIdeaOnAVAudioEngine
//
//  By Marc Gelfo
//  Copyright © 2018 Modacity, Inc. All rights reserved.

import AVFoundation

class MetroDroneAudio {
    
    private var dronePlayerNode:AVAudioPlayerNode
    private var clickPlayerNode:AVAudioPlayerNode
    private var audioFileMainClick:AVAudioFile
    private var audioFileSubClick:AVAudioFile
    
    
    //var clickOnly: Bool = true
    var decay: Float = 0.5
    var isDroning: Bool = false
    
    init (mainClickFile: URL, subClickFile: URL? = nil) {
        
        audioFileMainClick = try! AVAudioFile(forReading: mainClickFile)
        audioFileSubClick = try! AVAudioFile(forReading: subClickFile ?? mainClickFile)
        dronePlayerNode = AVAudioPlayerNode()
        clickPlayerNode = AVAudioPlayerNode()
        
        connectWithEngine()
    }


    func connectWithEngine() {
        let format = audioFileMainClick.processingFormat
        ModacityAudioEngine.engine.attachAudio(node: self.clickPlayerNode)
        ModacityAudioEngine.engine.connectAudio(node: clickPlayerNode, format: format)
        
        ModacityAudioEngine.engine.attachAudio(node: self.dronePlayerNode)
        ModacityAudioEngine.engine.connectAudio(node: dronePlayerNode, format: format)
        
        ModacityAudioEngine.engine.startEngine()
        ModacityDebugger.debug("Engine started")
    }
    
    
    private func generateDronePulse(frameLength: AVAudioFrameCount, decayPoint: Float) -> AVAudioPCMBuffer {
        let audioFormat = audioFileMainClick.processingFormat
        let bufferDronePulse = AVAudioPCMBuffer(pcmFormat: audioFormat, frameCapacity: frameLength)
        
        let freq: Double = frequencyForNote(noteName: MetrodroneParameters.instance.currNote, octave: MetrodroneParameters.instance.currOctave, aRef: Double(MetrodroneParameters.instance.tuningStandardA))
        let secduration: Double = Double(frameLength)/audioFormat.sampleRate
        
        fillBuffer(buffer: bufferDronePulse!, frequency: freq, seconds: secduration, sampleRate: audioFormat.sampleRate)
        
        bufferDronePulse?.frameLength = frameLength
        
        
        // apply decay & ratio to drone pulses
        let silenceStartFrame = AVAudioFrameCount(decayPoint * Float(frameLength)) // where silence starts
        let droneDuration = silenceStartFrame
        let decayPercentage:Float = decay
        let decaySamples = AVAudioFrameCount(decayPercentage * Float(droneDuration))
        let startSample = silenceStartFrame - decaySamples
        
        // decay the samples
        let lastNonZeroSample = Float(decaySamples - 1)
        for i in 0..<decaySamples {
            let index = Int(startSample + i)
            let multiplier:Float = (lastNonZeroSample - Float(i)) / lastNonZeroSample
            bufferDronePulse?.floatChannelData!.pointee[index] *= multiplier
        }
        
        // zero the rest
        for i in silenceStartFrame..<frameLength {
            bufferDronePulse?.floatChannelData!.pointee[Int(i)] = 0.0
        }
        
        return bufferDronePulse!
    }
    
    private func generateSubdividedClick(bpm: Double, subdivisions: Int, includeDrone: Bool, droneRatio: Float) -> AVAudioPCMBuffer {
        
        audioFileMainClick.framePosition = 0
        audioFileSubClick.framePosition = 0
        
        let audioFormat = audioFileMainClick.processingFormat
        
        var beatLength = AVAudioFrameCount(audioFormat.sampleRate * 60 / bpm)
        let subdivisionLength = beatLength / AVAudioFrameCount(subdivisions)
        beatLength = subdivisionLength * AVAudioFrameCount(subdivisions) // just in case it wasn't evenly divided
        
        let bufferMainClick = AVAudioPCMBuffer(pcmFormat: audioFormat, frameCapacity: subdivisionLength)
        try! audioFileMainClick.read(into: bufferMainClick!)
        bufferMainClick?.frameLength = subdivisionLength
        
        let bufferSubClick = AVAudioPCMBuffer(pcmFormat: audioFormat, frameCapacity: subdivisionLength)
        if (subdivisions > 1) {
            try! audioFileSubClick.read(into: bufferSubClick!)
            bufferSubClick?.frameLength = subdivisionLength
        }
 
        if (includeDrone) {
            let bufferDronePulse = generateDronePulse(frameLength: subdivisionLength, decayPoint: droneRatio)
            
            for index in 0..<Int(subdivisionLength) {
                let droneData: Float = bufferDronePulse.floatChannelData!.pointee[index]
                bufferMainClick?.floatChannelData!.pointee[index] += droneData
                bufferSubClick?.floatChannelData!.pointee[index] += droneData
            }
        }
        
        let bufferBeat = AVAudioPCMBuffer(pcmFormat: audioFormat, frameCapacity: beatLength)
        bufferBeat?.frameLength = beatLength
        
        // don't forget if we have two or more channels then we have to multiply memory pointee at channels count
        let accentedClickArray = Array(
            UnsafeBufferPointer(start: bufferMainClick?.floatChannelData?[0],
                                count:Int(audioFormat.channelCount) * Int(subdivisionLength))
        )
        let subClickArray = Array(
            UnsafeBufferPointer(start: bufferSubClick?.floatChannelData?[0],
                                count:Int(audioFormat.channelCount) * Int(subdivisionLength))
        )
        
        var beatArray = Array<Float>()
        // one time for first beat
        beatArray.append(contentsOf: accentedClickArray)
        
        // if subdivisions
        
        for _ in 1..<subdivisions {
            beatArray.append(contentsOf: subClickArray)
        }
        
        bufferBeat?.floatChannelData?.pointee.assign(from: beatArray,
                                                     count: Int(audioFormat.channelCount) * Int(bufferBeat!.frameLength))
        
        return bufferBeat!
    }
    
    private func generateSustaining() -> AVAudioPCMBuffer {

        let audioFormat = audioFileMainClick.processingFormat
        
        let freq: Double = frequencyForNote(noteName: MetrodroneParameters.instance.currNote, octave: MetrodroneParameters.instance.currOctave, aRef: Double(MetrodroneParameters.instance.tuningStandardA))
        let secduration = repeatableDuration(frequency: Double(freq), maxDuration: 0.10)
        let frames: AVAudioFrameCount = AVAudioFrameCount(secduration * audioFormat.sampleRate)
        let bufferLoopWave = AVAudioPCMBuffer(pcmFormat: audioFormat, frameCapacity: frames)
        
        fillBuffer(buffer: bufferLoopWave!, frequency: freq, seconds: secduration, sampleRate: audioFormat.sampleRate)
        
        bufferLoopWave?.frameLength = AVAudioFrameCount(frames)

        return bufferLoopWave!
    }
    
    func playInfiniteDrone(withLooping: Bool = true) {
        let buffer = generateSustaining()
        
        let option: AVAudioPlayerNodeBufferOptions = (withLooping) ? .loops : .interrupts
        
        fadeAudioOut()
        
        if self.dronePlayerNode.isPlaying {
            self.dronePlayerNode.scheduleBuffer(buffer, at: nil, options: .interrupts, completionHandler: nil)
        } else {
            self.dronePlayerNode.play()
            
        }
        self.dronePlayerNode.scheduleBuffer(buffer, at: nil, options: option, completionHandler: nil)
        fadeAudioIn()
        self.isDroning = true
    }
    
    func fadeAudioIn() {
        let steps = 1000
        for i in 0...steps {
            self.dronePlayerNode.volume = Float(i)/Float(steps)
        }
    }
    func fadeAudioOut() {
        let steps = 1000
        for i in 0...steps {
            self.dronePlayerNode.volume = Float(steps - i)/Float(steps)
        }
    }
    
    func stopInfiniteDrone() {
        fadeAudioOut()
        
       // DispatchQueue.main.async {
            self.dronePlayerNode.stop()
         //   self.dronePlayerNode.volume = 1.0
        //}
        self.isDroning = false
    }
    
    func playSingleClick() {

        if (!clickPlayerNode.isPlaying) {
            self.clickPlayerNode.play()
        }
        clickPlayerNode.scheduleFile(audioFileMainClick, at: nil, completionHandler: nil)
    }
    
    
    // play timed metrodrone
    func playPulsing(bpm: Double, includeDrone: Bool, ratio: Float, subdivision: Int) {
        let bufferClick = generateSubdividedClick(bpm: bpm, subdivisions: subdivision, includeDrone: includeDrone, droneRatio: ratio)
        
        if clickPlayerNode.isPlaying {
            clickPlayerNode.scheduleBuffer(bufferClick, at: nil, options: .interruptsAtLoop, completionHandler: nil)
        } else {
            self.clickPlayerNode.play()
        }
        
        self.clickPlayerNode.scheduleBuffer(bufferClick, at: nil, options: .loops, completionHandler: nil)
        
    }
    
    func stopPulsing() {
        clickPlayerNode.stop()
    }
    
    func stop() {
        stopPulsing()
        stopInfiniteDrone()
    }
    
}
