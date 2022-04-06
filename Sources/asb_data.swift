/**
 * \file    asb_data.swift
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


/**
 * The value of a characteristic in the CoreBluetooth module is given as a
 * plain generic ``Data`` object. This struct wraps it with a timestamp,
 * representing the unix epoch (with nanosecond precision) when the buffer
 * was received.
 */
public struct ASB_data
{
    
    public let timestamp : ASB_timestamp
    public let data      : Data
    
    
    public init()
    {
        self.init(timestamp: 0, data: Data() )
    }
    
    
    public init(
            timestamp : ASB_timestamp,
            data      : Data
        )
    {
        self.timestamp = timestamp
        self.data      = data
    }
    
}
