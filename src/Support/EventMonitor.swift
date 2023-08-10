//
//  EventMonitor.swift
//  Support
//
//  Created by Jordy Witteman on 02/09/2020.
//

import Cocoa
import os

// Monitor mouse clicks
public class EventMonitor {
    
    let logger = Logger(subsystem: "nl.root3.support", category: "EventMonitor")
    
    private var monitor: Any?
    private let mask: NSEvent.EventTypeMask
    private let handler: (NSEvent?) -> Void

    public init(mask: NSEvent.EventTypeMask, handler: @escaping (NSEvent?) -> Void) {
        self.mask = mask
        self.handler = handler
    }
    
    deinit {
        stop()
    }
    
    public func start() {
        logger.debug("EventMonitor started")
        monitor = NSEvent.addGlobalMonitorForEvents(matching: mask, handler: handler)
    }
    
    public func stop() {
        if monitor != nil {
            logger.debug("EventMonitor stopped")
            NSEvent.removeMonitor(monitor!)
            monitor = nil
        }
    }
}
