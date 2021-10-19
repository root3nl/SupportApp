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

        ZStack {
            EffectsView(material: NSVisualEffectView.Material.fullScreenUI, blendingMode: NSVisualEffectView.BlendingMode.behindWindow)
            
            // We need to provide Quit option for Apple App Review approval
            if !preferences.hideQuit {
                QuitButton()
            }
            
            VStack(spacing: 10) {
                
                // Horizontal stack with Title and Logo
                HStack(spacing: 10) {
                    
                    // Use Rounded font like in Reminders app
                    Text(preferences.title).font(.system(size: 20, design: .rounded)).fontWeight(.medium)
                    
                    Spacer()
                    
                    // Logo shown in the top right corner
                    // We cannot use @AppStorage because NSImage is a different type when custom logo is used
                    if colorScheme == .light && defaults.string(forKey: "Logo") != nil {
                        Image(nsImage: (NSImage(contentsOfFile: defaults.string(forKey: "Logo")!) ?? NSImage(named: "DefaultLogo"))!)
                            .resizable()
                            .scaledToFit()
                            .frame(height: 48)
                        // Show different logo in Dark Mode when LogoDarkMode is also set
                    } else if colorScheme == .dark && defaults.string(forKey: "Logo") != nil {
                        if defaults.string(forKey: "LogoDarkMode") != nil {
                            Image(nsImage: (NSImage(contentsOfFile: defaults.string(forKey: "LogoDarkMode")!) ?? NSImage(named: "DefaultLogo"))!)
                                .resizable()
                                .scaledToFit()
                                .frame(height: 48)
                        } else if defaults.string(forKey: "Logo") != nil && defaults.string(forKey: "LogoDarkMode") == nil {
                            Image(nsImage: (NSImage(contentsOfFile: defaults.string(forKey: "Logo")!) ?? NSImage(named: "DefaultLogo"))!)
                                .resizable()
                                .scaledToFit()
                                .frame(height: 48)
                        } else {
                            Image("DefaultLogo")
                                .resizable()
                                .scaledToFit()
                                .frame(height: 48)
                        }
                        // Show default logo in all other cases
                    } else {
                        Image("DefaultLogo")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 48, height: 48)
                    }
                    
                }
                .foregroundColor(Color.primary)
                .padding(.leading, 16.0)
                .padding(.trailing, 10.0)
                .padding(.top, 10.0)
                
                VStack(alignment: .leading, spacing: 10) {
                                        
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
//                    preferences.showWelcomeScreen.toggle()
                    preferences.hasSeenWelcomeScreen.toggle()
                    
                }
                .onHover {_ in
                    withAnimation(.easeInOut) {
                        hoverButton.toggle()
                    }
                }
                .padding(.top)
                
            }
            .padding(.bottom)
        }
    }
}

struct WelcomeView_Previews: PreviewProvider {
    static var previews: some View {
        WelcomeView()
    }
}
