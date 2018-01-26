//
//  Speecher.swift
//  ud1038-capstone
//
//  Created by Ezequiel on 11/11/17.
//  Copyright © 2017 Ezequiel. All rights reserved.
//

import Foundation
import AVFoundation

enum Beat : NSString {
    case one = "beat1.mp3"
    case two = "beat2.mp3"
    case three = "beat3.mp3"
}

struct ConfigurationBeat {
    var beat:Beat
    var rate:Float
}

public protocol SpeecherDelegate {
    func didFinish()
}

public class Speecher : NSObject, AVSpeechSynthesizerDelegate {
    
    var delegate:SpeecherDelegate?
    private var textToSpeech:String
    private var utterance:AVSpeechUtterance
    private var synthesizer:AVSpeechSynthesizer
    private var beat:Beat
    private var audioPlayer: AVAudioPlayer?
    private var player:AVAudioPlayer? {
        
        if let audioURL = Bundle.main.url(forResource: self.beat.rawValue.deletingPathExtension, withExtension: self.beat.rawValue.pathExtension) {
            
            do {
                let audioData = try Data(contentsOf:audioURL)
                try self.audioPlayer = AVAudioPlayer(data: audioData)
            } catch {
                return nil
            }
            return self.audioPlayer
        }
        return nil
    }
    
    init(text:String, config:ConfigurationBeat) {
        self.textToSpeech = text
        self.beat = config.beat
        self.utterance = AVSpeechUtterance(string: text)
        self.utterance.voice = AVSpeechSynthesisVoice(language: "en-US")
        self.utterance.rate = config.rate
        self.utterance.volume = 0.95
        self.utterance.pitchMultiplier = 1.0
        self.synthesizer = AVSpeechSynthesizer()
        print(AVSpeechUtteranceMaximumSpeechRate)
        print(AVSpeechUtteranceMinimumSpeechRate)
    }
    
    public var isPlaying : Bool {
        return synthesizer.isSpeaking
    }
    
    public var isPaused : Bool {
        return synthesizer.isPaused
    }
    
    public func play() {
        if textToSpeech.count > 0 {
            self.player?.play()
            synthesizer.speak(self.utterance)
        }
    }
    
    public func pause() {
        if textToSpeech.count > 0 {
            self.player?.stop()
            self.synthesizer.stopSpeaking(at: AVSpeechBoundary.immediate)
            //let boundary = AVSpeechBoundary.immediate
            //synthesizer.pauseSpeaking(at: boundary)
        }
    }
    
    public func stop() {
        self.player?.stop()
        self.synthesizer.stopSpeaking(at: .immediate)
    }
    
    public func speechSynthesizer(_ synthesizer: AVSpeechSynthesizer, didFinish utterance: AVSpeechUtterance) {
        delegate?.didFinish()
    }
    
    deinit {
        self.audioPlayer = nil
    }
    
}
