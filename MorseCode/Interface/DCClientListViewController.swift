//
//  DCClientListViewController.swift
//  MorseCode
//
//  Created by MobileDev on 10/17/18.
//  Copyright © 2018 SwiftDeveloper. All rights reserved.
//

import UIKit
import SVProgressHUD
import BluetoothKit

class DCClientTableViewCell: UITableViewCell {
    
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var statusLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
}

protocol DCClientListViewControllerDelegate: class {
    func dcClientListViewControllerDidConnect(_ sender: DCClientListViewController, peripheral: BKRemotePeripheral)
}

class DCClientListViewController: UIViewController {
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var startButton: UIButton!
    
    private var clients: [BKDiscovery] = []
    weak var delegate: DCClientListViewControllerDelegate? = nil
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let backButton = UIButton(type: .system)
        backButton.setTitle("Cancel", for: .normal)
        backButton.setTitleColor(UIColor.black, for: .normal)
        backButton.titleLabel?.font = UIFont.systemFont(ofSize: 17)
        backButton.addTarget(self, action: #selector(onCancel), for: .touchUpInside)
        let backBarItem = UIBarButtonItem(customView: backButton)
        navigationItem.leftBarButtonItem = backBarItem
        navigationController?.setNavigationBarHidden(false, animated: true)
        
        // Do any additional setup after loading the view.
        tableView.tableFooterView = UIView(frame: CGRect.zero)
        tableView.layer.masksToBounds = true
        tableView.layer.borderColor = UIColor.black.cgColor
        tableView.layer.borderWidth = 1
        
        startButton.layer.masksToBounds = true
        startButton.layer.borderColor = UIColor.black.cgColor
        startButton.layer.borderWidth = 1
        startButton.layer.cornerRadius = 10
        
        startButton.isEnabled = DCMorseCodeBLECentral.shared.startRunning()
        if DCMorseCodeBLECentral.shared.isScanning {
            startButton.setTitle("Scanning Clients...", for: .normal)
            startButton.isEnabled = false
        } else {
            startButton.setTitle("Scan Clients", for: .normal)
            startButton.isEnabled = true
        }
        
//        if !DCMorseCodeBLECentral.shared.isAvailable {
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
        if DCMorseCodeBLECentral.shared.isScanning {
            DCMorseCodeBLECentral.shared.stopScanning()
        }
        
        navigationController?.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func onStart(_ sender: Any) {
        if DCMorseCodeBLECentral.shared.isScanning {
            DCMorseCodeBLECentral.shared.stopScanning()
            startButton.setTitle("Scan Clients", for: .normal)
            startButton.isEnabled = true
        } else {
            startButton.setTitle("Scanning Clients...", for: .normal)
            startButton.isEnabled = false
            
            SVProgressHUD.show()
            DCMorseCodeBLECentral.shared.startScanning(timeout: 5) { (discoveries) in
                self.clients = discoveries
                
                DispatchQueue.main.async {
                    SVProgressHUD.dismiss()
                    
                    self.tableView.reloadData()
                    self.startButton.setTitle("Scan Clients", for: .normal)
                    self.startButton.isEnabled = true
                }
            }
        }
    }
}

extension DCClientListViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return clients.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ClientCell") as! DCClientTableViewCell
        let peripheral = clients[indexPath.row].remotePeripheral
        
        cell.nameLabel.text = peripheral.name
        cell.statusLabel.text = DCMorseCodeBLECentral.shared.isConnected(peripheral: peripheral) ? "Connected" : "Disconnected"
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let peripheral = clients[indexPath.row].remotePeripheral
        DCMorseCodeBLECentral.shared.connect(peripheral: peripheral) { (success) in
            DispatchQueue.main.async {
                self.navigationController?.dismiss(animated: true, completion: {
                    self.delegate?.dcClientListViewControllerDidConnect(self, peripheral: peripheral)
                })
            }
        }
    }
}
