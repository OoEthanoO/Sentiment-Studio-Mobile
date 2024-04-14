//
//  TitleView.swift
//  Sentiment Studio Mobile
//
//  Created by Ethan Xu on 2024-04-13.
//

import SwiftUI

struct TitleView: View {
    var text: String
    var body: some View {
        Text(text)
            .font(.title)
            .padding(.top, 50)
            .bold()
    }
}

#Preview {
    TitleView(text: "Sample Text")
}
