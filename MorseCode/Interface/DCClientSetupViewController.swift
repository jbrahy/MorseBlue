//
//  DCClientSetupViewController.swift
//  MorseCode
//
//  Created by MobileDev on 10/17/18.
//  Copyright © 2018 SwiftDeveloper. All rights reserved.
//

import UIKit
import BluetoothKit

protocol DCClientSetupViewControllerDelegate: class {
    func dcClientSetupViewControllerDidConnect(_ sender: DCClientSetupViewController, central: BKRemoteCentral)
}

class DCClientSetupViewController: UIViewController {

    @IBOutlet weak var nameField: UITextField!
    @IBOutlet weak var startButton: UIButton!
    
    weak var delegate: DCClientSetupViewControllerDelegate? = nil
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        let backButton = UIButton(type: .system)
        backButton.setTitle("Cancel", for: .normal)
        backButton.setTitleColor(UIColor.black, for: .normal)
        backButton.titleLabel?.font = UIFont.systemFont(ofSize: 17)
        backButton.addTarget(self, action: #selector(onCancel), for: .touchUpInside)
        let backBarItem = UIBarButtonItem(customView: backButton)
        navigationItem.leftBarButtonItem = backBarItem
        navigationController?.setNavigationBarHidden(false, animated: true)
        
        startButton.layer.masksToBounds = true
        startButton.layer.borderColor = UIColor.black.cgColor
        startButton.layer.borderWidth = 1
        startButton.layer.cornerRadius = 10
        
        nameField.text = "Anonymous"
        nameField.delegate = self
        
        DCMorseCodeBLEPeripheral.shared.delegate = self
        if DCMorseCodeBLEPeripheral.shared.isRunning {
            startButton.setTitle("Stop Scanning", for: .normal)
            nameField.isEnabled = false
        } else {
            startButton.setTitle("Start Scanning", for: .normal)
            nameField.isEnabled = true
        }
        
//        if !DCMorseCodeBLEPeripheral.shared.isAvailable {
//            let alertController = UIAlertController(title: "Bluetooth unavailable", message: "Please check Bluetooth status", preferredStyle: .alert)
//            let okAction = UIAlertAction(title: "OK", style: .default) { (_) in
//                self.onCancel()
//            }
//            alertController.addAction(okAction)
//            present(alertController, animated: true, completion: nil)
//        }
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

    // MARK: - User Action
    @objc private func onCancel() {
        if DCMorseCodeBLEPeripheral.shared.isRunning {
            _ = DCMorseCodeBLEPeripheral.shared.stopRunning()
        }
        
        navigationController?.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func onStart(_ sender: Any) {
        if DCMorseCodeBLEPeripheral.shared.isRunning {
            if DCMorseCodeBLEPeripheral.shared.stopRunning() {
                startButton.setTitle("Start Scanning", for: .normal)
                nameField.isEnabled = true
            }
        } else {
            let name = nameField.text ?? ""
            if name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                let alertController = UIAlertController(title: "Client Name is empty", message: "Please fill Client Name", preferredStyle: .alert)
                let okActionn = UIAlertAction(title: "OK", style: .default, handler: nil)
                alertController.addAction(okActionn)
                present(alertController, animated: true, completion: nil)
            } else {
                if DCMorseCodeBLEPeripheral.shared.startRunning(name: name) {
                    startButton.setTitle("Stop Scanning", for: .normal)
                    nameField.isEnabled = false
                }
            }
        }
    }
}

extension DCClientSetupViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        
        return true
    }
}

extension DCClientSetupViewController: DCMorseCodeBLEPeripheralDelegate {
    func dcMorseCodeBLEPeripheralDidReceiveData(_ sender: DCMorseCodeBLEPeripheral, data: Data, from: BKRemotePeer) {
        
    }
    
    func dcMorseCodeBLEPeripheralDidFinishConnect(_ sender: DCMorseCodeBLEPeripheral, central: BKRemoteCentral) {
        DCMorseCodeBLEPeripheral.shared.delegate = nil
        
        DispatchQueue.main.async {
            self.navigationController?.dismiss(animated: true, completion: {
                self.delegate?.dcClientSetupViewControllerDidConnect(self, central: central)
            })
        }
    }
    
    func dcMorseCodeBLEPeripheralDidFinishDisconnect(_ sender: DCMorseCodeBLEPeripheral, central: BKRemoteCentral) {
    }
}
