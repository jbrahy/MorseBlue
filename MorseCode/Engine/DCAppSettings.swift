//
//  DCAppSettings.swift
//  MorseCode
//
//  Created by MobileDev on 10/18/18.
//  Copyright © 2018 SwiftDeveloper. All rights reserved.
//

import UIKit

class DCAppSettings: NSObject {
    private static let initedKey: String          = "inited"
    private static let sentSoundEnabledKey: String          = "sent_sound_enabled"
    private static let receivedSoundEnabledKey: String      = "received_sound_enabled"
    
    class func prepare() {
        if !UserDefaults.standard.bool(forKey: initedKey) {
            UserDefaults.standard.set(true, forKey: sentSoundEnabledKey)
            UserDefaults.standard.set(true, forKey: receivedSoundEnabledKey)
            UserDefaults.standard.set(true, forKey: initedKey)
            UserDefaults.standard.synchronize()
        }
    }
    
    class var isSentSoundEnabled: Bool {
        get {
            return UserDefaults.standard.bool(forKey: sentSoundEnabledKey)
        }
        set {
            UserDefaults.standard.set(newValue, forKey: sentSoundEnabledKey)
            UserDefaults.standard.synchronize()
        }
    }
    
    class var isReceivedSoundEnabled: Bool {
        get {
            return UserDefaults.standard.bool(forKey: receivedSoundEnabledKey)
        }
        set {
            UserDefaults.standard.set(newValue, forKey: receivedSoundEnabledKey)
            UserDefaults.standard.synchronize()
        }
    }
}
