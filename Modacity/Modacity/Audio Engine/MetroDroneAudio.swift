//
//  Metronome.swift
//  MetronomeIdeaOnAVAudioEngine
//
//  By Marc Gelfo

import AVFoundation

class MetroDroneAudio {
    
    private var dronePlayerNode:AVAudioPlayerNode
    private var clickPlayerNode:AVAudioPlayerNode
    private var audioFileDrone:AVAudioFile?
    private var audioFileMainClick:AVAudioFile
    private var audioFileSubClick:AVAudioFile
    
    //var clickOnly: Bool = true
    
    var decay: Float = 0.5
    
    init (mainClickFile: URL, subClickFile: URL? = nil) {
        
        audioFileMainClick = try! AVAudioFile(forReading: mainClickFile)
        audioFileSubClick = try! AVAudioFile(forReading: subClickFile ?? mainClickFile)
        dronePlayerNode = AVAudioPlayerNode()
        clickPlayerNode = AVAudioPlayerNode()
        
        connectWithEngine()
    }
    
    func loadDrone(droneAudio: URL) {
        audioFileDrone = try! AVAudioFile(forReading: droneAudio)
    }
    
    func connectWithEngine() {
        ModacityAudioEngine.engine.attachAudio(node: self.clickPlayerNode)
        ModacityAudioEngine.engine.connectAudio(node: clickPlayerNode, format: audioFileMainClick.processingFormat)
        
        ModacityAudioEngine.engine.attachAudio(node: self.dronePlayerNode)
        ModacityAudioEngine.engine.connectAudio(node: dronePlayerNode, format: audioFileMainClick.processingFormat)
        
        ModacityAudioEngine.engine.startEngine()
        ModacityDebugger.debug("Engine started")
    }
    
    private func generateSubdividedDrone(bpm: Double, subdivisions: Int, droneRatio: Float) -> AVAudioPCMBuffer {
        
        if (audioFileDrone == nil) {
            ModacityDebugger.debug("error - called drone subdivide with no audio file")
            return AVAudioPCMBuffer()
        }
        
        audioFileDrone!.framePosition = 0
        let audioFormat = audioFileMainClick.processingFormat
        
        var beatLength = AVAudioFrameCount(audioFormat.sampleRate * 60 / bpm)
        let subdivisionLength = beatLength / AVAudioFrameCount(subdivisions)
        beatLength = subdivisionLength * AVAudioFrameCount(subdivisions) // just in case it wasn't evenly divided
        
        
        let bufferDrone = AVAudioPCMBuffer(pcmFormat: audioFormat, frameCapacity: subdivisionLength)
        try! audioFileDrone!.read(into: bufferDrone!)
        bufferDrone?.frameLength = subdivisionLength
        
        
        // apply decay & ratio to clicks
        let silenceStartFrame = AVAudioFrameCount(droneRatio * Float(subdivisionLength)) // where silence starts
        let droneDuration = silenceStartFrame
        let decayPercentage:Float = decay
        let decaySamples = AVAudioFrameCount(decayPercentage * Float(droneDuration))
        let startSample = silenceStartFrame - decaySamples
        
        // decay the samples
        let lastNonZeroSample = Float(decaySamples - 1)
        for i in 0..<decaySamples {
            let index = Int(startSample + i)
            let multiplier:Float = (lastNonZeroSample - Float(i)) / lastNonZeroSample
            bufferDrone?.floatChannelData!.pointee[index] *= multiplier
        }
        
        // zero the rest
        for i in silenceStartFrame..<subdivisionLength {
            bufferDrone?.floatChannelData!.pointee[Int(i)] = 0.0
        }
        
        let bufferBeat = AVAudioPCMBuffer(pcmFormat: audioFormat, frameCapacity: beatLength)
        bufferBeat?.frameLength = beatLength
        
        // don't forget if we have two or more channels then we have to multiply memory pointee at channels count
        let droneArray = Array(
            UnsafeBufferPointer(start: bufferDrone?.floatChannelData?[0],
                                count:Int(audioFormat.channelCount) * Int(subdivisionLength))
        )
        
        var beatArray = Array<Float>()
        
        // works whether subdivisoins or not.
        for _ in 0..<subdivisions {
            beatArray.append(contentsOf: droneArray)
        }
        
        bufferBeat?.floatChannelData?.pointee.assign(from: beatArray,
                                                     count: Int(audioFormat.channelCount) * Int(bufferBeat!.frameLength))
        
        return bufferBeat!
    }
    
    private func generateSubdividedClick(bpm: Double, subdivisions: Int, droneRatio: Float) -> AVAudioPCMBuffer {
        
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
        
        /*
         // apply decay & ratio to clicks
         let silenceStartFrame = AVAudioFrameCount(droneRatio * Float(subdivisionLength)) // where silence starts
         let droneDuration = silenceStartFrame
         let decayPercentage:Float = decay
         let decaySamples = AVAudioFrameCount(decayPercentage * Float(droneDuration))
         let startSample = silenceStartFrame - decaySamples
         
         // decay the samples
         let lastNonZeroSample = Float(decaySamples - 1)
         for i in 0..<decaySamples {
         let index = Int(startSample + i)
         let multiplier:Float = (lastNonZeroSample - Float(i)) / lastNonZeroSample
         bufferMainClick?.floatChannelData!.pointee[index] *= multiplier
         if (subdivisions > 1) {
         bufferSubClick?.floatChannelData!.pointee[index] *= multiplier
         }
         }
         
         // zero the rest
         for i in silenceStartFrame..<subdivisionLength {
         bufferMainClick?.floatChannelData!.pointee[Int(i)] = 0.0
         if (subdivisions > 1) {
         bufferSubClick?.floatChannelData!.pointee[Int(i)] = 0.0
         }
         }
         */
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
    
    private func generateUntimed() -> AVAudioPCMBuffer {
        audioFileDrone!.framePosition = 0
        let audioFormat = audioFileDrone!.processingFormat
        let duration = AVAudioFrameCount(audioFileDrone!.length)
        
        let bufferLoopWave = AVAudioPCMBuffer(pcmFormat: audioFormat, frameCapacity: duration)
        try! audioFileDrone!.read(into: bufferLoopWave!)
        bufferLoopWave?.frameLength = duration
        
        return bufferLoopWave!
    }
    
    func playUntimed(withLooping: Bool = true) {
        let buffer = generateUntimed()
        if dronePlayerNode.isPlaying {
            dronePlayerNode.scheduleBuffer(buffer, at: nil, options: .interrupts, completionHandler: nil)
        } else {
            self.dronePlayerNode.play()
        }
        
        let option: AVAudioPlayerNodeBufferOptions = (withLooping) ? .loops : .interrupts
        
        self.dronePlayerNode.scheduleBuffer(buffer, at: nil, options: option, completionHandler: nil)
    }
    
    func playClick() {

        if (!dronePlayerNode.isPlaying) {
            self.dronePlayerNode.play()
        }
        dronePlayerNode.scheduleFile(audioFileMainClick, at: nil, completionHandler: nil)
    }
    
    
    // play timed metrodrone
    func play(bpm: Double, ratio: Float, subdivision: Int) {
        /*
         let frameCount: AVAudioFrameCount = AVAudioFrameCount(audioFile.length)
         player.prepareWithFrameCount(frameCount)
         */
        
       // let startTime: AVAudioTime = dronePlayerNode.lastRenderTime!
        
        let bufferClick = generateSubdividedClick(bpm: bpm, subdivisions: subdivision, droneRatio: ratio)

        
        let bufferDrone = generateSubdividedDrone(bpm: bpm, subdivisions: subdivision, droneRatio: ratio)
        
        if dronePlayerNode.isPlaying {
            dronePlayerNode.scheduleBuffer(bufferDrone, at: nil, options: .interruptsAtLoop, completionHandler: nil)
        } else {
            self.dronePlayerNode.play()
        }
        
        if clickPlayerNode.isPlaying {
            //clickPlayerNode.stop()
            clickPlayerNode.scheduleBuffer(bufferClick, at: nil, options: .interruptsAtLoop, completionHandler: nil)
        } else {
            self.clickPlayerNode.play()
        }
        
        self.clickPlayerNode.scheduleBuffer(bufferClick, at: nil, options: .loops, completionHandler: nil)

        self.dronePlayerNode.scheduleBuffer(bufferDrone, at: nil, options: .loops, completionHandler: nil)

    }
    
    func stop() {
        
        clickPlayerNode.stop()
        
        dronePlayerNode.stop()
        
        
        
        //        ModacityAudioEngine.engine.audioEngine.detach(audioPlayerNode)
    }
    
}
