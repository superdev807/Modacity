//
//  Metronome.swift
//  MetronomeIdeaOnAVAudioEngine
//
//  By Marc Gelfo

import AVFoundation

class Metrodrone {
    
    private var audioPlayerNode:AVAudioPlayerNode
    private var audioFileMainClick:AVAudioFile
    private var audioFileSubClick:AVAudioFile
    private var audioEngine:AVAudioEngine
    var decay: Float = 0.5
    
    init (mainClickFile: URL, subClickFile: URL? = nil) {
        
        let audioSession = AVAudioSession.sharedInstance()
        do {
            try audioSession.setCategory(AVAudioSessionCategoryPlayAndRecord)
            try audioSession.overrideOutputAudioPort(AVAudioSessionPortOverride.speaker)
        } catch {
            print("Setting category to AVAudioSessionCategoryPlayback failed.")
        }
        
        audioFileMainClick = try! AVAudioFile(forReading: mainClickFile)
        audioFileSubClick = try! AVAudioFile(forReading: subClickFile ?? mainClickFile)
        
        audioPlayerNode = AVAudioPlayerNode()
        
        audioEngine = AVAudioEngine()
        audioEngine.attach(self.audioPlayerNode)
        
    /*    print("Vol: " + String(audioPlayerNode.volume))
        audioPlayerNode.volume = 1.0
        
        print("audioEngine output: " + String(audioEngine.mainMixerNode.outputVolume))
        audioEngine.mainMixerNode.outputVolume = 1.0
 */
        
        audioEngine.connect(audioPlayerNode, to: audioEngine.mainMixerNode, format: audioFileMainClick.processingFormat)
        try! audioEngine.start()
        
    }
    
    func loadDrone(droneMain: URL, droneSub: URL) {
        audioFileMainClick = try! AVAudioFile(forReading: droneMain)
        audioFileSubClick = try! AVAudioFile(forReading: droneSub)
    }
    
    
    private func generateSubdivided(bpm: Double, subdivisions: Int, droneRatio: Float) -> AVAudioPCMBuffer {
        
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
        audioFileMainClick.framePosition = 0
        let audioFormat = audioFileMainClick.processingFormat
        let duration = AVAudioFrameCount(audioFileMainClick.length)
        
        let bufferLoopWave = AVAudioPCMBuffer(pcmFormat: audioFormat, frameCapacity: duration)
        try! audioFileMainClick.read(into: bufferLoopWave!)
        bufferLoopWave?.frameLength = duration
        
        return bufferLoopWave!
    }
    
    func playUntimed() {
        let buffer = generateUntimed()
        if audioPlayerNode.isPlaying {
            audioPlayerNode.scheduleBuffer(buffer, at: nil, options: .interrupts, completionHandler: nil)
        } else {
            self.audioPlayerNode.play()
        }
        
        self.audioPlayerNode.scheduleBuffer(buffer, at: nil, options: .loops, completionHandler: nil)
        
    }
    
    func play(bpm: Double, ratio: Float, subdivision: Int) {
        
        let buffer = generateSubdivided(bpm: bpm, subdivisions: subdivision, droneRatio: ratio)
        
        if audioPlayerNode.isPlaying {
            audioPlayerNode.scheduleBuffer(buffer, at: nil, options: .interruptsAtLoop, completionHandler: nil)
        } else {
            self.audioPlayerNode.play()
        }
        
        self.audioPlayerNode.scheduleBuffer(buffer, at: nil, options: .loops, completionHandler: nil)
        
    }
    
    func stop() {
        audioPlayerNode.stop()
    }
    
}
