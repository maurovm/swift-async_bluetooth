/**
 * \file    cb_service_identifiable.swift
 * \author  Mauricio Villarroel
 * \date    Created: Feb 2, 2022
 * ____________________________________________________________________________
 *
 * Copyright (C) 2022 Mauricio Villarroel. All rights reserved.
 *
 * SPDX-License-Identifer:  GPL-2.0-only
 * ____________________________________________________________________________
 */

import Foundation
import CoreBluetooth


extension CBService : Identifiable
{
    
    public typealias ID_type = CBUUID
    
    public var id : ID_type
    {
        self.uuid
    }
    
    
}
