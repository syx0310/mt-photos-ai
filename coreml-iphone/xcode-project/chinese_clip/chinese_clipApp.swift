//
//  chinese_clipApp.swift
//  chinese_clip
//
//  Created by Yixuan Si on 5/22/24.
//
import SwiftUI

@main
struct chinese_clipApp: App {
    @StateObject var viewModel = WebSocketViewModel()  // Shared ViewModel for the app
    @State var showingAlert = false
    @State var alertMessage = ""

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(viewModel)  // Provide the ViewModel to the views
                .alert(isPresented: $showingAlert) {
                    Alert(title: Text("URL Update"), message: Text(alertMessage), dismissButton: .default(Text("OK")))
                }
                .onOpenURL { url in
                    handleURL(url)
                }
        }
    }

    private func handleURL(_ url: URL) {
        guard let components = URLComponents(url: url, resolvingAgainstBaseURL: true),
              let queryItems = components.queryItems else {
                  updateAlert(message: "Invalid URL: Unable to resolve query components.")
                  return
              }

        if let serverAddress = queryItems.first(where: { $0.name == "serverAddress" })?.value,
           let key = queryItems.first(where: { $0.name == "key" })?.value {
            print(serverAddress)
            if URL.isValidURL(serverAddress) {
                DispatchQueue.main.async {
                    viewModel.serverAddress = serverAddress
                    viewModel.clientKey = key
                    viewModel.saveSettings(newServerAddress: serverAddress, newClientKey: key)  // Assume this method exists and handles UserDefaults
                    updateAlert(message: "Settings have been updated successfully.")
                }
            } else {
                updateAlert(message: "Invalid URL: The server address is not valid.")
            }
        } else {
            updateAlert(message: "Invalid URL: Missing necessary parameters.")
        }
    }

    private func updateAlert(message: String) {
        DispatchQueue.main.async {
            alertMessage = message
            showingAlert = true
        }
    }
}
