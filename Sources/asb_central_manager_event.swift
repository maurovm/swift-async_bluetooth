/**
 * \file    asb_central_manager_event.swift
 * \author  Mauricio Villarroel
 * \date    Created: Mar 8, 2022
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
 * Events that occur in the Central Manager that have no associated action
 * requests. For example, when a peripheral is abruptly disconnected by the
 * user without the software requesting to disconnect. Subscribers to these
 * published events will take the appropriate action when they are notified
 * of the unusual activity
 */
public enum ASB_central_manager_event
{
    
    case no_set
    
    case did_update_state( _ state : CBManagerState )
    
    case peripheral_disconnected(
                _  peripheral_id : CBPeripheral.ID_type,
                   name   : String,
                   error  : Error?
            )
    
    case no_continuation_for_did_connect(
                _  peripheral_id : CBPeripheral.ID_type,
                   error         : Error
            )
    
    case no_continuation_for_did_failt_to_connect(
                _  peripheral_id : CBPeripheral.ID_type,
                   error         : Error
            )
    
    case no_continuation_for_did_disconnect(
                _  peripheral_id : CBPeripheral.ID_type,
                   error         : Error
            )
    
}
