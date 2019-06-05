//
//  DCMorseCodeBLEPeripheral.swift
//  MorseCode
//
//  Created by MobileDev on 10/16/18.
//  Copyright © 2018 SwiftDeveloper. All rights reserved.
//

import UIKit
import BluetoothKit
import CoreBluetooth

protocol DCMorseCodeBLEPeripheralDelegate: class {
    func dcMorseCodeBLEPeripheralDidFinishConnect(_ sender: DCMorseCodeBLEPeripheral, central: BKRemoteCentral)
    func dcMorseCodeBLEPeripheralDidFinishDisconnect(_ sender: DCMorseCodeBLEPeripheral, central: BKRemoteCentral)
    func dcMorseCodeBLEPeripheralDidReceiveData(_ sender: DCMorseCodeBLEPeripheral, data: Data, from: BKRemotePeer)
}

class DCMorseCodeBLEPeripheral: NSObject {
    static let shared = DCMorseCodeBLEPeripheral()
    
    private let peripheral = BKPeripheral()
    private var _isRunning: Bool = false
    var isRunning: Bool {
        return _isRunning
    }
    var isAvailable: Bool {
        let peripheralManager = CBPeripheralManager(delegate: nil, queue: nil)
        return peripheralManager.state == .poweredOn
    }
    
    weak var delegate: DCMorseCodeBLEPeripheralDelegate? = nil
    
    override init() {
        super.init()

        _isRunning = false
        peripheral.delegate = self
        peripheral.addAvailabilityObserver(self)
    }
    
    // MARK: - Start Service
    func startRunning(name: String = "") -> Bool {
        var success: Bool = false
        
        do {
            let serviceUUID = UUID(uuidString: DCMorseCodeBLEConstant.serviceUUID)!
            let characteristicUUID = UUID(uuidString: DCMorseCodeBLEConstant.characteristicUUIDUUID)!
            let configuration = BKPeripheralConfiguration(dataServiceUUID: serviceUUID, dataServiceCharacteristicUUID: characteristicUUID, localName: name)
            try peripheral.startWithConfiguration(configuration)
            _isRunning = true
            
            success = true
        } catch let error {
            print("\(error.localizedDescription)")
        }
        
        return success
    }
    
    func stopRunning() -> Bool {
        var success: Bool = false
        
        do {
            try peripheral.stop()
            _isRunning = false
            
            success = true
        } catch let error {
            print("\(error.localizedDescription)")
        }
        
        return success
    }
    
    // MARK: - Send Data
    func sendData(_ data: Data, to: BKRemoteCentral, completion: @escaping ((Bool) -> Void)) {
        peripheral.sendData(data, toRemotePeer: to) { (_, _, error) in
            completion(error == nil)
        }
    }
}

extension DCMorseCodeBLEPeripheral: BKPeripheralDelegate {
    func peripheral(_ peripheral: BKPeripheral, remoteCentralDidConnect remoteCentral: BKRemoteCentral) {
        remoteCentral.delegate = self
        delegate?.dcMorseCodeBLEPeripheralDidFinishConnect(self, central: remoteCentral)
    }
    
    func peripheral(_ peripheral: BKPeripheral, remoteCentralDidDisconnect remoteCentral: BKRemoteCentral) {
        remoteCentral.delegate = nil
        delegate?.dcMorseCodeBLEPeripheralDidFinishDisconnect(self, central: remoteCentral)
    }
}


extension DCMorseCodeBLEPeripheral: BKAvailabilityObserver {
    func availabilityObserver(_ availabilityObservable: BKAvailabilityObservable, availabilityDidChange availability: BKAvailability) {
        
    }
    
    func availabilityObserver(_ availabilityObservable: BKAvailabilityObservable, unavailabilityCauseDidChange unavailabilityCause: BKUnavailabilityCause) {
    }
}

extension DCMorseCodeBLEPeripheral: BKRemotePeerDelegate {
    func remotePeer(_ remotePeer: BKRemotePeer, didSendArbitraryData data: Data) {
        delegate?.dcMorseCodeBLEPeripheralDidReceiveData(self, data: data, from: remotePeer)
    }
}
