//
//  ContentView.swift
//  HomeCamera
//
//  Created by cmStudent on 2025/06/24.
//

import SwiftUI

struct ContentView: View {
    @StateObject private var notificationManager = NotificationManager.shared
    @State private var selectedTopic = "news"
    
    @State private var fcmtoken: String = ""
    
    let availableTopics = ["news", "sports", "technology", "weather"]
    
    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
               
                Text("FCMtoken: \(fcmtoken)")
            }
            .onAppear {
                notificationManager.fcmToken
            }
        }
    }
}

#Preview {
    ContentView()
}
