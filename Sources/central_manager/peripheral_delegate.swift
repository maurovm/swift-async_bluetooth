/**
 * \file    peripheral_delegate.swift
 * \author  Mauricio Villarroel
 * \date    Created: Mar 28, 2022
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
 * - This class acts as a wrapper around "CBPeripheral"
 */
final class Peripheral_delegate : NSObject, CBPeripheralDelegate
{
    
    @Published public private(set) var peripheral_event : ASB_peripheral_event =
        .no_set
    
    
    /**
     * The underlying CoreBluetooth peripheral.
     * This is only used by internal classes of the module
     */
    let CB_peripheral: CBPeripheral
    
    
    
    /**
     * Class initialiser
     */
    init( _  cbPeripheral : CBPeripheral )
    {
        
        self.CB_peripheral = cbPeripheral
        
        super.init()
        
        
        if let _ = cbPeripheral.delegate as? Peripheral_delegate
        {
            // TODO: already has the correct delegate. I don't know why this
            // happens
        }
        else if let cb_delegate = cbPeripheral.delegate
        {
            peripheral_event = .different_delegate_class(
                    CB_peripheral.id,
                    class_name: String(describing: cb_delegate.self)
                )
        }
        else
        {
            self.CB_peripheral.delegate = self
        }
        
    }
    
    
    /**
     * Clean up resources
     */
    deinit
    {
        
        characteristic_data_streams.removeAll()
        
    }
    
    
    // MARK: - Identifying a Peripheral
    
    
    /**
     * Convinence shortcut to the original peripheral's identifier
     */
    var id: CBPeripheral.ID_type
    {
        CB_peripheral.identifier
    }
    
    
    /**
     * The name of the peripheral.
     */
    var name: String
    {
        CB_peripheral.name ?? ""
    }
    
    
    // MARK: - Discovering Services
    
    
    /**
     * Async version to discover the specified services of the peripheral.
     */
    func discover_services(
            _  service_UUIDs : [CBService.ID_type]? = nil
        ) async throws -> [CBService]
    {
        
        return try await service_discovery_executor.submit
        {
            [weak self] in
            
            self?.CB_peripheral.discoverServices(service_UUIDs)
        }
        
    }
    
    
    /**
     * A list of a peripheral’s services.
     */
    var services: [CBService]?
    {
        CB_peripheral.services
    }
    
    
    /**
     * Tells the delegate that peripheral service discovery succeeded
     */
    func peripheral(
            _                    cbPeripheral : CBPeripheral,
            didDiscoverServices  error        : Error?
        )
    {
        
        Task
        {
            [weak self] in
            
            do
            {
                if let cb_error = error
                {
                    
                    let discovery_error =
                        ASB_error.failed_to_discover_service(cb_error)
                    
                    try await self?.service_discovery_executor.send(
                            .failure(discovery_error)
                        )
                }
                else
                {
                    let value = cbPeripheral.services ?? []
                    
                    try await self?.service_discovery_executor.send(
                            .success(value)
                        )
                }
            }
            catch
            {
                self?.peripheral_event = .no_continuation_for_service_discovery(
                        cbPeripheral.id, error: error
                    )
            }
        }
        
    }
    
    
    /**
     * Discovers the specified included services of a
     * previously-discovered service.
     */
    func discover_included_services(
            _    service_UUIDs : [CBUUID]?,
            for  service      : CBService
        ) async throws -> [CBService]
    {
        
        return try await included_services_discovery_executor.submit(service.id)
            {
                [weak self] in
                
                self?.CB_peripheral.discoverIncludedServices(
                        service_UUIDs, for: service
                    )
            }
        
    }
    
    
    /**
     * Tells the delegate that discovering included services within
     * the indicated service completed
     */
    func peripheral(
            _                               cbPeripheral : CBPeripheral,
            didDiscoverIncludedServicesFor  service      : CBService,
                                            error        : Error?
        )
    {
        
        Task
        {
            [weak self] in
            
            do
            {
                if let cb_error = error
                {
                    try await self?.included_services_discovery_executor.send(
                            .failure(cb_error), for_key: service.id
                        )
                }
                else
                {
                    let value = service.includedServices ?? []
                    
                    try await self?.included_services_discovery_executor.send(
                            .success(value), for_key: service.id
                        )
                }
            }
            catch
            {
                self?.peripheral_event = .no_continuation_for_included_service_discovery(
                        cbPeripheral.id, error: error
                    )
            }
        }
        
    }
    
    
    // MARK: - Discovering Characteristics and Descriptors
    
    
    /**
     * Discovers the specified characteristics of a service.
     */
    func discover_characteristics(
            _    characteristic_UUIDs : [CBUUID]?,
            for  service              : CBService
        ) async throws -> [CBCharacteristic]
    {
        
        return try await characteristic_discovery_executor.submit(service.id)
            {
                [weak self] in
                
                self?.CB_peripheral.discoverCharacteristics(
                        characteristic_UUIDs, for: service
                    )
            }
        
    }
    
    
    /**
     * Tells the delegate that the peripheral found characteristics
     * for a service
     */
    func peripheral(
            _                              cbPeripheral : CBPeripheral,
            didDiscoverCharacteristicsFor  service      : CBService,
                                           error        : Error?
        )
    {
        
        Task
        {
            [weak self] in
            
            do
            {
                if let cb_error = error
                {
                    let discovery_error =
                        ASB_error.failed_to_discover_characteristics(cb_error)
                    
                    try await self?.characteristic_discovery_executor.send(
                            .failure(discovery_error), for_key: service.id
                        )
                }
                else
                {
                    let value =  service.characteristics ?? []
                    
                    try await self?.characteristic_discovery_executor.send(
                            .success(value), for_key: service.id
                        )
                }
            }
            catch
            {
                self?.peripheral_event = .no_continuation_for_characteristic_discovery(
                        cbPeripheral.id, service_id: service.id, error: error
                    )
            }
        }
        
    }
    
    
    /**
     * Discovers the descriptors of a characteristic.
     */
    func discover_descriptors(
            for  characteristic : CBCharacteristic
        ) async throws -> [CBDescriptor]
    {
        
        return try await descriptor_discovery_executor.submit(characteristic.id)
            {
                [weak self] in
                
                self?.CB_peripheral.discoverDescriptors(for: characteristic)
            }
        
    }
    
    
    /**
     * Tells the delegate that the peripheral found descriptors
     * for a characteristic
     */
    func peripheral(
            _                          cbPeripheral   : CBPeripheral,
            didDiscoverDescriptorsFor  characteristic : CBCharacteristic,
                                       error          : Error?
        )
    {
        
        Task
        {
            [weak self] in
            
            do
            {
                if let cb_error = error
                {
                    
                    let discovery_error =
                        ASB_error.failed_to_discover_descriptor(cb_error)
                    
                    try await self?.descriptor_discovery_executor.send(
                            .failure(discovery_error),
                            for_key: characteristic.id
                        )
                }
                else
                {
                    let value =  characteristic.descriptors ?? []
                    
                    try await self?.descriptor_discovery_executor.send(
                            .success(value), for_key: characteristic.id
                        )
                }
            }
            catch
            {
                self?.peripheral_event = .no_continuation_for_descriptor_discovery(
                        cbPeripheral.id,
                        characteristic_id: characteristic.id,
                        error            : error
                    )
            }
        }
        
    }
    
    
    // MARK: - Reading Characteristic and Descriptor Values
    
    
    /**
     * Retrieves the value of a specified characteristic.
     */
    func read_value(
            for  characteristic : CBCharacteristic
        ) async throws -> ASB_data
    {
        
        return try await characteristic_value_reader_executor.submit(characteristic.id)
            {
                [weak self] in
                
                self?.CB_peripheral.readValue(for: characteristic)
            }
        
    }
    
    
    /**
      * Tells the delegate that retrieving the specified characteristic’s
      * value succeeded, or that the characteristic’s value changed
      */
     func peripheral(
             _                  cbPeripheral   : CBPeripheral,
             didUpdateValueFor  characteristic : CBCharacteristic,
                                error          : Error?
         )
     {
         
         let timestamp = current_timestamp()
         
         if characteristic.isNotifying
         {
             
             /**
               * Notify subscribers of the Async Stream that a new value
               * is available.
               *
               * Read the value from the characteristic and send it to the
               * data stream
               */
             Task
             {
                 [weak self] in
                 
                 guard let self = self ,
                       let data_stream = self.characteristic_data_streams[characteristic.id]
                    else
                    {
                        return
                    }
                 
                 
                 if let cb_error = error
                 {
                     await data_stream.yield(with: .failure(cb_error))
                 }
                 else if let value = characteristic.value
                 {
                     let data = ASB_data(timestamp: timestamp, data: value)
                     await data_stream.yield(data)
                 }
                 else
                 {
                     let ble_error = ASB_error.empty_characteristic_value
                     await data_stream.yield( with: .failure(ble_error) )
                 }
             }
             
         }
         else
         {
             
             // The characteristic is not notifying, just read the value

             Task
             {
                 [weak self] in
                 
                 guard let self = self ,
                       await self.characteristic_value_reader_executor.has_work(characteristic.id)
                     else
                     {
                         return
                     }
                 
                 
                 do
                 {
                     if let cb_error = error
                     {
                         try await self.characteristic_value_reader_executor.send(
                                .failure(cb_error), for_key: characteristic.id
                            )
                     }
                     else if let value = characteristic.value
                     {
                         let data = ASB_data(timestamp: timestamp, data: value)
                         
                         try await self.characteristic_value_reader_executor.send(
                                .success(data), for_key: characteristic.id
                            )
                     }
                     else
                     {
                         try await self.characteristic_value_reader_executor.send(
                                .failure(ASB_error.empty_characteristic_value),
                                for_key: characteristic.id
                             )
                     }
                 }
                 catch
                 {
                     self.peripheral_event = .failed_to_read_characteristic_value(
                             cbPeripheral.id, characteristic.id, error: error
                         )
                 }
             }
             
         }

     }

    
    /**
     * Retrieves the value of a specified characteristic descriptor.
     */
    func read_value( for  descriptor : CBDescriptor ) async throws -> Any
    {
        
        return try await descriptor_value_reader_executor.submit(descriptor.id)
            {
                [weak self] in
                
                self?.CB_peripheral.readValue(for: descriptor)
            }
        
    }
    
    
    /**
     * Tells the delegate that retrieving a specified characteristic
     * descriptor’s value succeeded
     */
    func peripheral(
            _                  cbPeripheral : CBPeripheral,
            didUpdateValueFor  descriptor   : CBDescriptor,
                               error        : Error?
        )
    {
        
        Task
        {
            [weak self] in
            
            guard let self = self ,
                  await self.descriptor_value_reader_executor.has_work(descriptor.id)
                else
                {
                    return
                }
            
            
            do
            {
                if let cb_error = error
                {
                    try await self.descriptor_value_reader_executor.send(
                            .failure(cb_error), for_key: descriptor.id
                        )
                }
                else if let value = descriptor.value
                {
                    try await self.descriptor_value_reader_executor.send(
                            .success(value), for_key: descriptor.id
                        )
                }
                else
                {
                    try await self.characteristic_value_reader_executor.send(
                           .failure(ASB_error.empty_descriptor_value),
                           for_key: descriptor.id
                        )
                }
            }
            catch
            {
                self.peripheral_event = .failed_to_read_descriptor_value(
                        cbPeripheral.id, descriptor.id, error: error
                    )
            }
        }
        
    }
    
    
    // MARK: - Writing Characteristic and Descriptor Values
    
    
    /**
     * Writes the value of a characteristic.
     */
    func write_value(
            _    data           : Data,
            for  characteristic : CBCharacteristic,
                 type           : CBCharacteristicWriteType
        ) async throws
    {
        
        try await characteristic_value_writer_executor.submit(characteristic.id)
            {
                [weak self] in
                
                guard let self = self else { return }
                
                self.CB_peripheral.writeValue(data, for: characteristic, type: type)
                
                if type == .withoutResponse
                {
                    self.peripheral(
                            self.CB_peripheral,
                            didWriteValueFor : characteristic,
                            error            : nil
                        )
                }
            }
        
    }
    
    
    /**
     * Tells the delegate that the peripheral successfully set a value
     * for the characteristic
     */
    func peripheral(
            _                 cbPeripheral   : CBPeripheral,
            didWriteValueFor  characteristic : CBCharacteristic,
                              error          : Error?
        )
    {
        
        Task
        {
            [weak self] in
            
            do
            {
                if let cb_error = error
                {
                    try await self?.characteristic_value_writer_executor.send(
                            .failure(cb_error), for_key: characteristic.id
                        )
                }
                else
                {
                    try await self?.characteristic_value_writer_executor.send(
                            .success(()), for_key: characteristic.id
                        )
                }
            }
            catch
            {
                self?.peripheral_event = .failed_to_write_characteristic_value(
                        cbPeripheral.id, characteristic.id, error: error
                    )
            }
        }
        
    }
    
    
    /**
     * Writes the value of a characteristic descriptor.
     */
    func write_value(
            _    data       : Data,
            for  descriptor : CBDescriptor
        ) async throws
    {
        
        try await descriptor_value_writer_executor.submit(descriptor.id)
            {
                [weak self] in
                
                self?.CB_peripheral.writeValue(data, for: descriptor)
            }
        
    }
    
    
    /**
     * Tells the delegate that the peripheral successfully set a value
     * for the descriptor
     */
    func peripheral(
            _                 cbPeripheral : CBPeripheral,
            didWriteValueFor  descriptor   : CBDescriptor,
                              error        : Error?
        )
    {
        
        Task
        {
            [weak self] in
            
            do
            {
                if let cb_error = error
                {
                    try await self?.descriptor_value_writer_executor.send(
                            .failure(cb_error), for_key: descriptor.id
                        )
                }
                else
                {
                    try await self?.descriptor_value_writer_executor.send(
                            .success(()), for_key: descriptor.id
                        )
                }
            }
            catch
            {
                self?.peripheral_event = .failed_to_write_descriptor_value(
                        cbPeripheral.id, descriptor.id, error: error
                    )
            }
        }
        
    }
    
    
    /**
     * The maximum amount of data, in bytes, you can send to a characteristic
     * in a single write type.
     */
    func maximum_write_value_length(
            for type: CBCharacteristicWriteType
        ) -> Int
    {
        
        return CB_peripheral.maximumWriteValueLength(for: type)
        
    }
    
    
    // MARK: - Setting Notifications for a Characteristic’s Value
    
    
    /**
     * Sets notifications or indications for the value of a
     * specified characteristic.
     */
    func notification_values(
            for  characteristic : CBCharacteristic
        ) async throws -> AsyncThrowingStream<ASB_data, Error>
    {
        
        if  characteristic_data_streams[characteristic.id] != nil
        {
            throw ASB_error.failed_to_enable_notifications
        }
        
        
        let data_stream = Asynchronous_data_stream<ASB_data>()
        characteristic_data_streams[characteristic.id] = data_stream
        
        
        return await data_stream.create(
            on_termination:
            {
                [weak self] in
                
                try await self?.set_peripheral_notification_value(
                        false, for: characteristic
                    )
            },
            on_start:
            {
                [weak self] in
                
                try await self?.set_peripheral_notification_value(
                        true, for: characteristic
                    )
                
                if characteristic.isNotifying == false
                {
                    throw ASB_error.failed_to_enable_notifications
                }
            }
        )
        
    }
    
    
    func stop_notifications( from characteristic : CBCharacteristic ) async
    {
        
        if let data_stream = characteristic_data_streams[characteristic.id]
        {
            await data_stream.finish()
            
            characteristic_data_streams.removeValue(forKey: characteristic.id)
        }
        
    }
    
    
    func stop_notifications_from_all_characteristics() async
    {
        
        for data_stream in characteristic_data_streams.values
        {
            await data_stream.finish()
        }
        
        characteristic_data_streams.removeAll()
        
    }
    
    
    /**
     * Sets notifications or indications for the value of a
     * specified characteristic.
     */
    private func set_peripheral_notification_value(
            _    enabled        : Bool,
            for  characteristic : CBCharacteristic
        ) async throws
    {

        try await notify_value_executor.submit(characteristic.uuid)
        {
            [weak self] in
            
            self?.CB_peripheral.setNotifyValue(enabled, for: characteristic)
        }
        
    }
    
    
    /**
     * Tells the delegate that the peripheral received a request to start
     * or stop providing notifications for a specified characteristic’s value
     */
    func peripheral(
            _                              cbPeripheral   : CBPeripheral,
            didUpdateNotificationStateFor  characteristic : CBCharacteristic,
                                           error          : Error?
        )
    {
        
        Task
        {
            [weak self] in
            
            guard let self = self ,
                  await self.notify_value_executor.has_work(characteristic.id)
                else
                {
                    return
                }
            
            
            do
            {
                let result: Result<Void, Error> = (error == nil) ?
                    .success(()) : .failure(error!)
                
                try await self.notify_value_executor.send(
                        result, for_key: characteristic.id
                    )
            }
            catch
            {
                self.peripheral_event = .failed_to_set_notify_value(
                        cbPeripheral.id, characteristic.id, error: error
                    )
            }
        }
        
    }
    
    
    // MARK: - Working with Apple Notification Center Service (ANCS)
    
    
    /**
     * A Boolean value that indicates if the remote device has authorization
     * to receive data over ANCS protocol.
     */
    var ANCS_authorized: Bool
    {
        CB_peripheral.ancsAuthorized
    }

    
    // MARK: - Monitoring a Peripheral’s Connection State
    
    
    var is_connected : Bool
    {
        CB_peripheral.state == .connected
    }
    
    
    /**
     * The connection state of the peripheral.
     */
    var state: CBPeripheralState
    {
        CB_peripheral.state
    }
    
    
    /**
     * A Boolean value that indicates whether the remote device can send
     * a write without a response.
     */
    var can_send_write_without_response: Bool
    {
        CB_peripheral.canSendWriteWithoutResponse
    }
    
    
    // MARK: - Accessing a Peripheral’s Signal Strength
    
    
    /**
     * Retrieves the current RSSI value for the peripheral while connected
     * to the central manager.
     */
    func read_RSSI() async throws -> NSNumber
    {
        
        return try await RSSI_reader_executor.submit
            {
                [weak self] in
                
                self?.CB_peripheral.readRSSI()
            }
        
    }
    
    
    /**
     * Tells the delegate that retrieving the value of the peripheral’s
     * current Received Signal Strength Indicator (RSSI) succeeded
     */
    func peripheral(
            _            cbPeripheral : CBPeripheral,
            didReadRSSI  RSSI         : NSNumber,
                         error        : Error?
        )
    {
        
        Task
        {
            [weak self] in
            
            do
            {
                if let cb_error = error
                {
                    try await self?.RSSI_reader_executor.send(.failure(cb_error))
                }
                else
                {
                    try await self?.RSSI_reader_executor.send(.success(RSSI))
                }
            }
            catch
            {
                self?.peripheral_event = .no_continuation_for_RSSI_reader(
                        cbPeripheral.id, error: error
                    )
            }
        }
        
    }
    
    
    // MARK: - Working with L2CAP Channels
    
    
    /**
     * Attempts to open an L2CAP channel to the peripheral using the
     * supplied Protocol/Service Multiplexer (PSM).
     */
    @available(iOS 11.0, *)
    func open_L2CAP_channel( _  PSM : CBL2CAPPSM ) async throws
    {
        
        try await L2CAP_channel_executor.submit
        {
            [weak self] in
            
            self?.CB_peripheral.openL2CAPChannel(PSM)
        }
        
    }
    
    /**
     * Delivers the result of an attempt to open an L2CAP channel
     */
    func peripheral(
            _        cbPeripheral : CBPeripheral,
            didOpen  channel      : CBL2CAPChannel?,
                     error        : Error?
        )
    {
        
        Task
        {
            [weak self] in
            
            do
            {
                if let cb_error = error
                {
                    try await self?.L2CAP_channel_executor.send(.failure(cb_error))
                }
                else
                {
                    try await self?.L2CAP_channel_executor.send(.success(()))
                }
            }
            catch
            {
                self?.peripheral_event = .no_continuation_for_L2CAP_channel(
                        cbPeripheral.id, error: error
                    )
            }
        }
        
    }

    
    // MARK: - Private custom executors that serialise access to processes
    
    
    
    
    private lazy var service_discovery_executor           = Asynchronous_serial_executor<[CBService]>()
    
    private lazy var included_services_discovery_executor = Asynchronous_executor_hashmap<CBService.ID_type, [CBService]>()
    
    private lazy var characteristic_discovery_executor    = Asynchronous_executor_hashmap<CBCharacteristic.ID_type, [CBCharacteristic]>()
    
    private lazy var characteristic_value_reader_executor = Asynchronous_executor_hashmap<CBCharacteristic.ID_type, ASB_data>()
    
    private lazy var characteristic_value_writer_executor = Asynchronous_executor_hashmap<CBCharacteristic.ID_type, Void>()
    
    private lazy var notify_value_executor = Asynchronous_executor_hashmap<CBUUID, Void>()
    
    /**
     * Manages the process subscribing to characteristic notifications
     */
    private var characteristic_data_streams : [ CBCharacteristic.ID_type : Asynchronous_data_stream<ASB_data>] = [:]
    
    
    private lazy var descriptor_discovery_executor    = Asynchronous_executor_hashmap<CBDescriptor.ID_type, [CBDescriptor]>()
    
    private lazy var descriptor_value_reader_executor = Asynchronous_executor_hashmap<CBDescriptor.ID_type, Any>()
    
    private lazy var descriptor_value_writer_executor = Asynchronous_executor_hashmap<CBDescriptor.ID_type, Void>()
    
    
    private lazy var RSSI_reader_executor   = Asynchronous_serial_executor<NSNumber>()
    
    private lazy var L2CAP_channel_executor = Asynchronous_serial_executor<Void>()
    
    
    // MARK: - Private interface
    
    
    /**
     * Return the curent epoch/Unix timestamp in nanoseconds
     */
    @inline(__always)
    private func current_timestamp() -> ASB_timestamp
    {
        
        let epoch = Date().timeIntervalSince1970
        return ASB_timestamp( epoch * 1_000_000_000 )
        
    }
    
}
