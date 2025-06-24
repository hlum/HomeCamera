//
//  CameraLogFetcher.swift
//  HomeCamera
//
//  Created by cmStudent on 2025/06/24.
//

import Foundation

struct CameraLog : Identifiable, Decodable {
    var id: String = UUID().uuidString
    var timestamp: String
    var imgURL: String
    
    enum CodingKeys: String, CodingKey {
        case timestamp
        case imgURL = "image_url"
    }
}

class CameraLogFetcher {
    static let shared = CameraLogFetcher()
    
    func getLogs() async -> [CameraLog] {
        let endPoint = "https://24cm0138.main.jp/esp32/detector.php?action=check_log"
        
        do {
            let (data, _) = try await URLSession.shared.data(from: URL(string: endPoint)!)
            let rawString = String(data: data, encoding: .utf8)
            print(rawString ?? "no data")
            let decoder = JSONDecoder()
            return try decoder.decode([CameraLog].self, from: data)
            
        } catch {
            print("Error getting logs: \(error.localizedDescription)")
            return []
        }
    }
}
