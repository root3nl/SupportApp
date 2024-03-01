//
//  WelcomeView.swift
//  Support
//
//  Created by Jordy Witteman on 23/06/2021.
//

import SwiftUI

struct WelcomeView: View {
    
    @EnvironmentObject var computerinfo: ComputerInfo
    @EnvironmentObject var userinfo: UserInfo
    
    // Get preferences or default values
    @StateObject var preferences = Preferences()
    
    // Make UserDefaults easy to use
    let defaults = UserDefaults.standard
        
    // Dark Mode detection
    @Environment(\.colorScheme) var colorScheme
    
    // Set the custom color for all symbols depending on Light or Dark Mode.
    var customColor: String {
        if colorScheme == .light && defaults.string(forKey: "CustomColor") != nil {
            return preferences.customColor
        } else if colorScheme == .dark && defaults.string(forKey: "CustomColorDarkMode") != nil {
            return preferences.customColorDarkMode
        } else {
            return preferences.customColor
        }
    }
    
    @State var hoverButton = false
    
    var body: some View {
        
        VStack(alignment: .leading) {
            
            FeatureView(image: "stethoscope", title: NSLocalizedString("Mac diagnosis", comment: ""), subtitle: NSLocalizedString("MAC_DIAGNOSIS_TEXT", comment: ""), color: Color(NSColor(hex: "\(customColor)") ?? NSColor.controlAccentColor))
            
            FeatureView(image: "briefcase", title: NSLocalizedString("Easy access", comment: ""), subtitle: NSLocalizedString("EASY_ACCESS_TEXT", comment: ""), color: Color(NSColor(hex: "\(customColor)") ?? NSColor.controlAccentColor))
            
            FeatureView(image: "lifepreserver", title: NSLocalizedString("Get in touch", comment: ""), subtitle: NSLocalizedString("GET_IN_TOUCH_TEXT", comment: ""), color: Color(NSColor(hex: "\(customColor)") ?? NSColor.controlAccentColor))
            
        }
        
        HStack {
            Spacer()
            Text(NSLocalizedString("Continue", comment: ""))
                .font(.system(.body, design: .rounded))
                .fontWeight(.bold)
                .foregroundColor(.white)
            Spacer()
        }
        .frame(width: 200, height: 35)
        .background(Color(NSColor(hex: "\(customColor)") ?? NSColor.controlAccentColor))
        .opacity(hoverButton ? 0.5 : 1.0)
        .cornerRadius(10)
        .onTapGesture {
            preferences.hasSeenWelcomeScreen.toggle()
        }
        .onHover {_ in
            withAnimation(.easeInOut) {
                hoverButton.toggle()
            }
        }
        .padding(.top)
    }
}

struct WelcomeView_Previews: PreviewProvider {
    static var previews: some View {
        WelcomeView()
    }
}
