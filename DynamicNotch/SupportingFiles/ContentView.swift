//
//  ContentView.swift
//  DynamicNotch
//
//  Created by Patrick Jakobsen on 22/12/2024.
//

import SwiftUI

struct ContentView: View {
    @State private var notch: DynamicNotch<InfoView>?
    @State private var customNotch: DynamicNotch<InfoView>?
    @State private var title = "Hello from the notch!"
    @State private var description = "This is a description"
    
    var body: some View {
        VStack(spacing: 20) {
            Spacer()
            
            Text("DynamicNotch Demo")
                .font(.title2)
            
            VStack(spacing: 15) {
                // Custom Information Demo
                Button(action: {
                    if customNotch == nil {
                        customNotch = DynamicNotch {
                            InfoView(
                                icon: "star.fill",
                                title: "Custom Info",
                                description: "Hover to keep visible"
                            )
                        }
                    }
                    customNotch?.toggle()
                }) {
                    Text(customNotch?.isVisible == true ? "Hide Custom Info" : "Show Custom Info")
                        .foregroundColor(.white)
                        .padding()
                        .background(Color.blue)
                        .cornerRadius(10)
                }
                
                // Notification Demo
                Button(action: {
                    if notch == nil {
                        notch = DynamicNotch {
                            InfoView(
                                icon: "bell.badge.fill",
                                title: "New Notification",
                                description: "This will disappear in 3 seconds"
                            )
                        }
                    }
                    notch?.show(for: 3)
                }) {
                    Text("Show Notification (3s)")
                        .foregroundColor(.white)
                        .padding()
                        .background(Color.green)
                        .cornerRadius(10)
                }
                
                // Different Notification Styles
                Button(action: {
                    Task {
                        if notch == nil {
                            notch = DynamicNotch {
                                InfoView(
                                    icon: "star.fill",
                                    title: "Custom Notification",
                                    description: "With a different icon and longer duration"
                                )
                            }
                        }
                        notch?.show(for: 5)
                        
                        try? await Task.sleep(for: .seconds(2))
                        notch?.setContent {
                            InfoView(
                                icon: "sparkles",
                                title: "Updated Notification",
                                description: "This notification was updated!"
                            )
                        }
                    }
                }) {
                    Text("Show Star Notification (5s with update)")
                        .foregroundColor(.white)
                        .padding()
                        .background(Color.orange)
                        .cornerRadius(10)
                }
                
                // Update Custom Info Demo
                Button(action: {
                    if customNotch == nil {
                        customNotch = DynamicNotch {
                            InfoView(
                                icon: "sparkles.rectangle.stack",
                                title: "Updated Custom Info",
                                description: "This content was updated!"
                            )
                        }
                        customNotch?.show()
                    } else {
                        customNotch?.setContent {
                            InfoView(
                                icon: "sparkles.rectangle.stack",
                                title: "Updated Custom Info \(Int.random(in: 1...100))",
                                description: "This content was updated at \(Date().formatted(date: .omitted, time: .standard))!"
                            )
                        }
                    }
                }) {
                    Text("Update Custom Info")
                        .foregroundColor(.white)
                        .padding()
                        .background(Color.purple)
                        .cornerRadius(10)
                }
            }
            .padding(.bottom, 50)
        }
    }
}

struct InfoView: View {
    let icon: String
    let title: String
    let description: String
    
    var body: some View {
        HStack(spacing: 10) {
            Image(systemName: icon)
                .resizable()
                .foregroundStyle(.white)
                .padding(3)
                .scaledToFit()
            VStack(alignment: .leading) {
                Text(title)
                    .font(.headline)
                    .foregroundStyle(.white)
                Text(description)
                    .font(.caption2)
                    .foregroundStyle(.white.opacity(0.8))
            }
            Spacer(minLength: 0)
        }
        .frame(height: 40)
    }
}

#Preview {
    ContentView()
}
