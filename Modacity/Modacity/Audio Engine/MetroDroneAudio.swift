//
//  Metronome.swift
//  MetronomeIdeaOnAVAudioEngine
//
//  By Marc Gelfo
//  Copyright © 2018 Modacity, Inc. All rights reserved.

import AVFoundation

class MetroDroneAudio {
    
    private var droneAudioEngine: AVAudioEngine
    private var dronePlayerNode:AVAudioPlayerNode
    private var clickPlayerNode:AVAudioPlayerNode
    private var audioFileMainClick:AVAudioFile
    private var audioFileSubClick:AVAudioFile
    
    //var clickOnly: Bool = true
    var decay: Float = 0.5
    var isDroning: Bool = false
    
    init (mainClickFile: URL, subClickFile: URL? = nil) {
        
        droneAudioEngine = AVAudioEngine()
        audioFileMainClick = try! AVAudioFile(forReading: mainClickFile)
        audioFileSubClick = try! AVAudioFile(forReading: subClickFile ?? mainClickFile)
        dronePlayerNode = AVAudioPlayerNode()
        clickPlayerNode = AVAudioPlayerNode()
        
        connectWithEngine()
        
    }
    
    
    func connectWithEngine() {
        let format = audioFileMainClick.processingFormat
        droneAudioEngine.attach(self.clickPlayerNode)
        droneAudioEngine.connect(self.clickPlayerNode, to: droneAudioEngine.mainMixerNode, format: format)
        
        droneAudioEngine.attach(self.dronePlayerNode)
        droneAudioEngine.connect(dronePlayerNode, to: droneAudioEngine.mainMixerNode, format: format)
        
        do {
            try droneAudioEngine.start()
        } catch let error {
            print("audio engine start error : \(error)")
        }
    }
    
    func checkAndRestartEngine() {
        print("Engine Status: \(droneAudioEngine.isRunning ? "Running" : "Not Running")")
        
        if !droneAudioEngine.isRunning {
            do {
                droneAudioEngine.prepare()
                try droneAudioEngine.start()
            } catch let error {
                print("retart error \(error)")
            }
            
            
        }
        
    }
    
    private func generateDronePulse(frameLength: AVAudioFrameCount, decayPoint: Float, droneType: WaveType = .Triangle) -> AVAudioPCMBuffer {
        let audioFormat = audioFileMainClick.processingFormat
        let bufferDronePulse = AVAudioPCMBuffer(pcmFormat: audioFormat, frameCapacity: frameLength)
        
        let freq: Double = frequencyForNote(noteName: MetrodroneParameters.instance.currNote, octave: MetrodroneParameters.instance.currOctave, aRef: Double(MetrodroneParameters.instance.tuningStandardA))
        let secduration: Double = Double(frameLength)/audioFormat.sampleRate
        
        fillBuffer(buffer: bufferDronePulse!, frequency: freq, seconds: secduration, sampleRate: audioFormat.sampleRate, waveType: droneType)
        
        //mixBuffer(buffer: bufferDronePulse!, frequency: freq * 1.5, seconds: secduration, sampleRate: audioFormat.sampleRate, waveType: droneType)
        
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
        
        let start = Date()
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
            let bufferDroneMain = generateDronePulse(frameLength: subdivisionLength, decayPoint: droneRatio, droneType: .Triangle)
            // this is only required if we do a different tone for subdivision
//            var bufferDroneSub: AVAudioPCMBuffer?
            /*if (subdivisions > 1) {
                bufferDroneSub = generateDronePulse(frameLength: subdivisionLength, decayPoint: droneRatio, droneType: .Triangle)
            }
 */
            
            let droneMult: Float = MetrodroneParameters.instance.ratioDroneToClick
            let clickMult: Float = MetrodroneParameters.instance.ratioDroneToClick - 1.0
            var maxPoint: Float = 0.0
            for index in 0..<Int(subdivisionLength) {
                let droneData: Float = bufferDroneMain.floatChannelData!.pointee[index]
                let clickData: Float = (bufferMainClick?.floatChannelData!.pointee[index])!
                let newData = (droneData * droneMult) + (clickData * clickMult)
                if (newData > maxPoint) {
                    maxPoint = newData // for normalizing
                }
                bufferMainClick?.floatChannelData!.pointee[index] = newData
                
 //no need to do this it will happen in normalization - delete this comment once proven
                /*
                 if (subdivisions > 1) {
// only for separate subdvision sound
 //                 let droneSubData: Float = bufferDroneSub!.floatChannelData!.pointee[index]
                    bufferSubClick?.floatChannelData!.pointee[index] = newData
                }
 */

            }

            let mult = 1.0/maxPoint
            for index in 0..<Int(subdivisionLength) {
                let clickData: Float = (bufferMainClick?.floatChannelData!.pointee[index])!
                let newData = clickData * mult
                bufferMainClick?.floatChannelData!.pointee[index] = newData
                
                if (subdivisions > 1) {
                    //let subData: Float = (bufferSubClick?.floatChannelData!.pointee[index])!
                    bufferSubClick?.floatChannelData!.pointee[index] = newData
                }
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
        
        ModacityDebugger.debug("Overall time to generate click - \(Date().timeIntervalSince1970 - start.timeIntervalSince1970)s")
        return bufferBeat!
    }
    
    private func generateSustaining() -> AVAudioPCMBuffer {

        let audioFormat = audioFileMainClick.processingFormat
        
        let freq: Double = frequencyForNote(noteName: MetrodroneParameters.instance.currNote, octave: MetrodroneParameters.instance.currOctave, aRef: Double(MetrodroneParameters.instance.tuningStandardA))
        let secduration = repeatableDuration(frequency: Double(freq), maxDuration: 0.10)
        let frames: AVAudioFrameCount = AVAudioFrameCount(secduration * audioFormat.sampleRate)
        let bufferLoopWave = AVAudioPCMBuffer(pcmFormat: audioFormat, frameCapacity: frames)
        
        fillBuffer(buffer: bufferLoopWave!, frequency: freq, seconds: secduration, sampleRate: audioFormat.sampleRate)
/*        for i in 0...4 {
        mixBuffer(buffer: bufferLoopWave!, frequency: freq * (1.5 * Double(i)), seconds: secduration, sampleRate: audioFormat.sampleRate)
        }
 */
        bufferLoopWave?.frameLength = AVAudioFrameCount(frames)

        return bufferLoopWave!
    }
    
    func playInfiniteDrone(withLooping: Bool = true) {
        
        checkAndRestartEngine()
        
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
        
        checkAndRestartEngine()
        
        fadeAudioOut()
        
       // DispatchQueue.main.async {
            self.dronePlayerNode.stop()
         //   self.dronePlayerNode.volume = 1.0
        //}
        self.isDroning = false
    }
    
    func playSingleClick() {

        checkAndRestartEngine()
        
        if (!clickPlayerNode.isPlaying) {
            self.clickPlayerNode.play()
        }
        clickPlayerNode.scheduleFile(audioFileMainClick, at: nil, completionHandler: nil)
    }
    
    
    // play timed metrodrone
    func playPulsing(bpm: Double, includeDrone: Bool, ratio: Float, subdivision: Int) {
        
        checkAndRestartEngine()
        
        let bufferClick = generateSubdividedClick(bpm: bpm, subdivisions: subdivision, includeDrone: includeDrone, droneRatio: ratio)
        
        if clickPlayerNode.isPlaying {
            clickPlayerNode.scheduleBuffer(bufferClick, at: nil, options: .interruptsAtLoop, completionHandler: nil)
        } else {
            self.clickPlayerNode.play()
        }
        
        self.clickPlayerNode.scheduleBuffer(bufferClick, at: nil, options: .loops, completionHandler: nil)
        
    }
    
    func stopPulsing() {
        
        checkAndRestartEngine()
        clickPlayerNode.stop()
        
    }
    
    func stop() {
        stopPulsing()
        stopInfiniteDrone()
    }
    
}
