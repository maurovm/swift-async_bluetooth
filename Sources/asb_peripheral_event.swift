/**
 * \file    asb_peripheral_event.swift
 * \author  Mauricio Villarroel
 * \date    Created: Mar 30, 2022
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
 * Events that occur in the BLE Peripheral that have no associated action
 * requests. For example, when a peripheral has a different delegate class.
 *
 * Subscribers to these published events will take the appropriate action
 * when they are notified of the unusual activity
 */
public enum ASB_peripheral_event
{
    
    case no_set
    
    
    
    case different_delegate_class(
                _  peripheral_id : CBPeripheral.ID_type,
                   class_name    : String
            )
    
    
    
    case no_continuation_for_service_discovery(
                _  peripheral_id : CBPeripheral.ID_type,
                   error         : Error
            )
    
    case no_continuation_for_included_service_discovery(
                _  peripheral_id : CBPeripheral.ID_type,
                   error         : Error
            )
    
    case no_continuation_for_characteristic_discovery(
                _  peripheral_id : CBPeripheral.ID_type,
                   service_id    : CBService.ID_type,
                   error         : Error
            )
    
    case no_continuation_for_descriptor_discovery(
                _  peripheral_id     : CBPeripheral.ID_type,
                   characteristic_id : CBCharacteristic.ID_type,
                   error             : Error
            )
    
    case no_continuation_for_RSSI_reader(
                _  peripheral_id     : CBPeripheral.ID_type,
                   error             : Error
            )
    
    case no_continuation_for_L2CAP_channel(
                _  peripheral_id     : CBPeripheral.ID_type,
                   error             : Error
            )
    
    
    
    case failed_to_read_characteristic_value(
                _  peripheral_id     : CBPeripheral.ID_type,
                _  characteristic_id : CBCharacteristic.ID_type,
                   error             : Error
            )
    
    case failed_to_read_descriptor_value(
                _  peripheral_id     : CBPeripheral.ID_type,
                _  descriptor_id     : CBDescriptor.ID_type,
                   error             : Error
            )
    
    
    
    case failed_to_write_characteristic_value(
                _  peripheral_id     : CBPeripheral.ID_type,
                _  characteristic_id : CBCharacteristic.ID_type,
                   error             : Error
            )
    
    case failed_to_write_descriptor_value(
                _  peripheral_id     : CBPeripheral.ID_type,
                _  descriptor_id     : CBDescriptor.ID_type,
                   error             : Error
            )
    
    
    
    case failed_to_set_notify_value(
                _  peripheral_id     : CBPeripheral.ID_type,
                _  characteristic_id : CBCharacteristic.ID_type,
                   error             : Error
            )
    
}
