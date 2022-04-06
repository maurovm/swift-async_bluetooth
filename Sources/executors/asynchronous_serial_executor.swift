/**
 * \file    asynchronous_serial_executor.swift
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
 * Executes queued work serially, in the order they where added (FIFO).
 *
 * After work has started, this class will await until the client completes
 * it before taking on the next work.
 *
 * - Value: ???
 */
final actor Asynchronous_serial_executor<Value>
{
    
    /**
     * Check whether we're executing or have queued work.
     */
    var has_job : Bool
    {
        is_executing_job || job_queue.count > 0
    }
    
    
    /**
     * Class destructor
     */
    deinit
    {
        
        if has_job
        {
            broadcast( .failure(Executor_error.executor_deinitialised) )
        }
        
    }
    
    
    /**
     * Places work in the queue to be executed. If the queue is empty
     * it will be executed. Otherwise it will get dequeued (and executed)
     * when all previously queued work has finished.
     *
     * This function will await until the given block is executed and will
     * only resume after clients provide a Result via
     * `setWorkCompletedWithResult` or `flush`
     *
     * - Note: No other work will be executed while there's a work in progress.
     *
     *  - block : The code block to run
     */
    func submit(
            _  job : @Sendable @escaping () -> Void
        ) async throws -> Value
    {
        
        let job_id = UUID()
        
        return try await withTaskCancellationHandler
        {
            
            Task.detached
            {
                [weak self] in
                await self?.cancel_job(job_id)
            }
            
        }
        operation:
        {
            
            try await withCheckedThrowingContinuation
            {
                continuation in
                
                job_queue.append(
                        Asynchronous_job(
                            id          : job_id,
                            function    : job,
                            continuation: continuation
                        )
                    )
                
                schedule_next_queued_job_for_execution()
            }
            
        }
        
    }
    
    
    /**
     * Completes the current work with the given result and dequeues
     * the next queued work.
     */
    func send( _ result : Result<Value, Error> ) throws
    {
        
        defer
        {
            schedule_next_queued_job_for_execution()
        }
        
        if let job = current_job
        {
            job.continuation.resume(with: result)
            current_job = nil
        }
        else
        {
            throw Executor_error.no_job_to_execute
        }
        
    }
    
    
    /**
     * Sends the given result to all queued and executing work.
     */
    func broadcast( _ result: Result<Value, Error> )
    {
        
        current_job?.continuation.resume(with: result)
        current_job = nil
        
        for job in job_queue
        {
            job.continuation.resume(with: result)
        }
    
        job_queue.removeAll()
        
    }
    
    
    // MARK: - Private state
    
    
    private var current_job : Asynchronous_job<Value>?  = nil
    private var job_queue   : [Asynchronous_job<Value>] = []
    
    
    private var is_executing_job: Bool
    {
        current_job != nil
    }
    
    
    // MARK: - Private interface
    
    
    private func schedule_next_queued_job_for_execution()
    {
        
        Task.detached
        {
            await self.execute_next_queued_job()
        }
        
    }
    
    
    /**
     * Grabs the next available work from the queue. If it's not canceled,
     * executes it. Otherwise sends a `AsyncSerialExecutor.canceled` error.
     */
    private func execute_next_queued_job()
    {
        
        if is_executing_job || job_queue.isEmpty
        {
            return
        }
        
        let job = job_queue.removeFirst()
        
        if job.is_cancelled
        {
            job.continuation.resume(throwing: Executor_error.job_cancelled)
            // TODO: Check if this sentence won't create a recursive Task loop hell
            schedule_next_queued_job_for_execution()
        }
        else
        {
            current_job = job
            job.function()
            // TODO: Should we run "self.currentWork = nil" after "work" finishes?
        }
        
    }

    
    /**
     * Cancels the work with the given ID. If the work is executing it
     * will be immediately canceled. If it's queued, the work will get
     * flagged and once its dequeued, it will get canceled without executing.
     */
    private func cancel_job( _ job_id: UUID )
    {
        
        if let job = current_job ,
           job.id == job_id
        {
            
            job.continuation.resume(throwing: Executor_error.job_cancelled)
            current_job = nil
            schedule_next_queued_job_for_execution()
            
        }
        else if let index = job_queue.firstIndex(where: { $0.id == job_id })
        {
            job_queue[index].is_cancelled = true
        }
        
    }

}
