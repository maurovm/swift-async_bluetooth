/**
 * \file    asb_discovered_peripheral.swift
 * \author  Mauricio Villarroel
 * \date    Created: Feb 1, 2022
 * ____________________________________________________________________________
 *
 * Copyright (C) 2022 Mauricio Villarroel. All rights reserved.
 *
 * SPDX-License-Identifer:  GPL-2.0-only
 * ____________________________________________________________________________
 */

import Foundation
import CoreBluetooth


/**
 * Represents a newly discovered peripheral when the Cental Manager is
 * scanning for pheripherals
 */
public struct ASB_discovered_peripheral : Identifiable, Equatable
{   
    
    /**
     * Compare if two peripherals are describing the same device
     */
    public static func == (
            lhs : ASB_discovered_peripheral,
            rhs : ASB_discovered_peripheral
        ) -> Bool
    {
        return lhs.id == rhs.id
    }
    
    
    /**
     * Convinence shortcut to the original peripheral's identifier
     */
    public var id: CBPeripheral.ID_type
    {
        peripheral.id
    }
    
    
    /**
     * Convinence shortcut to the original peripheral's name
     */
    public var name: String
    {
        peripheral.name
    }
    
    
    /**
     * The actual peripheral object
     */
    public let peripheral: ASB_peripheral
    
    
    /**
     * A dictionary containing any information the devices is publicly
     * advertising
     */
    public let advertisement_data: [String : Any]
    
    
    /**
     * The current RSSI of the peripheral, in dBm. A value of 127 is
     * reserved and indicates the RSSI was not available.
     */
    public let rssi: NSNumber
    
    
    // MARK: - Internal module interface
    
    
    internal init(
            peripheral         : ASB_peripheral,
            advertisement_data : [String : Any],
            rssi               : NSNumber
        )
    {
        
        self.peripheral         = peripheral
        self.advertisement_data = advertisement_data
        self.rssi               = rssi
        
    }
    
}
