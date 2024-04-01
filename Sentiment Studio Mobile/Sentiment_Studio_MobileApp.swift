//
//  Sentiment_Studio_MobileApp.swift
//  Sentiment Studio Mobile
//
//  Created by Ethan Xu on 2024-04-01.
//

import SwiftUI
import SwiftData

@main
struct Sentiment_Studio_MobileApp: App {
    var sharedModelContainer: ModelContainer = {
        let schema = Schema([
            Item.self,
        ])
        let modelConfiguration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)

        do {
            return try ModelContainer(for: schema, configurations: [modelConfiguration])
        } catch {
            fatalError("Could not create ModelContainer: \(error)")
        }
    }()

    var body: some Scene {
        WindowGroup {
            ContentView()
        }
        .modelContainer(sharedModelContainer)
    }
}
