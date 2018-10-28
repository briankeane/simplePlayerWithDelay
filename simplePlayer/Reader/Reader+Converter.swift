//
//  Reader+Converter.swift
//  simplePlayer
//
//  Created by Brian D Keane on 10/28/18.
//  Copyright © 2018 Brian D Keane. All rights reserved.
//

import Foundation
import AVFoundation

func ReaderConverterCallback(_ converter: AudioConverterRef,
                             _ packetCount: UnsafeMutablePointer<UInt32>,
                             _ ioData: UnsafeMutablePointer<AudioBufferList>,
                             _ outPacketDescriptions: UnsafeMutablePointer<UnsafeMutablePointer<AudioStreamPacketDescription>?>?,
                             _ context: UnsafeMutableRawPointer?) -> OSStatus {
    let reader = Unmanaged<Reader>.fromOpaque(context!).takeUnretainedValue()
    
    guard let sourceFormat = reader.parser.dataFormat else {
        return ReaderMissingSourceFormatError
    }
    
    let packetIndex = Int(reader.currentPacket)
    let packets = reader.parser.packets
    let isEndOfData = packetIndex >= packets.count - 1
    if isEndOfData {
        if reader.parser.isParsingComplete {
            packetCount.pointee = 0
            return ReaderReachedEndOfDataError
        } else {
            return ReaderNotEnoughDataError
        }
    }
    
    let packet = packets[packetIndex]
    var data = packet.0
    let dataCount = data.count
    ioData.pointee.mNumberBuffers = 1
    ioData.pointee.mBuffers.mData = UnsafeMutableRawPointer.allocate(byteCount: dataCount, alignment: 0)
    _ = data.withUnsafeMutableBytes { (bytes: UnsafeMutablePointer<UInt8>) in
        memcpy((ioData.pointee.mBuffers.mData?.assumingMemoryBound(to: UInt8.self))!, bytes, dataCount)
    }
    ioData.pointee.mBuffers.mDataByteSize = UInt32(dataCount)
    
    let sourceFormatDescription = sourceFormat.streamDescription.pointee
    if sourceFormatDescription.mFormatID != kAudioFormatLinearPCM {
        if outPacketDescriptions?.pointee == nil {
            outPacketDescriptions?.pointee = UnsafeMutablePointer<AudioStreamPacketDescription>.allocate(capacity: 1)
        }
        outPacketDescriptions?.pointee?.pointee.mDataByteSize = UInt32(dataCount)
        outPacketDescriptions?.pointee?.pointee.mStartOffset = 0
        outPacketDescriptions?.pointee?.pointee.mVariableFramesInPacket = 0
    }
    packetCount.pointee = 1
    reader.currentPacket = reader.currentPacket + 1
    
    return noErr
}
