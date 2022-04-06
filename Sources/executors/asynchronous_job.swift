/**
 * \file    asynchronous_job.swift
 * \author  Mauricio Villarroel
 * \date    Created: Jan 26, 2022
 * ____________________________________________________________________________
 *
 * Copyright (C) 2022 Mauricio Villarroel. All rights reserved.
 *
 * SPDX-License-Identifer:  GPL-2.0-only
 * ____________________________________________________________________________
 */

import Foundation



/**
 * The code to run as part of the `Asynchronous_serial_executor`
 *
 * - Value: The returning type for the continuation
 */
struct Asynchronous_job<Value> : Identifiable
{
    
    let id           : UUID
    let function     : @Sendable () -> Void
    let continuation : CheckedContinuation<Value, Error>
    var is_cancelled : Bool   = false
    
}
