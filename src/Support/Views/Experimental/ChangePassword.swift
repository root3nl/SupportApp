//
//  ChangePassword.swift
//  Support
//
//  Created by Jordy Witteman on 17/05/2021.
//

import SwiftUI

struct ChangePassword: View {
    
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
    
    var body: some View {

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
                
            }
        
        VStack {
            
//            HStack {
//                Text("Change your Mac password").font(.system(.body, design: .rounded)).fontWeight(.medium)
//                Spacer()
//            }
                    
            HStack {
                
                Button(action: {
//                    withAnimation(.easeInOut) {
                        computerinfo.showPasswordChange.toggle()
//                    }
                }) {
                    Image(systemName: "arrow.left.circle")
                        .imageScale(.large)
                }
                .buttonStyle(PlainButtonStyle())
                
                Spacer()
            }
//            .padding(.leading, 16.0)
            
            HStack {
                Text("Old Password").font(.system(.body, design: .rounded)).fontWeight(.medium)
                Spacer()
                SecureField("", text: $userinfo.currentPassword)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .frame(width: 200)
            }
            HStack {
                Text("New Password").font(.system(.body, design: .rounded)).fontWeight(.medium)
                Spacer()
                SecureField("", text: $userinfo.newPassword)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .frame(width: 200)
            }
            HStack {
                Text("Verify New Password").font(.system(.body, design: .rounded)).fontWeight(.medium)
                Spacer()
                SecureField("", text: $userinfo.verifyNewPassword)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .frame(width: 200)

            }
            
            HStack {
                Button(action: {
                    userinfo.changePassword()
                }) {
                    Text("Change Password").font(.system(.body, design: .rounded)).fontWeight(.medium)
                }
                
                Spacer()
            }
        }
        .padding(.horizontal)
        .padding(.bottom)
        .alert(isPresented: $userinfo.passwordChangedAlert) {
            Alert(title: Text(NSLocalizedString("Password changed", comment: "")), message: Text("Password changed successfully"), dismissButton: .default(Text("OK")))
        }
    }
}

struct ChangePassword_Previews: PreviewProvider {
    static var previews: some View {
        ChangePassword()
    }
}
