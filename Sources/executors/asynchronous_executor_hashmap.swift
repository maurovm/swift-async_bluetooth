/**
 * \file    asynchronous_executor_hashmap.swift
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
 * Executes jobs in parallel when keys are different, and serially when
 * there's work queued for a given key. After the job for a given key has
 * started, this class will await until the client completes it before taking
 * on the next job for that key.
 */
actor Asynchronous_executor_hashmap<Hash_key, Value> where Hash_key: Hashable
{
    
    /**
     * Places job in the queue for the given key to be executed.
     * If the queue is empty it will be executed. Otherwise it will get
     * dequeued (and executed) when all previously queued work has finished.
     *
     * - Note: Once the job is executed, the task will be waiting until
     *         clients provide a Result via `setWorkCompletedForKey`.
     *         No other work will be executed during this time.
     */
    func submit(
            _  key : Hash_key,
               job : @Sendable @escaping () -> Void
        ) async throws -> Value
    {
        
        let executor = self.all_executors[key] ??
            {
                let executor = Asynchronous_serial_executor<Value>()
                self.all_executors[key] = executor
                return executor
            }()

        return try await executor.submit(job)
        
    }
    
    
    /**
     * Completes the current work for the given key.
     */
    func send(
            _        result : Result<Value, Error>,
            for_key  key    : Hash_key
        ) async throws
    {
        
        guard let executor = all_executors[key]
            else
            {
                throw Executor_error.executor_not_found
            }
        
        try await executor.send(result)
        
        if await executor.has_job == false
        {
            all_executors[key] = nil
        }
        
    }
    
    
    /**
     * Sends the given result to all queued and executing work for a given
     * key
     */
    func broadcast(
            _        result : Result<Value, Error>,
            for_key  key    : Hash_key
        ) async throws
    {
        
        guard let executor = self.all_executors[key]
            else
            {
                throw Executor_error.executor_not_found
            }

        await executor.broadcast(result)
        
        if await executor.has_job == false
        {
            all_executors[key] = nil
        }
        
    }
    
    
    /**
     * Check whether we're executing or have queued work for the given key
     */
    func has_work( _  key : Hash_key ) async -> Bool
    {
        
        await (all_executors[key]?.has_job == true)
        
    }
    
    
    // MARK: - Private state
    
    
    private var all_executors: [Hash_key: Asynchronous_serial_executor<Value>] = [:]
    
}
