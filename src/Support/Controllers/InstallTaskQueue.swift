//
//  InstallTaskQueue.swift
//  Support
//
//  Created by Jordy Witteman on 21/05/2025.
//

import Foundation

class InstallTaskQueue {
    
    // Create singleton
    static let shared = InstallTaskQueue()
    
    // Create queue
    let queue = Queue()
    
    actor Queue {
        private var tasks: [(id: String, task: () async -> Void)] = []
        private var cancelledTaskIDs: Set<String> = []
        private var isRunning = false

        func enqueue(id: String, _ task: @escaping () async -> Void) {
            tasks.append((id, task))

            // Check if current task is running before running the next task
            if !isRunning {
                isRunning = true
                Task {
                    await runNext()
                }
            }
        }
        
        func cancel(_ id: String) {
            cancelledTaskIDs.insert(id)
        }
        
        // Run tasks
        private func runNext() async {
            while !tasks.isEmpty {
                let (id, task) = tasks.removeFirst()
                if !cancelledTaskIDs.contains(id) {
                    await task()
                }
                cancelledTaskIDs.remove(id)
            }
            isRunning = false
        }
    }
    
    // Function to add new tasks
    func submit(id: String, task: @escaping () async -> Void) async {
        await queue.enqueue(id: id, task)
    }

    // Function to cancel task based on ID
    func cancel(taskID: String) async {
        await queue.cancel(taskID)
    }
}
