//
//  CameraView.swift
//  Sentiment Studio Mobile
//
//  Created by Ethan Xu on 2024-04-13.
//

import SwiftUI

struct CameraView: UIViewControllerRepresentable {
    typealias UIViewControllerType = ViewController
    
    func makeUIViewController(context: Context) -> ViewController {
        return ViewController()
    }
    
    func updateUIViewController(_ uiViewController: ViewController, context: Context) {
        
    }
}

#Preview {
    CameraView()
}
