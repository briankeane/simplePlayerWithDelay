//
//  Reader.swift
//  simplePlayer
//
//  Created by Brian D Keane on 10/28/18.
//  Copyright © 2018 Brian D Keane. All rights reserved.
//

import AVFoundation
import Foundation
import AudioToolbox

public class Reader: Readable {
    
    public internal(set) var currentPacket: AVAudioPacketCount = 0
    public let parser:Parsable
    public let readFormat: AVAudioFormat

    /// An 'AudioconverterRef' used to do the coversion from the source format of the parser to the read destination format
    var converter: AudioConverterRef? = nil
    
    /// A 'DispatchQueue' used to ensure any operations we do are thread-safe
    private let queue = DispatchQueue(label: "com.fastleraner.streamer")

    public required init(parser: Parsable, readFormat: AVAudioFormat) throws {
        self.parser = parser
        
        guard let dataFormat = parser.dataFormat else {
            throw ReaderError.parserMissingDataFormat
        }
        
        let sourceFormat = dataFormat.streamDescription
        let commonFormat = readFormat.streamDescription
        
        let result = AudioConverterNew(sourceFormat, commonFormat, &converter)
        guard result == noErr else {
            throw ReaderError.unableToCreateConverter(result)
        }
        self.readFormat = readFormat
    }
    
    // make sure the converter is deallocated
    deinit {
        guard AudioConverterDispose(converter!) == noErr else {
            return
        }
    }
    
    public func read(_ frames: AVAudioFrameCount) throws -> AVAudioPCMBuffer {
        let framesPerPacket = readFormat.streamDescription.pointee.mFramesPerPacket
        var packets = frames / framesPerPacket
        
        guard let buffer = AVAudioPCMBuffer(pcmFormat: readFormat, frameCapacity: frames) else {
            throw ReaderError.failedToCreatePCMBuffer
        }
        buffer.frameLength = frames
        
        try queue.sync {
            let context = unsafeBitCast(self, to: UnsafeMutableRawPointer.self)
            let status = AudioConverterFillComplexBuffer(converter!, ReaderConverterCallback, context, &packets, buffer.mutableAudioBufferList, nil)
            guard status == noErr else {
                switch status {
                case ReaderMissingSourceFormatError:
                    throw ReaderError.parserMissingDataFormat
                case ReaderReachedEndOfDataError:
                    throw ReaderError.reachedEndOfFile
                case ReaderNotEnoughDataError:
                    throw ReaderError.notEnoughData
                default:
                    throw ReaderError.converterFailed(status)
                }
            }
        }
        return buffer
    }
    
    public func seek(_ packet: AVAudioPacketCount) throws {
        queue.sync {
            currentPacket = packet
        }
    }
    
}


