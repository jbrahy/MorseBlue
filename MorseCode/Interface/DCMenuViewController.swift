//
//  DCMenuViewController.swift
//  MorseCode
//
//  Created by MobileDev on 10/16/18.
//  Copyright © 2018 SwiftDeveloper. All rights reserved.
//

import UIKit
import BluetoothKit

class DCMenuViewController: UIViewController {

    @IBOutlet weak var masterButton: UIButton!
    @IBOutlet weak var clientButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        navigationController?.setNavigationBarHidden(true, animated: true)
        
        let buttons: [UIButton] = [masterButton, clientButton]
        for button in buttons {
            button.layer.masksToBounds = true
            button.layer.cornerRadius = 20
            button.layer.borderWidth = 2
            button.layer.borderColor = UIColor.black.cgColor
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        navigationController?.setNavigationBarHidden(true, animated: true)
    }
    
    // MARK: - Navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
        if segue.identifier == "Menu2ClientList" {
            let clientListViewController = (segue.destination as! UINavigationController).viewControllers[0] as! DCClientListViewController
            clientListViewController.delegate = self
        } else if segue.identifier == "Menu2ClientSetup" {
            let clientSetupViewController = (segue.destination as! UINavigationController).viewControllers[0] as! DCClientSetupViewController
            clientSetupViewController.delegate = self
        } else if segue.identifier == "Menu2Chat" {
            let chatViewController = segue.destination as! DCChatViewController
            chatViewController.central = sender as? BKRemoteCentral
            chatViewController.peripheral = sender as? BKRemotePeripheral
        }
    }

    // MARK: - User Action
    @IBAction func onMasterMode(_ sender: Any) {
        performSegue(withIdentifier: "Menu2ClientList", sender: nil)
    }
    
    @IBAction func onClientMode(_ sender: Any) {
        performSegue(withIdentifier: "Menu2ClientSetup", sender: nil)
    }
}

extension DCMenuViewController: DCClientListViewControllerDelegate {
    func dcClientListViewControllerDidConnect(_ sender: DCClientListViewController, peripheral: BKRemotePeripheral) {
        performSegue(withIdentifier: "Menu2Chat", sender: peripheral)
    }
}

extension DCMenuViewController: DCClientSetupViewControllerDelegate {
    func dcClientSetupViewControllerDidConnect(_ sender: DCClientSetupViewController, central: BKRemoteCentral) {
        performSegue(withIdentifier: "Menu2Chat", sender: central)
    }
}
