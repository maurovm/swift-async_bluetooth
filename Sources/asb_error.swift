/**
 * \file    asb_error.swift
 * \author  Mauricio Villarroel
 * \date    Created: Mar 1, 2022
 * ____________________________________________________________________________
 *
 * Copyright (C) 2022 Mauricio Villarroel. All rights reserved.
 *
 * SPDX-License-Identifer:  GPL-2.0-only
 * ____________________________________________________________________________
 */

import Foundation


public enum ASB_error: Error
{
    
    case bluetoothUnavailable
    
    case scanning_in_progress
    
    case failed_to_scan_for_peripherals(description: String)
    
    case connection_in_progress
    
    case disconnecting_in_progress
    
    case no_connection_to_peripheral_exists
    
    
    case failed_to_connect_to_peripheral( _ error: Error? )
    
    case failed_to_discover_service( _ error: Error )
    
    case failed_to_discover_characteristics( _ error: Error )
    
    case failed_to_discover_descriptor( _ error: Error )
    
    
    case characteristic_not_found
    
    case unable_to_parse_characteristic_value
    
    case failed_to_enable_notifications
    
    
    case empty_characteristic_value
    
    case empty_descriptor_value
    
    
    case decode_data(description: String)
    
    case unable_to_convert_value_to_data
    
    case unknown_error(description: String)
    
}
