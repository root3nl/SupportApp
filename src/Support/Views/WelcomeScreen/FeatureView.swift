//
//  FeatureView.swift
//  Support
//
//  Created by Jordy Witteman on 23/06/2021.
//

import SwiftUI

struct FeatureView: View {
    
    var image: String
    var title: String
    var subtitle: String
    var color: Color
    
    var body: some View {
        
        HStack(spacing: 24) {
            Image(systemName: image)
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 35, height: 35)
                .foregroundColor(color)
            
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.system(.body, design: .rounded)).fontWeight(.medium)
//                    .font(.system(.headline, design: .rounded))
//                    .fontWeight(.bold)
                Text(subtitle)
                    .font(.system(.subheadline, design: .rounded))
//                    .font(.system(.subheadline, design: .rounded))
//                    .fontWeight(.semibold)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
            
        }
        .frame(width: 250, height: 60)
    }
    
}
