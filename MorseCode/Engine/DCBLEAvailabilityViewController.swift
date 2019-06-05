//
//  DCBLEAvailabilityDelegate.swift
//  MorseCode
//
//  Created by MobileDev on 10/16/18.
//  Copyright © 2018 SwiftDeveloper. All rights reserved.
//

import Foundation
import BluetoothKit

protocol DCBLEAvailabilityViewController: class, BKAvailabilityObserver {
    var availabilityView: DCBLEAvailabilityView { get set }
    var heightForAvailabilityView: CGFloat { get }
    func applyAvailabilityView()
}

extension DCBLEAvailabilityViewController where Self: UIViewController {
    // MARK: - Properties
    var heightForAvailabilityView: CGFloat {
        return CGFloat(45)
    }
    
    // MARK: - Functions
    func applyAvailabilityView() {
        view.addSubview(availabilityView)
        availabilityView.snp.makeConstraints { make in
            make.leading.trailing.bottom.equalTo(view)
            make.height.equalTo(heightForAvailabilityView)
        }
    }

    func availabilityObserver(_ availabilityObservable: BKAvailabilityObservable, availabilityDidChange availability: BKAvailability) {
        availabilityView.availabilityObserver(availabilityObservable, availabilityDidChange: availability)
    }
    
    func availabilityObserver(_ availabilityObservable: BKAvailabilityObservable, unavailabilityCauseDidChange unavailabilityCause: BKUnavailabilityCause) {
        availabilityView.availabilityObserver(availabilityObservable, unavailabilityCauseDidChange: unavailabilityCause)
    }
}
