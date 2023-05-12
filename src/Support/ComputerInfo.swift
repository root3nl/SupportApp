//
//  ComputerInfo.swift
//  Root3 Support
//
//  Created by Jordy Witteman on 31/07/2020.
//

import CoreWLAN
import Foundation
import IOKit
import os
import SwiftUI

// Class to publish computer info updates from variables to ContentView
class ComputerInfo: ObservableObject {
    
    // Expirimental view with link to password change view
    @Published var showPasswordChange = false
    
    // Get preferences or default values
    @ObservedObject var preferences = Preferences()
    
    // Unified logging for ComputerInfo
    let logger = Logger(subsystem: "nl.root3.support", category: "ComputerInfo")
    
    // Get the macOS version. We only have to get these values once because it is static
    let systemVersionMajor = ProcessInfo.processInfo.operatingSystemVersion.majorVersion
    let systemVersionMinor = ProcessInfo.processInfo.operatingSystemVersion.minorVersion
    let systemVersionPatch = ProcessInfo.processInfo.operatingSystemVersion.patchVersion
    
    // Initialize some needed values
    var capacity = Double()
    var totalCapacity = Double()
    var modelIdentifier = String()

    // Get Available Software Updates
    @AppStorage("LastUpdatesAvailable", store: UserDefaults(suiteName: "com.apple.SoftwareUpdate")) var updatesAvailable: Int = 0
    
    // Number of major macOS Software Updates
    @Published var majorVersionUpdates: Int = 0
    
    // Computer name
    @Published var hostname = String()
    
    // macOS Version Name
    @Published var macOSVersionName = String()
    
    // Rounded uptime
    @Published var uptimeRounded = Int()
    
    // Text after uptime such as minutes, hours or days
    @Published var uptimeText = String()
    
    // Boolean to activate notification badge when uptime limit is reached
    @Published var uptimeLimitReached = Bool()
    
    // Boolean to activate notification badge when storage limit is reached
    @Published var storageLimitReached = Bool()
    
    // Available capacity in bytes
    @Published var capacityRounded = String()
    
    // Total capacity in bytes
    @Published var totalCapacityRounded = String()
    
    // Used capacity in percentage used in bar length
    @Published var capacityPercentage = CGFloat()
    
    // Used capacity in percentage to show user
    @Published var capacityPercentageRounded = Double()
    
    // SF Symbols icon for Computer Name depending on Model Identifier or Model Name. Default is "desktopcomputer"
    @Published var computerNameIcon = "desktopcomputer"
    
    // Mac Model Name
    @Published var modelName = ""
    
    // Mac Short Model Name
    @Published var modelShortName = ""
    
    // Mac Model Year
    @Published var modelYear = ""
    
    // Mac Model Name to display
    @Published var modelNameString = ""
    
    // IP address of the currently first active interface
    @Published var ipAddress = String()
    
    // Network interface type to set the appropriate symbol
    @Published var networkInterfaceSymbol = "wifi.slash"
    
    // Boolean to activate notification badge when IP is self signed
    @Published var selfSignedIP = Bool()
    
    // Ethernet or SSID when connected
    @Published var networkName = NSLocalizedString("Not Connected", comment: "")
    
    // Rapid Security Response version
    @Published var rapidSecurityResponseVersion: String = ""
    
    // MARK: - Function to get uptime
    func kernelBootTime() {
        
        // Set current status to compare with new status when function completes
        let oldUptimeLimitReached = uptimeLimitReached
        
        // We use the same underlying code as uptime uses in macOS. Sources: https://worthdoingbadly.com/uptimekext/, https://gist.github.com/nyg/d81308a92fbf7e9c44c5f72db5ee2171
        var mib = [ CTL_KERN, KERN_BOOTTIME ]
        var bootTime = timeval()
        var bootTimeSize = MemoryLayout<timeval>.size
        
        if 0 != sysctl(&mib, UInt32(mib.count), &bootTime, &bootTimeSize, nil, 0) {
        fatalError("Could not get boot time, errno: \(errno)")
            }
        
        // Set the boot time in unix timestamp
        logger.debug("Uptime in unix timestamp: \(bootTime.tv_sec)")
        
        // Set the current unix timestamp
        let currentTimestamp = NSDate().timeIntervalSince1970
        logger.debug("Current unix timestamp: \(currentTimestamp)")
        
        // Calculate uptime in seconds by subtracting boot time from current time
        var uptime = Double(Int(currentTimestamp) - bootTime.tv_sec)
        logger.debug("Uptime in seconds: \(uptime)")
        
        // Set text to days when uptime is more than 24 hours
        if uptime > 86400 {
            // Convert uptime in seconds to days
            uptime = Double(uptime / 60 / 60 / 24)
            // Round the value down
            uptime.round(.down)
            // Convert double to integer because we don't want to see decimals
            uptimeRounded = Int(uptime)
            if uptimeRounded == 1 {
                uptimeText = NSLocalizedString("day", comment: "")
            } else {
                uptimeText = NSLocalizedString("days", comment: "")
            }
        // Set text to minutes when uptime is less than 60 minutes
        } else if uptime < 3600 {
            // Convert uptime in seconds to minutes
            uptime = Double(uptime / 60)
            // Round the value down
            uptime.round(.down)
            // Convert double to integer because we don't want to see decimals
            uptimeRounded = Int(uptime)
            if uptimeRounded == 1 {
                uptimeText = NSLocalizedString("minute", comment: "")
            } else {
                uptimeText = NSLocalizedString("minutes", comment: "")
            }
        // Set text to hours when uptime is between 1 and 24 hours
        } else {
            // Convert uptime in seconds to hours
            uptime = Double(uptime / 60 / 60)
            // Round the value down
            uptime.round(.down)
            // Convert double to integer because we don't want to see decimals
            uptimeRounded = Int(uptime)
            if uptimeRounded == 1 {
                uptimeText = NSLocalizedString("hour", comment: "")
            } else {
                uptimeText = NSLocalizedString("hours", comment: "")
            }
        }
        logger.debug("Rounded uptime: \(self.uptimeRounded) \(self.uptimeText, privacy: .public)")
        
        // Determine if notification badge with exclamation mark should be shown in tile
        if preferences.uptimeDaysLimit > 0 && (uptimeText == NSLocalizedString("days", comment: "") || uptimeText == NSLocalizedString("day", comment: "")) && uptimeRounded >= preferences.uptimeDaysLimit {
            // Set boolean to true to show alert and menu bar icon notification badge
            uptimeLimitReached = true
        } else {
            // Set boolean to false to hide alert and menu bar icon notification badge
            uptimeLimitReached = false
        }
        
        // Post changes to notification center
        if oldUptimeLimitReached != uptimeLimitReached {
            NotificationCenter.default.post(name: Notification.Name.uptimeDaysLimit, object: nil)
        } else {
            logger.debug("Uptime Days Limit status did not change, no need to reload StatusBarItem")
        }
    }
    
    // MARK: - Function to get computer name
    func getHostname() {
        self.hostname = Host.current().localizedName!
        logger.debug("Computer name: \(self.hostname, privacy: .public)")
    }
    
    // MARK: - Function to get macOS Version Name
    func getmacOSVersionName() {
        let version = systemVersionMajor
        switch version {
        case 11:
            macOSVersionName = "Big Sur"
        case 12:
            macOSVersionName = "Monterey"
        case 13:
            macOSVersionName = "Ventura"
        default:
            macOSVersionName = ""
        }
    }
    
    // MARK: - Function to get storage data
    func getStorage() {
        
        // Calculate available capacity
        let fileURL = URL(fileURLWithPath:"/")
        do {
            let values = try fileURL.resourceValues(forKeys: [.volumeAvailableCapacityForImportantUsageKey])
            if let capacity = values.volumeAvailableCapacityForImportantUsage {
                self.capacity = Double(capacity)
                logger.debug("Available capacity: \(capacity)")
                capacityRounded = ByteCountFormatter.string(fromByteCount: Int64(capacity), countStyle: .file)
                logger.debug("Available capacity rounded: \(self.capacityRounded, privacy: .public)")
            } else {
                logger.debug("Available capacity is unavailable")
                capacityRounded = "Capacity unavailable"
            }
        } catch {
            logger.debug("Error retrieving available capacity: \(error.localizedDescription)")
            capacityRounded = "Error: \(error.localizedDescription)"
        }
        
        // Calculate total capacity
        do {
            let values = try fileURL.resourceValues(forKeys: [.volumeTotalCapacityKey])
            if let totalCapacity = values.volumeTotalCapacity {
                self.totalCapacity = Double(totalCapacity)
                logger.debug("Total capacity: \(totalCapacity)")
                totalCapacityRounded = ByteCountFormatter.string(fromByteCount: Int64(totalCapacity), countStyle: .file)
                logger.debug("Total capacity rounded: \(self.totalCapacityRounded, privacy: .public)")
            } else {
                logger.debug("Total capacity is unavailable")
                totalCapacityRounded = "Total Capacity unavailable"
            }
        } catch {
            logger.debug("Error retrieving total capacity: \(error.localizedDescription)")
            totalCapacityRounded = "Error: \(error.localizedDescription)"
        }
        
        // Calculate percentage available capacity
        
        // Multiplied by 120 to match the bar length in StorageView
        let capacityPercentage = ((totalCapacity - capacity) / totalCapacity) * 120
        self.capacityPercentage = CGFloat(capacityPercentage)
        logger.debug("Used capacity percentage bar length: \(capacityPercentage)")
        
        // Multiplied by 100 to show percentage to user
        let capacityPercentageRounded = ((totalCapacity - capacity) / totalCapacity) * 100

        self.capacityPercentageRounded = round(capacityPercentageRounded * 10) / 10
        logger.debug("Used capacity percentage rounded: \(capacityPercentageRounded)")
        
        // Determine if notification badge with exclamation mark should be shown in tile
        if preferences.storageLimit > 0 && Int(capacityPercentageRounded) > preferences.storageLimit {
            // Set boolean to true to show alert and menu bar icon notification badge
            storageLimitReached = true
        } else {
            // Set boolean to false to hide alert and menu bar icon notification badge
            storageLimitReached = false
        }
        
        // Post changes to notification center
//        NotificationCenter.default.post(name: Notification.Name.storageLimit, object: nil)
    }
    
    // MARK: - Get the Model Identifier: https://github.com/Ekhoo/Device/blob/master/Source/macOS/DeviceMacOS.swift
     func getModelIdentifier() -> String {
        var size : Int = 0
        sysctlbyname("hw.model", nil, &size, nil, 0)
        var model = [CChar](repeating: 0, count: Int(size))
        sysctlbyname("hw.model", &model, &size, nil, 0)
        self.modelIdentifier = String.init(validatingUTF8: model) ?? ""
        logger.debug("Model Identifier: \(self.modelIdentifier, privacy: .public)")
         
         // Remove all numbers from Model Identifier string
         var modelIdentifierString = modelIdentifier.components(separatedBy: CharacterSet.decimalDigits).joined()
         logger.debug("Model Identifier without numbers and comma: \(modelIdentifierString, privacy: .public)")
         modelIdentifierString = modelIdentifierString.components(separatedBy: CharacterSet.punctuationCharacters).joined()
         
         return modelIdentifierString
    }
    
    // MARK: - Function to get the model name and set computer icon
    func getModelName() {
        
#if arch(arm64)
        
        // New method for Apple Silicon to get model name and set computer icon
        
        let task = Process()
        let pipe = Pipe()
        
        // Command to get c
        let computerNameCommand = """
        ioreg -l -c IOPlatformDevice | grep -e "product-name" | cut -d'"' -f 4
        """
        
        // Move command to background thread
        DispatchQueue.global().async {
            task.standardOutput = pipe
            task.standardError = pipe
            task.launchPath = "/bin/zsh"
            task.arguments = ["-c", computerNameCommand]
            task.launch()
            
            let data = pipe.fileHandleForReading.readDataToEndOfFile()
            
            // Back to the main thread to publish values
            DispatchQueue.main.async {
                // Set the Model Name
                self.modelNameString = String(data: data, encoding: .utf8)!.trimmingCharacters(in: .whitespacesAndNewlines)
                
                // Set the computer symbol based on the Model Name
                if self.modelNameString.localizedCaseInsensitiveContains("MacBook") {
                    self.computerNameIcon = "laptopcomputer"
                } else if self.modelNameString.localizedCaseInsensitiveContains("Mac mini") {
                    self.computerNameIcon = "macmini.fill"
                } else if self.modelNameString.localizedCaseInsensitiveContains("Mac Pro") {
                    // Filled SF Symbols are preferred but version for Mac Pro is only available in macOS 12 and higher
                    if #available(macOS 12, *) {
                        self.computerNameIcon = "macpro.gen3.fill"
                    } else {
                        self.computerNameIcon = "macpro.gen3"
                    }
                } else if self.modelNameString.localizedCaseInsensitiveContains("Mac Studio") {
                    // SF Symbol for Mac Studio is only available in macOS 13 and higher
                    if #available(macOS 13, *) {
                        self.computerNameIcon = "macstudio.fill"
                    } else {
                        self.computerNameIcon = "desktopcomputer"
                    }
                } else if self.modelNameString.localizedCaseInsensitiveContains("Apple Virtual Machine") {
                    self.computerNameIcon = "server.rack"
                } else {
                    self.computerNameIcon = "desktopcomputer"
                }
                
                self.logger.debug("Model Name: \(self.modelNameString, privacy: .public)")
                self.logger.debug("Computer SF Symbol: \(self.computerNameIcon, privacy: .public)")
            }
        }
        
#else
        // Legacy Intel method to get model name and set computer icon
        // https://github.com/davedelong/Syzygy/blob/master/SyzygyCore/macOS/System.swift
        
        // Remove all numbers and comma from Model Identifier string
        let modelIdentifierString = getModelIdentifier()
        
        // Set the short model name based on the Model Identifier
        if modelIdentifierString.hasPrefix("MacBookAir") {
            self.modelShortName = "MacBook Air"
        } else if modelIdentifierString.hasPrefix("MacBookPro") {
            self.modelShortName = "MacBook Pro"
        } else if modelIdentifierString.hasPrefix("MacBook") && !self.modelIdentifier.hasPrefix("MacBookPro") && !self.modelIdentifier.hasPrefix("MacBookAir") {
            self.modelShortName = "MacBook"
        } else if modelIdentifierString.hasPrefix("Macmini") {
            self.modelShortName = "Mac mini"
        } else if modelIdentifierString.hasPrefix("MacPro") {
            self.modelShortName = "Mac Pro"
        } else if modelIdentifierString.hasPrefix("iMac") {
            self.modelShortName = "iMac"
        } else if modelIdentifierString.hasPrefix("VirtualMac") {
            self.modelShortName = "Apple Virtual Machine"
        }
        
        // Set the computer symbol based on the Model Identifier
        if modelIdentifierString.hasPrefix("MacBook") {
            computerNameIcon = "laptopcomputer"
        } else if modelIdentifierString.hasPrefix("Macmini") {
            computerNameIcon = "macmini.fill"
        } else if modelIdentifierString.hasPrefix("MacPro") {
            switch modelIdentifierString {
                // Mac Pro Gen 2 is also compatible. Show Gen 2 icon if Model Identifier is MacPro6,1
            case "MacPro6,1":
                computerNameIcon = "macpro.gen2.fill"
            default:
                computerNameIcon = "macpro.gen3"
            }
        } else if modelIdentifierString.hasPrefix("VirtualMac") {
            computerNameIcon = "server.rack"
        } else {
            computerNameIcon = "desktopcomputer"
        }
        
        self.logger.debug("Short Model Name: \(self.modelShortName, privacy: .public)")
        
        // Get the serial number
        var serialNumber: String {
            let platformExpert = IOServiceGetMatchingService(kIOMasterPortDefault, IOServiceMatching("IOPlatformExpertDevice") )
            
            guard platformExpert > 0 else {
                return "Unknown"
            }
            
            guard let serialNumber = (IORegistryEntryCreateCFProperty(platformExpert, kIOPlatformSerialNumberKey as CFString, kCFAllocatorDefault, 0).takeUnretainedValue() as? String)?.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines) else {
                return "Unknown"
            }
            
            IOObjectRelease(platformExpert)
            
            return serialNumber
        }
        
        self.logger.debug("Serial Number: \(serialNumber, privacy: .public)")
        
        // Get the 4 last characters in the serial number
        let serialSuffix = serialNumber.suffix(4)
            
        // Moving network request to a background thread
        DispatchQueue.global().async {
            
            // FIXME: - Still unknown how to query for new 10 character random serial numbers
            // Set the API URL to get the full model name
            if let url = URL(string: "https://support-sp.apple.com/sp/product?cc=\(serialSuffix)") {
                
                // Start the network request
                if let request = try? Data(contentsOf: url) {
                    if let string = String(data: request, encoding: .utf8) {
                        // Get the full model name
                        let matchedModel = self.matches(for: "<configCode>(.+?)</configCode>", in: string)
                        
                        // Get the year from the full model name
                        let matchedYear = self.matches(for: "^.*(20[0-9][0-9]).", in: string)
                        
                        // Back to the main thread to publish values
                        DispatchQueue.main.async {
                            
                            // Check array for matches to avoid a crash
                            if matchedModel.indices.contains(0) && matchedYear.indices.contains(0) {
                                self.modelName = matchedModel[0]
                                self.modelYear = matchedYear[0]
                                
                                self.modelNameString = "\(self.modelName) \(self.modelYear)"
                            } else {
                                self.logger.debug("Error matching serial number with model and introduction year...")
                            }
                            
                            self.logger.debug("Full Model Name: \(self.modelName, privacy: .public)")
                            self.logger.debug("Model Year: \(self.modelYear, privacy: .public)")
                        }
                    }
                } else {
                    self.logger.debug("Error getting model name...")
                }
            }
        }
#endif
    }
    
    // MARK: - Function for matching a regular expression
    func matches(for regex: String, in text: String) -> [String] {

        do {
            let regex = try NSRegularExpression(pattern: regex)
            let results = regex.matches(in: text,
                                        range: NSRange(text.startIndex..., in: text))
            return results.map {
                String(text[Range($0.range(at: 1), in: text)!])
            }
        } catch let error {
            print("invalid regex: \(error.localizedDescription)")
            return []
        }
    }
    
    // MARK: - Function to get the IP address of the currently first active interface
    // https://stackoverflow.com/questions/30748480/swift-get-devices-wifi-ip-address
    // https://stackoverflow.com/questions/25626117/how-to-get-ip-address-in-swift
    func getIPAddress() {
        var address: String?
        var ifaddr: UnsafeMutablePointer<ifaddrs>? = nil
        
        // Set current IP to compare with new IP when function completes
//        let oldIPAdress = ipAddress
        
        // Set symbol when not connected
        networkInterfaceSymbol = "wifi.slash"
        networkName = NSLocalizedString("Not Connected", comment: "")
        
        if getifaddrs(&ifaddr) == 0 {
            var ptr = ifaddr
            while ptr != nil {
                defer { ptr = ptr?.pointee.ifa_next }
                
                guard let interface = ptr?.pointee else {
                    ipAddress = NSLocalizedString("No IP Address", comment: "")
                    return
                }
                
                let flags = Int32(interface.ifa_flags)
                let addrFamily = interface.ifa_addr.pointee.sa_family
                
                // Check for running IPv4, IPv6 interfaces. Skip the loopback interface.
                if (flags & (IFF_UP|IFF_RUNNING|IFF_LOOPBACK)) == (IFF_UP|IFF_RUNNING) {
                    // Monitoring for IPv6 disabled. Replace code below to enable
                    if addrFamily == UInt8(AF_INET) {
                        
                        //                if addrFamily == UInt8(AF_INET) || addrFamily == UInt8(AF_INET6) {
                        
                        // wifi = ["en0"]
                        // wired = ["en2", "en3", "en4"]
                        // cellular = ["pdp_ip0","pdp_ip1","pdp_ip2","pdp_ip3"]
                        // All other ethernet interfaces such as dongles = ["en*"]
                        
                        let name: String = String(cString: (interface.ifa_name))
                        if name.contains("en") || name == "pdp_ip0" || name == "pdp_ip1" || name == "pdp_ip2" || name == "pdp_ip3" {
                            var hostname = [CChar](repeating: 0, count: Int(NI_MAXHOST))
                            getnameinfo(interface.ifa_addr, socklen_t((interface.ifa_addr.pointee.sa_len)), &hostname, socklen_t(hostname.count), nil, socklen_t(0), NI_NUMERICHOST)
                            
                            // FIXME: - Caused false posiitives when a non connected interface shows up in ifconfig with a self-assigned IP address. Feature temporarily removed.
                            if String(cString: hostname).hasPrefix("169") {
                                // Do nothing to avoid displaying a non connected interface with self-assigned IP address
//                                selfSignedIP = true
                                
                            } else {
                                // Set the IP address and corresponding text/symbols
                                address = String(cString: hostname)
                                selfSignedIP = false
                                
                                // Get the wireless interface name
                                let wirelessInterface = CWWiFiClient.shared().interface()?.interfaceName
                                logger.debug("Wireless interface name: \(wirelessInterface ?? "Not present", privacy: .public)")

                                // Set the appropriate symbol for the network interface
                                if name == wirelessInterface {
                                    networkInterfaceSymbol = "wifi"
                                    networkName = CWWiFiClient.shared().interface(withName: nil)?.ssid() ?? "Unknown SSID"
                                } else {
                                    networkInterfaceSymbol = "rectangle.connected.to.line.below"
                                    networkName = "Ethernet"
                                }
                            }
                            
                            logger.debug("Network interface: \(name, privacy: .public)")
                            
                        }
                    }
                }
            }
            freeifaddrs(ifaddr)
        }
        logger.debug("IP address: \(address ?? "No IP Address", privacy: .public)")
        ipAddress = address ?? NSLocalizedString("No IP Address", comment: "")
        
        // Post changes to notification center when IP is different
//        if ipAddress != oldIPAdress {
//            NotificationCenter.default.post(name: Notification.Name.networkState, object: nil)
//        } else {
//            logger.debug("IP Address did not change, no need to reload StatusBarItem")
//        }
    }
    
    // MARK: - Get Array of RecommendedUpdates from com.apple.SoftwareUpdate
    func getRecommendedUpdates() {
        
        // Set current status to compare with new status when function completes
        let oldMajorVersionUpdates = majorVersionUpdates
        
        logger.debug("Checking RecommendedUpdates for macOS updates and versions...")
        
        // Set UserDefaults to com.apple.SoftwareUpdate
        let userDefaultsSoftwareUpdates = UserDefaults(suiteName: "com.apple.SoftwareUpdate")
        
        // Create empty array for RecommendedUpdates UserDefaults data
        let recommendedUpdates = userDefaultsSoftwareUpdates?.array(forKey: "RecommendedUpdates") ?? []
        
        // Create empty array for decoded RecommendedUpdates UserDefaults data
        var decodedItems: [SoftwareUpdateModel] = []

        // Move decoding of RecommendedUpdates to background thread
        DispatchQueue.global().async {
            
            do {
                // Convert UserDefaults to JSON data
                let data = try JSONSerialization.data(withJSONObject: recommendedUpdates, options: [])
                
                // Decode JSON data
                let decoder = JSONDecoder()
                decodedItems = try decoder.decode([SoftwareUpdateModel].self, from: data)
                self.logger.debug("Successfully decoded RecommendedUpdates...")
                
            } catch {
                self.logger.error("Error getting RecommendedUpdates...")
            }
            
            // Return when decoded RecommendedUpdates array is empty
            guard !decodedItems.isEmpty else {
                self.logger.debug("RecommendedUpdates is empty...")
                return
            }
            
            // Reset major version updates to 0
            var majorVersionUpdatesTemp = 0
            
            self.logger.debug("Updates found: \(decodedItems.count)")
            
            // Loop through all available updates and decrease number of updates when available macOS version is higher than current major version
            for item in decodedItems {
                // Filter updates with "macOS" in Display Name
                if item.displayName.contains("macOS") {
                    // Get digits from Display Version separated by a dot to get the major version
                    if let version = item.displayVersion?.components(separatedBy: ".")[0] {
                        self.logger.debug("macOS update found: \(item.displayName, privacy: .public)")
                        // Convert to integer and compare with current major OS version. If higher, increase number of major OS updates
                        if Int(version) ?? 0 > self.systemVersionMajor {
                            self.logger.debug("macOS version \(version, privacy: .public) is higher than the current macOS version (\(self.systemVersionMajor)), update will be hidden when DeferMajorVersions is enabled")
                            majorVersionUpdatesTemp += 1
                        }
                    } else {
                        self.logger.error("Error getting macOS version from \(item.displayName, privacy: .public)")
                    }
                    // Report but ignore any non-macOS updates, such as application updates
                } else {
                    self.logger.debug("\(item.displayName, privacy: .public) is not a macOS update")
                }
            }
            
            self.logger.debug("Major macOS updates found: \(majorVersionUpdatesTemp)")
            
            // Back to the main thread to publish values
            DispatchQueue.main.async {
                self.majorVersionUpdates = majorVersionUpdatesTemp
                
                // Post changes to notification center
                if oldMajorVersionUpdates != majorVersionUpdatesTemp {
                    NotificationCenter.default.post(name: Notification.Name.majorVersionUpdates, object: nil)
                } else {
                    self.logger.debug("Number of Major macOS Updates did not change, no need to reload StatusBarItem")
                }
            }
        }
    }
    
    @available(macOS 13, *)
    // MARK: - Get optional Rapid Security Response version
    func getRSRVersion() {
        
        let task = Process()
        let pipe = Pipe()
        
        // Command to get Rapid Security Response version
        let RSRCommand = """
        /usr/bin/sw_vers -productVersionExtra
        """
        
        // Move command to background thread
        DispatchQueue.global().async {
            task.standardOutput = pipe
            task.standardError = pipe
            task.launchPath = "/bin/zsh"
            task.arguments = ["-c", RSRCommand]
            task.launch()
            
            let data = pipe.fileHandleForReading.readDataToEndOfFile()
            
            // Back to the main thread to publish values
            DispatchQueue.main.async {
                self.rapidSecurityResponseVersion = String(data: data, encoding: .utf8)!.trimmingCharacters(in: .whitespacesAndNewlines)
            }
        }
    }
}
