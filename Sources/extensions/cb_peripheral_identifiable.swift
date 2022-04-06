/**
 * \file    cb_peripheral_identifiable.swift
 * \author  Mauricio Villarroel
 * \date    Created: Feb 3, 2022
 * ____________________________________________________________________________
 *
 * Copyright (C) 2022 Mauricio Villarroel. All rights reserved.
 *
 * SPDX-License-Identifer:  GPL-2.0-only
 * ____________________________________________________________________________
 */

import Foundation
import CoreBluetooth


extension CBPeripheral : Identifiable
{
    
    public typealias ID_type = UUID
    
    public var id : CBPeripheral.ID_type
    {
        self.identifier
    }
    
}
