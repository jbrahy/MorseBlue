//
//  DCMorseCodeBLECentral.swift
//  MorseCode
//
//  Created by MobileDev on 10/16/18.
//  Copyright © 2018 SwiftDeveloper. All rights reserved.
//

import UIKit
import BluetoothKit

protocol DCMorseCodeBLECentralDelegate: class {
    func dcMorseCodeBLECentralDidFinishDisconnect(_ sender: DCMorseCodeBLECentral, peripheral: BKRemotePeripheral, success: Bool)
    func dcMorseCodeBLECentralDidReceiveData(_ sender: DCMorseCodeBLECentral, data: Data, from: BKRemotePeer)
}

class DCMorseCodeBLECentral: NSObject {
    static let shared = DCMorseCodeBLECentral()
    
    private let central = BKCentral()
    private var _isRunning: Bool = false
    var isRunning: Bool {
        return _isRunning
    }
    private var _isScanning: Bool = false
    var isScanning: Bool {
        return _isScanning
    }
    var isAvailable: Bool {
        if let availability = central.availability {
            return availability == .available
        }
        
        return false
    }

    weak var delegate: DCMorseCodeBLECentralDelegate? = nil
    
    override init() {
        super.init()
        
        _isRunning = false
        _isScanning = false
        delegate = nil
        
        central.delegate = self
        central.addAvailabilityObserver(self)
    }
    
    // MARK: - Start Service
    func startRunning() -> Bool {
        var success: Bool = false
        
        do {
            let serviceUUID = UUID(uuidString: DCMorseCodeBLEConstant.serviceUUID)!
            let characteristicUUID = UUID(uuidString: DCMorseCodeBLEConstant.characteristicUUIDUUID)!
            let configuration = BKConfiguration(dataServiceUUID: serviceUUID, dataServiceCharacteristicUUID: characteristicUUID)
            try central.startWithConfiguration(configuration)
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
            try central.stop()
            _isRunning = false
            
            success = true
        } catch let error {
            print("\(error.localizedDescription)")
        }
        
        return success
    }
    
    // MARK: - Scan Peripheral
    func startScanning(timeout: TimeInterval, completion: @escaping (([BKDiscovery]) -> Void)) {
        if _isScanning {
            stopScanning()
        }
        
        _isScanning = true
        central.scanWithDuration(timeout, progressHandler: { (discoveries) in
            
        }) { (discoveries, error) in
            self._isScanning = false
            
            completion(discoveries ?? [])
        }
    }
    
    func stopScanning() {
        central.interruptScan()
        
        _isScanning = false
    }
    
    // MARK: - Connect/Disconnect Peripheral
    func isConnected(peripheral: BKRemotePeripheral) -> Bool {
        return central.connectedRemotePeripherals.contains(peripheral)
    }
    
    func connect(peripheral: BKRemotePeripheral, completion: @escaping ((_ success: Bool) -> Void)) {
        if central.connectedRemotePeripherals.contains(peripheral) {
            completion(true)
            return
        }
        
        central.connect(remotePeripheral: peripheral) { (peripheral, error) in
            if error == nil {
                peripheral.delegate = self
            }
            completion(error == nil)
        }
    }
    
    func disconnect(peripheral: BKRemotePeripheral) {
        if !central.connectedRemotePeripherals.contains(peripheral) {
            peripheral.delegate = nil
            delegate?.dcMorseCodeBLECentralDidFinishDisconnect(self, peripheral: peripheral, success: true)
            return
        }
        
        do {
            try central.disconnectRemotePeripheral(peripheral)
        } catch {
            peripheral.delegate = nil
            delegate?.dcMorseCodeBLECentralDidFinishDisconnect(self, peripheral: peripheral, success: true)
        }
    }
    
    // MARK: - Send Data
    func sendData(_ data: Data, to: BKRemotePeripheral, completion: @escaping ((_ success: Bool) -> Void)) {
        central.sendData(data, toRemotePeer: to) { (_, _, error) in
            completion(error == nil)
        }
    }
}

extension DCMorseCodeBLECentral: BKCentralDelegate {
    func central(_ central: BKCentral, remotePeripheralDidDisconnect remotePeripheral: BKRemotePeripheral) {
        remotePeripheral.delegate = nil
        delegate?.dcMorseCodeBLECentralDidFinishDisconnect(self, peripheral: remotePeripheral, success: true)
    }
}

extension DCMorseCodeBLECentral: BKAvailabilityObserver {
    func availabilityObserver(_ availabilityObservable: BKAvailabilityObservable, availabilityDidChange availability: BKAvailability) {
        
    }
    
    func availabilityObserver(_ availabilityObservable: BKAvailabilityObservable, unavailabilityCauseDidChange unavailabilityCause: BKUnavailabilityCause) {
    }
}

extension DCMorseCodeBLECentral: BKRemotePeerDelegate {
    func remotePeer(_ remotePeer: BKRemotePeer, didSendArbitraryData data: Data) {
        delegate?.dcMorseCodeBLECentralDidReceiveData(self, data: data, from: remotePeer)
    }
}
