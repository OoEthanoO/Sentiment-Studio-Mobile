//
//  LSTMView.swift
//  Sentiment Studio Mobile
//
//  Created by Ethan Xu on 2024-04-01.
//

import SwiftUI

struct LSTMView: View {
    @State private var userText = ""
    @State private var sentiment = "Please enter text"
    @State private var probabilities = [0.0, 0.0, 0.0]
    @State private var timer: Timer?
    var body: some View {
        VStack {
            TitleView(text: "Sentiment Predictor")
            TextField("Please enter text", text: Binding(get: { userText }, set: { newValue in
                userText = newValue
                resetTimer()
            }))
            .padding([.top, .leading, .trailing], 30)
            .frame(height: 80)
            AlertView(text: sentiment, color: Color.accentColor)
            if sentiment == "Please enter text" || sentiment == "Processing..." {
                AlertView(text: "", color: Color.green)
                AlertView(text: "", color: Color.yellow)
                AlertView(text: "", color: Color.red)
            } else {
                AlertView(text: "Positive: " + String(format: "%.2f", probabilities[0] * 100) + "%", color: Color.green)
                AlertView(text: "Neutral: " + String(format: "%.2f", probabilities[1] * 100) + "%", color: Color.yellow)
                AlertView(text: "Negative: " + String(format: "%.2f", probabilities[2] * 100) + "%", color: Color.red)
            }
            
            Spacer()
        }
    }
    
    func sendSentimentRequest(text: String) {
        if text.isEmpty {
            self.sentiment = "Please enter text"
            self.probabilities = [0.0, 0.0, 0.0]
            return
        }
        
        let urlString = "https://sentiment-studio-api.loca.lt/lstmPredict"
        
        guard let url = URL(string: urlString) else {
            print("Error creating URL")
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        guard let jsonData = try? JSONSerialization.data(withJSONObject: ["text": text], options: []) else {
            print("Error creating JSON data")
            return
        }
        
        request.httpBody = jsonData
        
        request.setValue("some-value", forHTTPHeaderField: "bypass-tunnel-reminder")
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                print("Error sending request:", error)
                return
            }
            
            guard let data = data, let response = response as? HTTPURLResponse else {
                print("Invalid response")
                return
            }
            
            print("Status code:", response.statusCode)
            do {
                let jsonResponse = try JSONSerialization.jsonObject(with: data, options: [])
                guard let dictionary = jsonResponse as? [String: Any],
                        let probabilities = dictionary["probabilities"] as? [Double],
                        let sentiment = dictionary["sentiment"] as? String else {
                    print("Invalid JSON response format")
                    return
                }
                
                self.sentiment = sentiment
                self.probabilities = probabilities
            } catch {
                print("Error decoding JSON response:", error)
            }
        }
        .resume()
    }
    
    private func resetTimer() {
        timer?.invalidate()
        self.sentiment = "Processing..."
        timer = Timer.scheduledTimer(withTimeInterval: 0.3, repeats: false) { _ in
            sendSentimentRequest(text: userText)
        }
    }
}

#Preview {
    LSTMView()
}
