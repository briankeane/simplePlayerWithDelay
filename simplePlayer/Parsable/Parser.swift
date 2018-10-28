//
//  Parser.swift
//  simplePlayer
//
//  Created by Brian D Keane on 10/22/18.
//  Copyright © 2018 Brian D Keane. All rights reserved.
//

import AVFoundation

class Parser: Parsable {    
    public internal(set) var dataFormat: AVAudioFormat?
    public internal(set) var packets = [(Data, AudioStreamPacketDescription?)]()
    
    /// the maximum of either the packetCount property that is a one-time parsed value from the Audio File Stream Services or the total number of packets received so far (the packets.count)
    public var totalPacketCount: AVAudioPacketCount? {
        guard let _ = dataFormat else {
            return nil
        }
        return max(AVAudioPacketCount(packetCount), AVAudioPacketCount(packets.count))
    }
    
    /// A `UInt64` corresponding to the total frame count parsed by the Audio File Stream Services
    public internal(set) var frameCount: UInt64 = 0
    
    /// A `UInt64` corresponding to the total packet count parsed by the Audio File Stream Services
    public internal(set) var packetCount: UInt64 = 0
    
    /// The `AudioFileStreamID` used by the Audio File Stream Services for converting the binary data into audio packets
    fileprivate var streamID: AudioFileStreamID?
    
    public init() throws {
        // create a context object that we can pass into the AudioFileStreamOpen method that will allow us to access our Parser class instance within static C methods.
        let context = unsafeBitCast(self, to: UnsafeMutableRawPointer.self)
        
        // initialize the Audio File Stream by called the AudioFileStreamOpen() method and pass our context object and callback methods that we can use to be notified anytime there is new data that was parsed.
        guard AudioFileStreamOpen(context, ParserPropertyChangeCallback, ParserPacketCallback, kAudioFileMP3Type, &streamID) == noErr else {
            throw ParserError.streamCouldNotOpen
        }
    }
    
    public func parse(data: Data) throws {
        let streamID = self.streamID!
        let count = data.count
        _ = try data.withUnsafeBytes { (bytes: UnsafePointer<UInt8>) in
            let result = AudioFileStreamParseBytes(streamID, UInt32(count), bytes, [])
            guard result == noErr else {
                throw ParserError.failedToParseBytes(result)
            }
        }
    }
}
