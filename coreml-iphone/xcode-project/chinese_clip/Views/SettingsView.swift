//
//  SettingsView.swift
//  chinese_clip
//
//  Created by Yixuan Si on 5/30/24.
//

import SwiftUI

struct SettingsView: View {
    @EnvironmentObject var viewModel: WebSocketViewModel
    @Environment(\.presentationMode) var presentationMode
    @State private var tempServerAddress: String = ""
    @State private var tempClientKey: String = ""

    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Connection Settings")) {
                    TextField("Server Address", text: $tempServerAddress)
                        .autocapitalization(.none)
                        .keyboardType(.URL)
                        .disableAutocorrection(true)
                    TextField("Key", text: $tempClientKey)
                        .autocapitalization(.none)
                        .keyboardType(.default)
                        .disableAutocorrection(true)
                }

                Section {
                    Button("Save Changes") {
                        viewModel.saveSettings(newServerAddress: tempServerAddress, newClientKey: tempClientKey)
                        if !viewModel.showAlert {
                            presentationMode.wrappedValue.dismiss()
                        }
                    }
                    .foregroundColor(.blue)

                    Button("Cancel") {
                        presentationMode.wrappedValue.dismiss()
                    }
                    .foregroundColor(.red)
                }
            }
            .alert("Invalid URL", isPresented: $viewModel.showAlert) {
                Button("OK", role: .cancel) {}
            } message: {
                Text("Please enter a valid URL for the server address.")
            }
            .onAppear {
                tempServerAddress = viewModel.serverAddress
                tempClientKey = viewModel.clientKey
            }
        }
    }
}
