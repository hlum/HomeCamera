//
//  NotificationManager.swift
//  HomeCamera
//
//  Created by cmStudent on 2025/06/24.
//


import Foundation
import Firebase
import FirebaseMessaging
import UserNotifications
import UIKit

class NotificationManager: ObservableObject {
    @Published var fcmToken: String = ""
    @Published var notificationMessage: String = ""
    @Published var showAlert: Bool = false
    
    static let shared = NotificationManager()
    
    private init() {
        setupNotificationObserver()
    }
    
    // MARK: - Public Methods
    
    func initialize() {
        requestNotificationPermissions()
        getFCMToken()
    }
    
    func getFCMToken() {
        Messaging.messaging().token { [weak self] token, error in
            if let error = error {
                print("Error fetching FCM registration token: \(error)")
                return
            }
            
            if let token = token {
                print("FCM registration token: \(token)")
                DispatchQueue.main.async {
                    self?.fcmToken = token
                }
                // Send token to your server here if needed
                self?.sendTokenToServer(token)
            }
        }
    }
    
    func subscribeToTopic(_ topic: String) {
        Messaging.messaging().subscribe(toTopic: topic) { [weak self] error in
            DispatchQueue.main.async {
                if let error = error {
                    print("Error subscribing to topic \(topic): \(error)")
                    self?.showNotificationAlert("Failed to subscribe to \(topic)")
                } else {
                    print("Successfully subscribed to topic: \(topic)")
                    self?.showNotificationAlert("Successfully subscribed to '\(topic)' topic!")
                }
            }
        }
    }
    
    func unsubscribeFromTopic(_ topic: String) {
        Messaging.messaging().unsubscribe(fromTopic: topic) { [weak self] error in
            DispatchQueue.main.async {
                if let error = error {
                    print("Error unsubscribing from topic \(topic): \(error)")
                    self?.showNotificationAlert("Failed to unsubscribe from \(topic)")
                } else {
                    print("Successfully unsubscribed from topic: \(topic)")
                    self?.showNotificationAlert("Successfully unsubscribed from '\(topic)' topic!")
                }
            }
        }
    }
    
    func handleNotificationTap(userInfo: [AnyHashable: Any]) {
        // Handle notification data when user taps on notification
        print("Notification tapped with data: \(userInfo)")
        
        // Extract custom data if available
        if let customData = userInfo["customData"] as? String {
            DispatchQueue.main.async {
                self.showNotificationAlert("Notification tapped: \(customData)")
            }
        }
        
        // Handle deep linking or navigation based on notification data
        handleDeepLink(from: userInfo)
    }
    
    func handleForegroundNotification(userInfo: [AnyHashable: Any]) {
        // Handle notification received while app is in foreground
        print("Notification received in foreground: \(userInfo)")
        
        if let aps = userInfo["aps"] as? [String: Any],
           let alert = aps["alert"] as? [String: Any],
           let title = alert["title"] as? String,
           let body = alert["body"] as? String {
            
            DispatchQueue.main.async {
                self.showNotificationAlert("\(title): \(body)")
            }
        }
    }
    
    // MARK: - Private Methods
    
    private func requestNotificationPermissions() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { granted, error in
            if granted {
                print("Notification permission granted")
            } else {
                print("Notification permission denied")
            }
            
            if let error = error {
                print("Notification permission error: \(error)")
            }
        }
    }
    
    private func setupNotificationObserver() {
        NotificationCenter.default.addObserver(
            forName: NSNotification.Name("FCMTokenRefreshed"),
            object: nil,
            queue: .main
        ) { [weak self] notification in
            if let token = notification.userInfo?["token"] as? String {
                self?.fcmToken = token
                self?.sendTokenToServer(token)
            }
        }
    }
    
    private func sendTokenToServer(_ token: String) {
        // Send the FCM token to your server
        // This is where you'd make an API call to register the device
        print("Sending token to server: \(token)")
        
        // Example API call structure:
        /*
        let url = URL(string: "https://your-server.com/api/register-device")!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let body = ["fcm_token": token, "user_id": getCurrentUserId()]
        request.httpBody = try? JSONSerialization.data(withJSONObject: body)
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            // Handle response
        }.resume()
        */
    }
    
    private func handleDeepLink(from userInfo: [AnyHashable: Any]) {
        // Handle deep linking based on notification data
        if let deepLink = userInfo["deepLink"] as? String {
            // Navigate to specific screen based on deep link
            print("Handling deep link: \(deepLink)")
            
            // Post notification for UI to handle navigation
            NotificationCenter.default.post(
                name: NSNotification.Name("HandleDeepLink"),
                object: nil,
                userInfo: ["deepLink": deepLink]
            )
        }
    }
    
    private func showNotificationAlert(_ message: String) {
        self.notificationMessage = message
        self.showAlert = true
    }
    
    // MARK: - Utility Methods
    
    func clearNotificationBadge() {
        UNUserNotificationCenter.current().removeAllDeliveredNotifications()
        UIApplication.shared.applicationIconBadgeNumber = 0
    }
    
    func getAvailableTopics() -> [String] {
        // Return list of available topics for subscription
        return ["news", "sports", "weather", "updates", "promotions"]
    }
}
