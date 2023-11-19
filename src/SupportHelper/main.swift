//
//  main.swift
//  nl.root3.support.helper
//
//  Created by Jordy Witteman on 18/11/2023.
//

import Foundation
import os

var logger = Logger(subsystem: "nl.root3.support.helper", category: "SupportHelper")

logger.debug("SupportHelper started")
let supportHelper = SupportHelper()
supportHelper.run()
