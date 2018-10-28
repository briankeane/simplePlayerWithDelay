//
//  ParsableProtocol.swift
//  simplePlayer
//
//  Created by Brian D Keane on 10/22/18.
//  Copyright © 2018 Brian D Keane. All rights reserved.
//

import AVFoundation

public protocol Parsable: class {
    
    // MARK: - Properties
    
    /// the format of the audio packets
    var dataFormat: AVAudioFormat? { get }
    
    /// the total duration of the file in seconds
    var duration: TimeInterval? { get }
    
    /// indicates whether all the packets have been parsed
    var isParsingComplete: Bool { get }
    
    /// Each duple contains a chunk of binary audio data (Data) and an optional packet description (AudioStreamPacketDescription) if it is a compressed format
    var packets: [(Data, AudioStreamPacketDescription?)] { get }
    
    /// the total amount of frames in the entire audio file.
    var totalFrameCount: AVAudioFrameCount? { get }
    
    /// the total amount of packets in the entire audio file.
    var totalPacketCount: AVAudioPacketCount? { get }
    
    // MARK: - Methods
    
    /// takes in binary audio data and progressively parses it to provide us the properties listed above.
    func parse(data: Data) throws
    
    /// provides a frame offset given a time in seconds (required for handling seek operations)
    func frameOffset(forTime time: TimeInterval) -> AVAudioFramePosition?
    
    /// provides a packet offset given a frame (required for handling seek operations)
    func packetOffset(forFrame frame: AVAudioFramePosition) -> AVAudioPacketCount?
    
    /// provides a time offset given a frame (required for handling seek operations)
    func timeOffset(forFrame frame: AVAudioFrameCount) -> TimeInterval?
}

extension Parsable {
    
    public var duration:TimeInterval? {
        guard let sampleRate = dataFormat?.sampleRate else {
            return nil
        }
        
        guard let totalFrameCount = totalFrameCount else {
            return nil
        }
        
        return TimeInterval(totalFrameCount) / TimeInterval(sampleRate)
    }
    
    public var totalFrameCount:AVAudioFrameCount? {
        guard let framesPerPacket = dataFormat?.streamDescription.pointee.mFramesPerPacket else {
            return nil
        }
        
        guard let totalPacketCount = totalFrameCount else {
            return nil
        }
        
        return AVAudioFrameCount(totalPacketCount) * AVAudioFrameCount(framesPerPacket)
    }
    
    public var isParsingComplete:Bool {
        guard let totalPacketCount = totalPacketCount else {
            return false
        }
        return packets.count == totalPacketCount
    }
    
    public func frameOffset(forTime time:TimeInterval) -> AVAudioFramePosition? {
        guard let _ = dataFormat?.streamDescription.pointee,
            let frameCount = totalFrameCount,
            let duration = duration else {
                return nil
        }
        
        let ratio = time/duration
        return AVAudioFramePosition(Double(frameCount) * ratio)
    }
    
    public func packetOffset(forFrame frame:AVAudioFramePosition) -> AVAudioPacketCount? {
        guard let framesPerPacket = dataFormat?.streamDescription.pointee.mFramesPerPacket else {
            return nil
        }
        return AVAudioPacketCount(frame) / AVAudioPacketCount(framesPerPacket)
    }
    
    public func timeOffset(forFrame frame:AVAudioFrameCount) -> TimeInterval? {
        guard let _ = dataFormat?.streamDescription.pointee,
            let frameCount = totalFrameCount,
            let duration = duration else {
                return nil
        }
        return TimeInterval(frame) / TimeInterval(frameCount) * duration
    }
}
