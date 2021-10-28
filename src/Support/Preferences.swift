//
//  Preferences.swift
//  Root3 Support
//
//  Created by Jordy Witteman on 31/07/2020.
//

import Foundation
import SwiftUI

// Class to publish preference updates from variables to ContentView
class Preferences: ObservableObject {
    
    // Where possible we use the @AppStorage property wrapper which uses UserDefaults to get and store preferences.
    // The benefit of @AppStorage is that value changes are automatically observed by SwiftUI and updates the view
    // without manually asking UserDefault for new data. Other preferences are handled elsewhere.
    
    // MARK: - General
    
    // Title shown in the top of the app
    @AppStorage("Title") var title: String = "Support"
    
    // Custom color for all symbols
    @AppStorage("CustomColor") var customColor: String = ""
    
    // Custom color for all symbols for Dark Mode
    @AppStorage("CustomColorDarkMode") var customColorDarkMode: String = ""
    
    // Custom error message
    @AppStorage("ErrorMessage") var errorMessage: String = NSLocalizedString("Please contact IT support", comment: "")
    
    // Show optional welcome screen
    @AppStorage("ShowWelcomeScreen") var showWelcomeScreen = false
    
    // Hide Quit Button. Set to FALSE by default in MAS version. Set to TRUE by default in Non-MAS version
    @AppStorage("HideQuit") var hideQuit: Bool = true
    
    // Text shown at the bottom as footnote
    @AppStorage("FooterText") var footerText = ""
    
    // MARK: - Info items
    
    // Version 2.2 new preferences for modular info items
    @AppStorage("InfoItemOne") var infoItemOne: String = "ComputerName"
    @AppStorage("InfoItemTwo") var infoItemTwo: String = "MacOSVersion"
    @AppStorage("InfoItemThree") var infoItemThree: String = "Uptime"
    @AppStorage("InfoItemFour") var infoItemFour: String = "Storage"
    
    // Days of uptime after which a notification badge is shown, disabled by default
    @AppStorage("UptimeDaysLimit") var uptimeDaysLimit: Int = 0
    
    // Days until password expiry shows a notification badge is shown, disabled by default
    @AppStorage("PasswordExpiryLimit") var passwordExpiryLimit: Int = 0
    
    // Text to show in Password info item
    @AppStorage("PasswordLabel") var passwordLabel: String = "Mac " + NSLocalizedString("Password", comment: "")
    
    // Password type
    @AppStorage("PasswordType") var passwordType: String = "Apple"
    
    // Percentage of storage used after which a notification badge is shown, disabled by default
    @AppStorage("StorageLimit") var storageLimit: Int = 0
    
    // MARK: - First row of configurable buttons
    
    // UserDefaults for button left (3rd row) with default values
    @AppStorage("FirstRowTitleLeft") var firstRowTitleLeft: String = "Remote Support"
    @AppStorage("FirstRowSubtitleLeft") var firstRowSubtitleLeft: String = ""
    @AppStorage("FirstRowTypeLeft") var firstRowTypeLeft: String = "App"
    @AppStorage("FirstRowLinkLeft") var firstRowLinkLeft: String = "com.apple.ScreenSharing"
    @AppStorage("FirstRowSymbolLeft") var firstRowSymbolLeft: String = "cursorarrow"
    
    // UserDefaults for optional button middle (3th row)
    @AppStorage("FirstRowTitleMiddle") var firstRowTitleMiddle: String = ""
    @AppStorage("FirstRowSubtitleMiddle") var firstRowSubtitleMiddle: String = ""
    @AppStorage("FirstRowTypeMiddle") var firstRowTypeMiddle: String = "URL"
    @AppStorage("FirstRowLinkMiddle") var firstRowLinkMiddle: String = ""
    @AppStorage("FirstRowSymbolMiddle") var firstRowSymbolMiddle: String = ""

    // UserDefaults for button right (3rd row) with default values
    @AppStorage("FirstRowTitleRight") var firstRowTitleRight: String = "Company Store"
    @AppStorage("FirstRowSubtitleRight") var firstRowSubtitleRight: String = ""
    @AppStorage("FirstRowTypeRight") var firstRowTypeRight: String = "App"
    @AppStorage("FirstRowLinkRight") var firstRowLinkRight: String = "com.apple.AppStore"
    @AppStorage("FirstRowSymbolRight") var firstRowSymbolRight: String = "cart.fill"
    
    // MARK: - Second row of configurable buttons
    
    // UserDefaults for button left (4th row) with default values
    @AppStorage("SecondRowTitleLeft") var secondRowTitleLeft: String = "Support Ticket"
    @AppStorage("SecondRowSubtitleLeft") var secondRowSubtitleLeft: String = ""
    @AppStorage("SecondRowTypeLeft") var secondRowTypeLeft: String = "URL"
    @AppStorage("SecondRowLinkLeft") var secondRowLinkLeft: String = "https://yourticketsystem.tld"
    @AppStorage("SecondRowSymbolLeft") var secondRowSymbolLeft: String = "ticket"
    
    // UserDefaults for optional button middle (4th row) with default values
    @AppStorage("SecondRowTitleMiddle") var secondRowTitleMiddle: String = ""
    @AppStorage("SecondRowSubtitleMiddle") var secondRowSubtitleMiddle: String = ""
    @AppStorage("SecondRowTypeMiddle") var secondRowTypeMiddle: String = "URL"
    @AppStorage("SecondRowLinkMiddle") var secondRowLinkMiddle: String = ""
    @AppStorage("SecondRowSymbolMiddle") var secondRowSymbolMiddle: String = ""
    
    // UserDefaults for button right (4th row) with default values
    @AppStorage("SecondRowTitleRight") var secondRowTitleRight: String = "Phone"
    @AppStorage("SecondRowSubtitleRight") var secondRowSubtitleRight: String = ""
    @AppStorage("SecondRowTypeRight") var secondRowTypeRight: String = "URL"
    @AppStorage("SecondRowLinkRight") var secondRowLinkRight: String = "tel:+31000000000"
    @AppStorage("SecondRowSymbolRight") var secondRowSymbolRight: String = "phone"
 
    // MARK: - Non MDM preferences
    
    // Boolean to hide the welcome screen after the first time. Should not be managed using MDM.
    @AppStorage("HasSeenWelcomeScreen") var hasSeenWelcomeScreen = false
    
}
