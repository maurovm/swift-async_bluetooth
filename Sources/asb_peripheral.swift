/**
 * \file    ASB_peripheral.swift
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
import Combine


/**
 * A remote peripheral device.
 * 
 * - This class acts as a wrapper around ``CBPeripheral``
 */
public final class ASB_peripheral: Identifiable, Equatable, Hashable
{
    
    @Published public private(set) var peripheral_event : ASB_peripheral_event
    
    /**
     * Class initialiser
     */
    public init( _  cb_peripheral : CBPeripheral )
    {
        
        delegate = Peripheral_delegate(cb_peripheral)
        peripheral_event = delegate.peripheral_event
        
        delegate.$peripheral_event.assign(to: &$peripheral_event)
        
    }
    
    
    // MARK: - Equatable and Hashable protocol conformance
    
    
    /**
     * Conformance to the Hashable protocol
     */
    public func hash( into hasher: inout Hasher )
    {
        
        hasher.combine(id)
        
    }
    
    
    /**
     * Compare if two peripherals are describing the same device
     */
    public static func == (
            lhs : ASB_peripheral,
            rhs : ASB_peripheral
        ) -> Bool
    {
        
        return lhs.id == rhs.id
        
    }
    
    
    public func isEqual(
            _  object : Any?
        ) -> Bool
    {
        
        if let other = object as? ASB_peripheral
        {
            return self.id == other.id
        }
        else
        {
            return false
        }
        
    }
    
    
    // MARK: - Identifying a Peripheral
    
    
    /**
     * Convinence shortcut to the original peripheral's identifier
     */
    public var id: CBPeripheral.ID_type
    {
        delegate.id
    }
    
    
    /**
     * The name of the peripheral.
     */
    public var name: String
    {
        delegate.name
    }
    
    
    // MARK: - Discovering Services
    
    
    /**
     * Async version to discover the specified services of the peripheral.
     */
    public func discover_services(
            _  service_UUIDs : [CBService.ID_type]? = nil
        ) async throws -> [CBService]
    {
        
        return try await delegate.discover_services(service_UUIDs)
        
    }
    
    
    /**
     * A list of a peripheral’s services.
     */
    public var services: [CBService]?
    {
        delegate.services
    }
    
    
    /**
     * Discovers the specified included services of a
     * previously-discovered service.
     */
    public func discover_included_services(
            _    service_UUIDs : [CBService.ID_type]?,
            for  service      : CBService
        ) async throws -> [CBService]
    {
        
        return try await delegate.discover_included_services(
                service_UUIDs, for: service
            )
        
    }
    
    
    // MARK: - Discovering Characteristics and Descriptors
    
    
    /**
     * Discovers the specified characteristics of a service.
     */
    public func discover_characteristics(
            _    characteristic_UUIDs : [CBUUID]?,
            for  service              : CBService
        ) async throws -> [CBCharacteristic]
    {
        
        return try await delegate.discover_characteristics(
                characteristic_UUIDs, for: service
            )
        
    }
    
    
    /**
     * Discovers the descriptors of a characteristic.
     */
    public func discover_descriptors(
            for  characteristic : CBCharacteristic
        ) async throws -> [CBDescriptor]
    {
        
        return try await delegate.discover_descriptors(for: characteristic)
        
    }
    
    
    // MARK: - Reading Characteristic and Descriptor Values
    
    
    /**
     * Retrieves the value of a specified characteristic.
     */
    public func read_value(
            for  characteristic : CBCharacteristic
        ) async throws -> ASB_data
    {
        
        return try await delegate.read_value(for: characteristic)
        
    }
    
         
    /**
     * Retrieves the value of a specified characteristic descriptor.
     */
    public func read_value(
            for  descriptor : CBDescriptor
        ) async throws -> Any
    {
        
        return try await delegate.read_value(for: descriptor)
        
    }
    
    
    // MARK: - Writing Characteristic and Descriptor Values
    
    
    /**
     * Writes the value of a characteristic.
     */
    public func write_value(
            _    data           : Data,
            for  characteristic : CBCharacteristic,
                 type           : CBCharacteristicWriteType
        ) async throws
    {
        
        try await delegate.write_value(data, for: characteristic, type: type)
        
    }
    
    
    /**
     * Writes the value of a characteristic descriptor.
     */
    public func write_value(
            _    data       : Data,
            for  descriptor : CBDescriptor
        ) async throws
    {
        
        try await delegate.write_value(data, for: descriptor)
        
    }
    
    
    /**
     * The maximum amount of data, in bytes, you can send to a characteristic
     * in a single write type.
     */
    public func maximum_write_value_length(
            for type: CBCharacteristicWriteType
        ) -> Int
    {
        
        return delegate.maximum_write_value_length(for: type)
        
    }
    
    
    // MARK: - Notifications for a Characteristic’s Value
    
    
    /**
     * Sets notifications or indications for the value of a
     * specified characteristic.
     */
    public func notification_values(
            for  characteristic : CBCharacteristic
        ) async throws -> AsyncThrowingStream<ASB_data, Error>
    {
        
        return try await delegate.notification_values(for: characteristic)
        
    }
    
    
    public func stop_notifications(
            from  characteristic : CBCharacteristic
        ) async
    {
        
        await delegate.stop_notifications(from: characteristic)
        
    }
    
    
    public func stop_notifications_from_all_characteristics() async
    {
        
        await delegate.stop_notifications_from_all_characteristics()
        
    }
    
    
    // MARK: - Working with Apple Notification Center Service (ANCS)
    
    
    /**
     * A Boolean value that indicates if the remote device has authorization
     * to receive data over ANCS protocol.
     */
    public var ANCS_authorized: Bool
    {
        delegate.ANCS_authorized
    }

    
    // MARK: - Monitoring a Peripheral’s Connection State
    
    
    public var is_connected : Bool
    {
        delegate.is_connected
    }
    
    
    /**
     * The connection state of the peripheral.
     */
    public var state: CBPeripheralState
    {
        delegate.state
    }
    
    
    /**
     * A Boolean value that indicates whether the remote device can send
     * a write without a response.
     */
    public var can_send_write_without_response: Bool
    {
        delegate.can_send_write_without_response
    }
    
    
    // MARK: - Accessing a Peripheral’s Signal Strength
    
    
    /**
     * Retrieves the current RSSI value for the peripheral while connected
     * to the central manager.
     */
    public func read_RSSI() async throws -> NSNumber
    {
        
        return try await delegate.read_RSSI()
        
    }
    
    
    // MARK: - Working with L2CAP Channels
    
    
    /**
     * Attempts to open an L2CAP channel to the peripheral using the
     * supplied Protocol/Service Multiplexer (PSM).
     */
    @available(iOS 11.0, *)
    public func open_L2CAP_channel( _  PSM : CBL2CAPPSM ) async throws
    {
        
        try await delegate.open_L2CAP_channel(PSM)
        
    }
    
    // MARK: - Internal module state
    
    
    /**
     * The underlying CoreBluetooth peripheral.
     * This is only used by internal classes of the module
     */
    internal var cbPeripheral: CBPeripheral
    {
        delegate.CB_peripheral
    }
    
    
    // MARK: - Private state

    
    private let delegate : Peripheral_delegate
    
}
