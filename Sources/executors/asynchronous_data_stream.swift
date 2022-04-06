/**
 * \file    asynchronous_data_stream.swift
 * \author  Mauricio Villarroel
 * \date    Created: Jan 27, 2022
 * ____________________________________________________________________________
 *
 * Copyright (C) 2022 Mauricio Villarroel. All rights reserved.
 *
 * SPDX-License-Identifer:  GPL-2.0-only
 * ____________________________________________________________________________
 */

import Foundation


/**
 * Actor that creates, starts and manages the process
 * of scanning for BLE peripherals.
 *
 * If you call the `startScan` function while the central manager is
 * already scanning, it will finish the previoys scan and restart a new
 * scan with the new parameters
 *
 * - Element : The type of the item that the sequence will produces
 */
final actor Asynchronous_data_stream<Element>
{
    
    func create(
            on_termination : @escaping () async throws -> Void,
            on_start       : @escaping () async throws -> Void
        ) -> AsyncThrowingStream<Element, Error>
    {
        
        return  AsyncThrowingStream
        {
            
            continuation in

            
            continuation.onTermination =
            {
                @Sendable _ in
                
                Task
                {
                    do
                    {
                        try await on_termination()
                    }
                    catch
                    {
                        print("Error terminating AsyncStream: " +
                              error.localizedDescription
                            )
                    }
                    
                    await self.set_continuation(nil)
                }
            }
            
            
            Task
            {
                do
                {
                    if stream_continuation != nil
                    {
                        throw ASB_error.scanning_in_progress
                    }
                    else
                    {
                        set_continuation(continuation)
                        try await on_start()
                    }
                }
                catch let error as ASB_error
                {
                    continuation.finish(throwing: error)
                }
                catch
                {
                    continuation.finish(throwing: ASB_error.unknown_error(
                        description: "Error starting AsyncStream: " +
                                     error.localizedDescription
                        ))
                }
            }
            
        }
        
    }
    
    
    /**
     * End the stream
     */
    func finish()
    {
        
        stream_continuation?.finish()
        
    }
    
    
    /**
     * End the stream
     */
    func finish( throwing error : Error? = nil )
    {
        
        stream_continuation?.finish(throwing: error)
        
    }
    
    
    /**
     * A new value has been read
     */
    func yield( _ value : Element )
    {
        
        stream_continuation?.yield(value)
        
    }
    
    
    /**
     * A new result has been read
     */
    func yield( with result : Result<Element, Error> )
    {
        
        stream_continuation?.yield(with: result)
        
    }
    
    
    // MARK: - Private state
    
    
    private var stream_continuation : AsyncThrowingStream<Element, Error>.Continuation?
    
    
    // MARK: - Private interface
    
    
    /**
     * Set the continuation for the scannig AsyncStream
     */
    private func set_continuation(
            _  continuation : AsyncThrowingStream<Element, Error>.Continuation?
        )
    {
        
        stream_continuation = continuation
        
    }
    
    
}
