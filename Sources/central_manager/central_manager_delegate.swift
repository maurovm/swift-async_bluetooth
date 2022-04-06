/**
 * \file    central_manager_delegate.swift
 * \author  Mauricio Villarroel
 * \date    Created: Mar 27, 2022
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
 * This is the module's internal interface to the `CBCentralManager` class,
 * but offering an asynchronous interface.
 *
 * The order of the functions in this file follows the order of the
 * `CBCentralManager` documentation.
 */
final class Central_manager_delegate : NSObject, CBCentralManagerDelegate
{
    
    @Published private(set) var manager_event : ASB_central_manager_event =
        .no_set
    
    
    /**
     * The current state of the Bluetooth manager
     */
    var state: CBManagerState
    {
        CB_central_manager.state
    }

    
    // MARK: - Initializing the Central Manager
    
    
    /**
     * Class initialiser
     */
    init(
            _  dispatch_queue : DispatchQueue? = nil,
            _  options        : [String: Any]? = nil
        )
    {
        
//        print("ASB_central_manager : init")
        
        super.init()
    
        CB_central_manager = CBCentralManager(
                delegate: self,
                queue   : dispatch_queue,
                options : options
            )
        
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
    func wait_until_is_powered_on() async throws
    {
        
        if let status = is_bluetooth_accessible(for: state)
        {
            switch status
            {
                case .success:
                    return
                    
                case .failure(let error):
                    throw error
            }
        }
        else
        {
            try await manager_state_executor.submit{}
        }
        
    }
    
    
    /**
     * Notification event when the state of the central manager has changed
     */
    public func centralManagerDidUpdateState( _  central : CBCentralManager )
    {
        
        Task
        {
            [weak self] in
            
            if let status = self?.is_bluetooth_accessible(for: central.state)
            {
                await self?.manager_state_executor.broadcast(status)
            }
        }
        
    }
    
    
//    /**
//     * Tells the delegate the system is about to restore the central manager,
//     * as part of relaunching the app into the background.
//     */
//    public func centralManager(
//            _                 central : CBCentralManager,
//            willRestoreState  dict    : [String : Any]
//        )
//    {
//        // TODO: Implement this method to deal with app state swap/change
//    }
    
    
    // MARK: - Establishing or Canceling Connections with Peripherals
    
    
    /**
     * Establishes a local connection to a peripheral.
     */
    public func connect(
            _  peripheral : ASB_peripheral,
            _  options    : [String : Any]? = nil
        ) async throws
    {
        
        if await connection_executor.has_work(peripheral.id)
        {
            throw ASB_error.connection_in_progress
        }
        
        try await connection_executor.submit(peripheral.id)
        {
            [weak self] in
        
            self?.CB_central_manager.connect(
                    peripheral.cbPeripheral, options: options
                )
        }
        
    }
    
    
    /**
     * Tells the delegate that the central manager connected to a peripheral.
     */
    public func centralManager(
            _           cbCentralManager : CBCentralManager,
            didConnect  peripheral       : CBPeripheral
        )
    {
    
        Task
        {
            [weak self] in
        
            do
            {
                try await self?.connection_executor.send(
                        .success(()), for_key: peripheral.identifier
                    )
            }
            catch
            {
                self?.manager_event = .no_continuation_for_did_connect(
                        peripheral.id, error: error
                    )
            }
        }
    
    }
    
    
    /**
     * Tells the delegate the central manager failed to create a connection
     * with a peripheral.
     */
    public func centralManager(
            _                 cbCentralManager: CBCentralManager,
            didFailToConnect  peripheral      : CBPeripheral,
                              error           : Error?
        )
    {
    
        Task
        {
            [weak self] in
        
            do
            {
                try await self?.connection_executor.send(
                        .failure(ASB_error.failed_to_connect_to_peripheral(error)),
                        for_key: peripheral.identifier
                    )
            }
            catch
            {
                self?.manager_event = .no_continuation_for_did_failt_to_connect(
                        peripheral.id, error: error
                    )
            }
        }
    
    }
    
    
    /**
     * Cancels an active or pending local connection to a peripheral.
     */
    public func cancel_peripheral_connection(
            _ peripheral: ASB_peripheral
        ) async throws
    {
        
        if await disconnection_executor.has_work(peripheral.id)
        {
            throw ASB_error.disconnecting_in_progress
        }
        
        if (peripheral.state == CBPeripheralState.connecting) ||
           (peripheral.state == CBPeripheralState.connected)
        {
            try await disconnection_executor.submit(peripheral.id)
            {
                [weak self] in
            
                self?.CB_central_manager.cancelPeripheralConnection(
                        peripheral.cbPeripheral
                    )
            }
        }
        
    }
    
    
    /**
     * Tells the delegate that the central manager disconnected from a
     * peripheral.
     */
    public func centralManager(
            _                       cbCentralManager : CBCentralManager,
            didDisconnectPeripheral peripheral       : CBPeripheral,
                                    error            : Error?
        )
    {
        
        Task
        {
            [weak self] in
            
            guard let self = self else { return }
            
            if await self.disconnection_executor.has_work(peripheral.id)
            {
                do
                {
                    try await self.disconnection_executor.send(
                            (error == nil) ? .success(()) : .failure(error!),
                            for_key : peripheral.identifier
                        )
                }
                catch
                {
                    self.manager_event = .no_continuation_for_did_disconnect(
                            peripheral.id, error: error
                        )
                }
            }
            else
            {
                let peripheral_id   = peripheral.id
                let peripheral_name = peripheral.name ?? "-"
            
                self.manager_event = .peripheral_disconnected(
                        peripheral_id, name: peripheral_name, error: error
                    )
            }
        }
        
    }
    
    
    /**
     * Tells the delegate that a connection event occurred which matches
     * the registered options.
     */
    public func centralManager(
            _                        cbCentralManager : CBCentralManager,
            connectionEventDidOccur  event            : CBConnectionEvent,
            for                      peripheral       : CBPeripheral
        )
    {
        // TODO: Implement code
    }
    
    
    // MARK: - Retrieving Lists of Peripherals
    
    
    /**
     * Returns a list of known peripherals by their identifiers.
     */
    public func retrieve_peripherals(
            _  identifiers: [UUID]
        ) -> [ASB_peripheral]
    {
    
        return CB_central_manager.retrievePeripherals(withIdentifiers: identifiers)
            .map { ASB_peripheral($0) }
    
    }
    
    
    /**
     * Returns a list of the peripherals connected to the system whose services
     * match a given set of criteria.
     */
    public func retrieve_connected_peripherals(
            _ service_UUIDs: [CBUUID]
        ) -> [ASB_peripheral]
    {
    
        return CB_central_manager.retrieveConnectedPeripherals(
                withServices: service_UUIDs
            )
            .map { ASB_peripheral($0) }
    
    }
    
    
    // MARK: - Scanning or Stopping Scans of Peripherals
    
    
    /**
     * Scans for peripherals that are advertising services.
     *
     */
    public func scan_for_peripherals(
            _  service_UUIDs : [CBUUID]?       = nil,
            _  options       : [String : Any]? = nil
        ) async -> AsyncThrowingStream<ASB_discovered_peripheral, Error>
    {
        
        return await peripheral_scanning_executor.create(
            on_termination:
            {
                [weak self] in
                
                self?.CB_central_manager.stopScan()
            },
            on_start:
            {
                [weak self] in
                
                self?.CB_central_manager.scanForPeripherals(
                    withServices: service_UUIDs, options: options
                )
            }
        )
        
    }
    
    
    /**
     * A new BLE peripheral has been discovered nearby
     */
    public func centralManager(
            _            cbCentralManager  : CBCentralManager,
            didDiscover  cbPeripheral      : CBPeripheral,
                         advertisementData : [String : Any],
            rssi         RSSI              : NSNumber
        )
    {
        
        Task
        {
            [weak self] in
            
            let peripheral = ASB_discovered_peripheral(
                peripheral         : ASB_peripheral(cbPeripheral),
                advertisement_data : advertisementData,
                rssi               : RSSI
            )
            
            await self?.peripheral_scanning_executor.yield(peripheral)
        }
        
    }
    
    
    /**
     * Asks the central manager to stop scanning for peripherals.
     */
    public func stop_scan() async
    {
        
        await peripheral_scanning_executor.finish()
        
    }
    
    
    /**
     * A Boolean value that indicates whether the central is
     * currently scanning.
     */
    public var is_scanning: Bool
    {
        
        CB_central_manager.isScanning
        
    }
    
    
    // MARK: - Private state
    
    
    private var CB_central_manager : CBCentralManager!
    
    
    // MARK: - Private Services that serialise access to processes
    
    
    /**
     * Actor that serialises events that handle the change of state
     * for the CBCentralManager
     */
    private lazy var manager_state_executor = Asynchronous_serial_executor<Void>()
    
    /**
     * Manages the process of scanning for new peripherals
     */
    private var peripheral_scanning_executor = Asynchronous_data_stream<ASB_discovered_peripheral>()
    
    /**
     * Serialise connection to a peripheral
     */
    private lazy var connection_executor    = Asynchronous_executor_hashmap<CBPeripheral.ID_type, Void>()
    
    /**
     * Serialise discconnection to a peripheral
     */
    private lazy var disconnection_executor = Asynchronous_executor_hashmap<CBPeripheral.ID_type, Void>()
    
    
    // MARK: - Private methods
    
    
    /**
     * Check if a given CBManagerState represents that the Bluetooth stack
     * is accesible, ready to be used
     *
     * - Returns: Denpending of the CBManagerState, it will return
     *            success when `poweredOn
     *            failure when `unsupported`, `unauthorized` or `poweredOff`
     *            nil for `unknown` or `resetting`.
     */
    private func is_bluetooth_accessible(
            for  state : CBManagerState
        ) -> Result<Void, Error>?
    {
        
        let result: Result<Void, Error>?
        
        switch state
        {
            case .poweredOn:
                result = .success( () )
                
            case .unsupported, .unauthorized, .poweredOff:
                result = .failure(ASB_error.bluetoothUnavailable)
                
            case .unknown, .resetting:
                result = nil
                
            @unknown default:
                result = .failure(ASB_error.bluetoothUnavailable)
        }
        
        return result
        
    }

}
