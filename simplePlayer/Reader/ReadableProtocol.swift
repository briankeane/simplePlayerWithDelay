//
//  Readable.swift
//  simplePlayer
//
//  Created by Brian D Keane on 10/28/18.
//  Copyright © 2018 Brian D Keane. All rights reserved.
//

import Foundation
import AVFoundation

public protocol Readable {
    // MARK: - Properties
    
    var currentPacket:AVAudioPacketCount { get }
    var parser: Parsable { get }
    var readFormat: AVAudioFormat { get }
    
    // MARK: - Initializers
    init(parser: Parsable, readFormat: AVAudioFormat) throws
    
    // MARK: - Methods
    func read(_ frames: AVAudioFrameCount) throws -> AVAudioPCMBuffer
    
    func seek(_ packet: AVAudioPacketCount) throws
}
