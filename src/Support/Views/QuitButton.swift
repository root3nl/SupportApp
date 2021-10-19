//
//  QuitButton.swift
//  Support
//
//  Created by Jordy Witteman on 04/01/2021.
//

import SwiftUI

struct QuitButton: View {
    
    @State var quitPressed = false
    
    var body: some View {
        
        VStack {
            HStack {
                Image(systemName: "xmark.circle.fill")
                    .padding(4)
                    .onTapGesture {
                        self.quitPressed = true
                    }
                    .help(NSLocalizedString("Quit", comment: ""))
                    .alert(isPresented: $quitPressed) {
                        Alert(title: Text(NSLocalizedString("Are you sure you want to quit?", comment: "")), message: Text(""), primaryButton: .default(Text(NSLocalizedString("Quit", comment: ""))) {
                            NSApplication.shared.terminate(AppDelegate.self)
                        }, secondaryButton: .cancel())
                    }
                
                Spacer()
            }
            Spacer()
        }
        .unredacted()
    }
}
