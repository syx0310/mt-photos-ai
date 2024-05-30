import SwiftUI

struct ContentView: View {
    @EnvironmentObject var viewModel: WebSocketViewModel
    @State private var showingSettings = false

    var body: some View {
        NavigationView {
            VStack {
                WebSocketView()
            }
            .navigationTitle("ChineseCLIP")
            .navigationBarItems(trailing: Button(action: {
                showingSettings = true
            }) {
                Image(systemName: "gearshape.fill")
            }
            .sheet(isPresented: $showingSettings) {
                SettingsView().environmentObject(viewModel)
            })
        }
    }
}