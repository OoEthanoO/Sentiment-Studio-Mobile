//
//  AlertView.swift
//  Sentiment Studio Mobile
//
//  Created by Ethan Xu on 2024-04-01.
//

import SwiftUI

struct AlertView: View {
    var text: String
    var color: Color
    var body: some View {
        ZStack(alignment: .topLeading) {
            RoundedRectangle(cornerSize: CGSize(width: 10, height: 10))
                .fill(color.opacity(0.2))
                .frame(height: 50)
            
            Text(text)
                .padding(15)
        }
        .padding([.leading, .trailing], 30)
    }
}

#Preview {
    AlertView(text: "Sample Text", color: Color.accentColor)
}
