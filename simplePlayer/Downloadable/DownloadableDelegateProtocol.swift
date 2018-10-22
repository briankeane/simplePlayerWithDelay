//
//  DownloadableDelegateProtocol.swift
//  simplePlayer
//
//  Created by Brian D Keane on 10/22/18.
//  Copyright © 2018 Brian D Keane. All rights reserved.
//

import Foundation

public protocol DownloadableDelegate: class {
    func download(_ download: Downloadable, changedState state: DownloadableState)
    func download(_ download: Downloadable, completedWithError error: Error?)
    func download(_ download: Downloadable, didReceiveData data: Data, progress: Float)
}
