//
//  DCMorseCodeSoundPlayer.swift
//  MorseCode
//
//  Created by MobileDev on 10/18/18.
//  Copyright © 2018 SwiftDeveloper. All rights reserved.
//

import UIKit
import AVFoundation

class DCMorseCodeSoundPlayer: NSObject {
    static let shared = DCMorseCodeSoundPlayer()
    
    private var dashSoundId01: SystemSoundID = 0
    private var dashSoundId02: SystemSoundID = 0
    private var dotSoundId01: SystemSoundID = 0
    private var dotSoundId02: SystemSoundID = 0
    
    override init() {
        super.init()
        
        createSounds()
    }
    
    deinit {
        releaseSounds()
    }
    
    // MARK: - Prepare
    func createSounds() {
        if let url = Bundle.main.url(forResource: "dash_01", withExtension: "wav") {
            AudioServicesCreateSystemSoundID(url as CFURL, &dashSoundId01)
        }
        if let url = Bundle.main.url(forResource: "dash_02", withExtension: "wav") {
            AudioServicesCreateSystemSoundID(url as CFURL, &dashSoundId02)
        }
        if let url = Bundle.main.url(forResource: "dot_01", withExtension: "wav") {
            AudioServicesCreateSystemSoundID(url as CFURL, &dotSoundId01)
        }
        if let url = Bundle.main.url(forResource: "dot_02", withExtension: "wav") {
            AudioServicesCreateSystemSoundID(url as CFURL, &dotSoundId02)
        }
    }
    
    func releaseSounds() {
        if dashSoundId01 > 0 {
            AudioServicesDisposeSystemSoundID(dashSoundId01)
        }
        if dashSoundId02 > 0 {
            AudioServicesDisposeSystemSoundID(dashSoundId02)
        }
        if dotSoundId01 > 0 {
            AudioServicesDisposeSystemSoundID(dotSoundId01)
        }
        if dotSoundId02 > 0 {
            AudioServicesDisposeSystemSoundID(dotSoundId02)
        }
    }
    
    // MARK: - Play
    func playDash01() {
        if dashSoundId01 > 0 {
            AudioServicesPlaySystemSound(dashSoundId01)
        }
    }
    
    func playDot01() {
        if dotSoundId01 > 0 {
            AudioServicesPlaySystemSound(dotSoundId01)
        }
    }
    
    func playDash02() {
        if dashSoundId02 > 0{
            AudioServicesPlaySystemSound(dashSoundId02)
        }
    }
    
    func playDot02() {
        if dotSoundId02 > 0{
            AudioServicesPlaySystemSound(dotSoundId02)
        }
    }
}
