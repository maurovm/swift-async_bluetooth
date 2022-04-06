/**
 * \file    executor_error.swift
 * \author  Mauricio Villarroel
 * \date    Created: Jan 30, 2022
 * ____________________________________________________________________________
 *
 * Copyright (C) 2022 Mauricio Villarroel. All rights reserved.
 *
 * SPDX-License-Identifer:  GPL-2.0-only
 * ____________________________________________________________________________
 */

import Foundation


/**
 * Errors that the different executors throw while executing a given job
 */
public enum Executor_error : Error
{
    
    case no_job_to_execute
    
    case job_cancelled
    
    case executor_deinitialised
    
    case executor_not_found
    
    
    /**
     * Readable descriptin of the error, often used to log error to the screen
     */
    public var description : String
    {
        let message : String
        
        switch self
        {
            case .no_job_to_execute:
                message = "The job to execute"
                
            case .job_cancelled:
                message = "The job has been cancelled"
                
            case .executor_deinitialised:
                message = "The executor has been deinitialised"
                
            case .executor_not_found:
                message = "Could not find executor"
        }
        
        return message
    }
    
}
