//
//  DCChatViewController.swift
//  MorseCode
//
//  Created by MobileDev on 10/17/18.
//  Copyright © 2018 SwiftDeveloper. All rights reserved.
//

import UIKit
import BluetoothKit

class DCChatViewController: UIViewController {

    @IBOutlet weak var receivedView: UIView!
    @IBOutlet weak var receivedTextView: UITextView!
    @IBOutlet weak var receivedSoundSwitch: UISwitch!
    @IBOutlet weak var sentView: UIView!
    @IBOutlet weak var sentTextView: UITextView!
    @IBOutlet weak var sentSoundSwitch: UISwitch!
    @IBOutlet weak var dotButton: UIButton!
    @IBOutlet weak var dashButton: UIButton!
    
    var central: BKRemoteCentral? = nil
    var peripheral: BKRemotePeripheral? = nil
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        let backButton = UIButton(type: .system)
        backButton.setTitle("Back", for: .normal)
        backButton.setTitleColor(UIColor.black, for: .normal)
        backButton.titleLabel?.font = UIFont.systemFont(ofSize: 17)
        backButton.addTarget(self, action: #selector(onBack), for: .touchUpInside)
        let backBarItem = UIBarButtonItem(customView: backButton)
        navigationItem.leftBarButtonItem = backBarItem
        navigationController?.setNavigationBarHidden(false, animated: true)
        
        let views: [UIView] = [receivedView, sentView]
        for view in views {
            view.layer.borderWidth = 1
            view.layer.borderColor = UIColor.black.cgColor
        }
        
        let buttons: [UIButton] = [dotButton, dashButton]
        for button in buttons {
            button.layer.masksToBounds = true
            button.layer.cornerRadius = 10
            button.layer.borderWidth = 1
            button.layer.borderColor = UIColor.black.cgColor
        }
        
        receivedSoundSwitch.isOn = DCAppSettings.isReceivedSoundEnabled
        sentSoundSwitch.isOn = DCAppSettings.isSentSoundEnabled
        
        sentTextView.text = ""
        receivedTextView.text = ""
        
        DCMorseCodeBLECentral.shared.delegate = self
        DCMorseCodeBLEPeripheral.shared.delegate = self
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        navigationItem.title = "Morse Code"
        navigationController?.setNavigationBarHidden(false, animated: true)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        navigationController?.setNavigationBarHidden(true, animated: true)
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

    // MARK: - Send Data
    private func sendText(_ text: String) {
        guard let data = text.data(using: .utf8) else {
            return
        }
        
        if let central = central { // Client
            DCMorseCodeBLEPeripheral.shared.sendData(data, to: central) { (success) in
                if success {
                    DispatchQueue.main.async {
                        self.sentTextView.text += text
                    }
                }
            }
            
            if DCAppSettings.isSentSoundEnabled {
                if text == "." {
                    DCMorseCodeSoundPlayer.shared.playDot01()
                } else if text == "-" {
                    DCMorseCodeSoundPlayer.shared.playDash01()
                }
            }
        }
        if let peripheral = peripheral { // Server
            DCMorseCodeBLECentral.shared.sendData(data, to: peripheral) { (success) in
                if success {
                    DispatchQueue.main.async {
                        self.sentTextView.text += text
                    }
                }
            }
            
            if DCAppSettings.isSentSoundEnabled {
                if text == "." {
                    DCMorseCodeSoundPlayer.shared.playDot01()
                } else if text == "-" {
                    DCMorseCodeSoundPlayer.shared.playDash01()
                }
            }
        }
    }
    
    private func receviedText(_ text: String) {
        DispatchQueue.main.async {
            self.receivedTextView.text += text
        }
        
        if DCAppSettings.isReceivedSoundEnabled {
            if text == "." {
                DCMorseCodeSoundPlayer.shared.playDot02()
            } else if text == "-" {
                DCMorseCodeSoundPlayer.shared.playDash02()
            }
        }
    }
    
    // MARK: - User Action
    @objc private func onBack() {
        if central != nil {
            DCMorseCodeBLEPeripheral.shared.delegate = nil
            _ = DCMorseCodeBLEPeripheral.shared.stopRunning()
            
        }
        if let peripheral = peripheral {
            DCMorseCodeBLECentral.shared.delegate = nil
            DCMorseCodeBLECentral.shared.disconnect(peripheral: peripheral)
            _ = DCMorseCodeBLECentral.shared.stopRunning()
        }
        
        navigationController?.popViewController(animated: true)
    }
    
    @IBAction func onDot(_ sender: Any) {
        sendText(".")
    }
    
    @IBAction func onDash(_ sender: Any) {
        sendText("-")
    }
    
    @IBAction func onChangeReceivedSound(_ sender: Any) {
        DCAppSettings.isReceivedSoundEnabled = receivedSoundSwitch.isOn
    }
    
    @IBAction func onChangeSentSound(_ sender: Any) {
        DCAppSettings.isSentSoundEnabled = sentSoundSwitch.isOn
    }
}

extension DCChatViewController: DCMorseCodeBLECentralDelegate {
    func dcMorseCodeBLECentralDidFinishDisconnect(_ sender: DCMorseCodeBLECentral, peripheral: BKRemotePeripheral, success: Bool) {
        if self.peripheral == peripheral {
            DispatchQueue.main.async {
                self.onBack()
            }
        }
    }
    
    func dcMorseCodeBLECentralDidReceiveData(_ sender: DCMorseCodeBLECentral, data: Data, from: BKRemotePeer) {
        let text = String(data: data, encoding: .utf8)
        if let text = text {
            receviedText(text)
        }
    }
}

extension DCChatViewController: DCMorseCodeBLEPeripheralDelegate {
    func dcMorseCodeBLEPeripheralDidFinishConnect(_ sender: DCMorseCodeBLEPeripheral, central: BKRemoteCentral) {
        
    }
    
    func dcMorseCodeBLEPeripheralDidFinishDisconnect(_ sender: DCMorseCodeBLEPeripheral, central: BKRemoteCentral) {
        if self.central == central {
            DispatchQueue.main.async {
                self.onBack()
            }
        }
    }
    
    func dcMorseCodeBLEPeripheralDidReceiveData(_ sender: DCMorseCodeBLEPeripheral, data: Data, from: BKRemotePeer) {
        let text = String(data: data, encoding: .utf8)
        if let text = text {
            receviedText(text)
        }
    }
}
