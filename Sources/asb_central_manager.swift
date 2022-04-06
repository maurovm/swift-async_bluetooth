/**
 * \file    asb_central_manager.swift
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
import CoreBluetooth


/**
 * This is the main public interface of the module. It attemps to provide
 * similar API as Apple's ``CBCentralManager`` class, but in an asynchronous
 * manner.
 *
 * The order of the functions in this file follows the order of
 * ``CBCentralManager``'s documentation.
 */
public final class ASB_central_manager
{
    
    @Published public private(set) var manager_event : ASB_central_manager_event
    
    
    /**
     * The current state of the Bluetooth manager
     */
    public var state: CBManagerState
    {
        delegate.state
    }

    
    // MARK: - Initializing the Central Manager
    
    
    /**
     * Class initialiser
     */
    public init(
            dispatch_queue : DispatchQueue? = nil,
            options        : [String: Any]? = nil
        )
    {
        
//        print("ASB_central_manager : init")
        
        delegate = Central_manager_delegate(dispatch_queue, options)
        manager_event = delegate.manager_event
    
        delegate.$manager_event.assign(to: &$manager_event)
        
    }
    
    
//    deinit
//    {
//        
//        print("ASB_central_manager : deinit")
//        
//    }
    
    
    // MARK: - Monitoring the Central Manager’s State
    
    
    /**
     * Waits until Bluetooth is ready.
     *
     * If the Bluetooth state is unknown or resetting, it will wait until a
     * `centralManagerDidUpdateState` message is received.
     *
     * If Bluetooth is powered off, unsupported or unauthorized, an error
     * will be thrown.
     *
     * Otherwise we'll continue.
     */
    public func wait_until_is_powered_on() async throws
    {
        
        try await delegate.wait_until_is_powered_on()
        
    }
    
    
    // MARK: - Establishing or Canceling Connections with Peripherals
    
    
    /**
     * Establishes a local connection to a peripheral.
     */
    public func connect(
            _  peripheral : ASB_peripheral,
               options    : [String : Any]? = nil
        ) async throws
    {
        
        try await delegate.connect(peripheral, options)
        
    }
    
    
    /**
     * Cancels an active or pending local connection to a peripheral.
     */
    public func disconnect(
            _ peripheral: ASB_peripheral
        ) async throws
    {
        
        try await delegate.cancel_peripheral_connection(peripheral)
        
    }
    
    
    // MARK: - Retrieving Lists of Peripherals
    
    
    /**
     * Returns a list of known peripherals by their identifiers.
     */
    public func retrieve_peripherals(
            with_identifiers identifiers: [UUID]
        ) -> [ASB_peripheral]
    {
    
        return delegate.retrieve_peripherals(identifiers)
    
    }
    
    
    /**
     * Returns a list of the peripherals connected to the system whose services
     * match a given set of criteria.
     */
    public func retrieve_connected_peripherals(
            with_services service_UUIDs: [CBUUID]
        ) -> [ASB_peripheral]
    {
    
        return delegate.retrieve_connected_peripherals(service_UUIDs)
    
    }
    
    
    // MARK: - Scanning or Stopping Scans of Peripherals
    
    
    /**
     * Scans for peripherals that are advertising services.
     * 
     */
    public func scan_for_peripherals(
            _  service_UUIDs : [CBUUID]?       = nil,
               options       : [String : Any]? = nil
        ) async -> AsyncThrowingStream<ASB_discovered_peripheral, Error>
    {
        
        return await delegate.scan_for_peripherals(service_UUIDs, options)
        
    }
    
    
    /**
     * Asks the central manager to stop scanning for peripherals.
     */
    public func stop_scan() async
    {
        
        await delegate.stop_scan()
        
    }
    
    
    /**
     * A Boolean value that indicates whether the central is
     * currently scanning.
     */
    public var is_scanning: Bool
    {
        
        delegate.is_scanning
        
    }
    
    
    // MARK: - Inspecting Feature Support
    
    
    /**
     * Returns a Boolean that indicates whether the device supports a
     * specific set of features.
     */
    @available(macOS, unavailable)
    public static func supports(
            _ features: CBCentralManager.Feature
        ) -> Bool
    {
    
        CBCentralManager.supports(features)
    
    }
    
    
    // MARK: - Private state
    
    
    private let delegate : Central_manager_delegate
    

}
