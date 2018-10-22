//
//  ViewController.swift
//  simplePlayer
//
//  Created by Brian D Keane on 10/22/18.
//  Copyright © 2018 Brian D Keane. All rights reserved.
//

import UIKit
import AVFoundation

class ViewController: UIViewController {
    var playerNode:AVAudioPlayerNode!
    var delayNode:AVAudioUnitDelay!
    var engine:AVAudioEngine!
    var file:AVAudioFile!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        /// Setup session
        let session = AVAudioSession.sharedInstance()
        do {
            try session.setCategory(.playback, mode: .default)
            try session.setActive(true)
        } catch {
            print("Failed to activate audio session: \(error.localizedDescription)")
        }
        
        engine = AVAudioEngine()
        
        // Create the nodes (1)
        playerNode = AVAudioPlayerNode()
        delayNode = AVAudioUnitDelay()
        
        // Attach the nodes (2)
        engine.attach(playerNode)
        engine.attach(delayNode)
        
        // Connect the nodes (3)
        engine.connect(playerNode, to: delayNode, format: nil)
        engine.connect(delayNode, to: engine.mainMixerNode, format: nil)
        
        // Prepare the engine (4)
        engine.prepare()
        
        // Schedule file (5)
        do {
            // Local files only
            let url = URL(fileReferenceLiteralResourceName: "hihat.wav")
            file = try AVAudioFile(forReading: url)
        } catch {
            print("Failed to create file: \(error.localizedDescription)")
            return
        }
        
        // Setup delay parameters (6)
        delayNode.delayTime = 0.8
        delayNode.feedback = 80
        delayNode.wetDryMix = 50
        
        // Start the engine and player node (7)
        do {
            try engine.start()
        } catch {
            print("Failed to start engine: \(error.localizedDescription)")
        }
        // Do any additional setup after loading the view, typically from a nib.
    }
    
    @IBAction func playButtonPressed(_ sender: Any) {
         playerNode.scheduleFile(file, at: nil, completionHandler: nil)
        playerNode.play()
    }
    


}

