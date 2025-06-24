//
//  ContentView.swift
//  HomeCamera
//
//  Created by cmStudent on 2025/06/24.
//

import SwiftUI

struct ContentView: View {
    @State var logs: [CameraLog] = []

    var body: some View {
        NavigationStack {
    
            ScrollView {
                LazyVStack(spacing: 16) {
                    ForEach(logs) { log in
                        CameraLogCard(log: log)
                    }
                }
                .padding()
            }
            .navigationTitle("侵入者レコード")
            .refreshable {
                self.logs = await CameraLogFetcher.shared.getLogs()
            }
            .task {
                self.logs = await CameraLogFetcher.shared.getLogs()
            }
        }
    }
}

struct CameraLogCard: View {
    let log: CameraLog

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text(log.timestamp)

            AsyncImage(url: URL(string: log.imgURL)) { phase in
                switch phase {
                case .empty:
                    ProgressView()
                        .frame(maxWidth: .infinity)
                        .frame(height: 200)
                        .background(Color.gray.opacity(0.2))
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                case .success(let image):
                    image
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(maxWidth: .infinity)
                        .frame(height: 200)
                        .clipped()
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                case .failure:
                    Image(systemName: "photo")
                        .resizable()
                        .scaledToFit()
                        .frame(maxWidth: .infinity)
                        .frame(height: 200)
                        .foregroundColor(.gray)
                        .background(Color.gray.opacity(0.1))
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                @unknown default:
                    EmptyView()
                }
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(16)
        .shadow(color: Color.black.opacity(0.05), radius: 5, x: 0, y: 2)
    }
}

#Preview {
    ContentView()
}
