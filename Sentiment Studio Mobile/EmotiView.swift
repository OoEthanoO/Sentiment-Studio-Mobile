//
//  EmotiView.swift
//  Sentiment Studio Mobile
//
//  Created by Ethan Xu on 2024-04-13.
//

import SwiftUI

struct EmotiView: View {
    var body: some View {
        VStack {
            TitleView(text: "Emotion Predictor")
            CameraView()
        }
    }
}

#Preview {
    EmotiView()
}
