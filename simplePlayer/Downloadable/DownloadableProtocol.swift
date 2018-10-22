//
//  Downloadable.swift
//  simplePlayer
//
//  Created by Brian D Keane on 10/22/18.
//  Copyright © 2018 Brian D Keane. All rights reserved.
//

import Foundation

public protocol Downloadable: class {
    // MARK: - Properties
    
    /// A receiver implementing the `DownloadableDelegate` to receive state change, completion, and progress events from the `Downloadable` instance.
    var delegate: DownloadableDelegate? { get set }
    
    /// The current progress of the downloader. Ranges from 0.0 - 1.0, default is 0.0.
    var progress: Float { get }
    
    /// The current state of the downloader. See `DownloadableState` for the different possible states.
    var state: DownloadableState { get }
    
    /// A `URL` representing the current URL the downloader is fetching. This is an optional because this protocol is designed to allow classes implementing the `Downloadable` protocol to be used as singletons for many different URLS so a common cache can be used to redownloading the same resources.
    var url: URL? { get set }
    
    // MARK: - Methods
    
    /// Starts the downloader
    func start()
    
    /// Pauses the downloader
    func pause()
    
    /// Stops and/or aborts the downloader. This should invalidate all cached data under the hood.
    func stop()
}
