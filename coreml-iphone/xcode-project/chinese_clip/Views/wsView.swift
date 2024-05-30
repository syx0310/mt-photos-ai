import SwiftUI
import Combine
import Foundation

class WebSocketViewModel: ObservableObject {
    @Published var serverAddress = "ws://10.16.50.133:8765" // Default address
    @Published var logMessages: [String] = []
    @Published var isConnected = false
    @Published var averageSpeed = "N/A"
    @Published var clientKey = "12345"
    @Published var showAlert = false
    

    var imageClient: WebSocketImageClient?
    var imgEncoder: ImgEncoder?
    
    private var lastProcessingTimes: [Date] = []

    init() {
        do {
            let baseURL = URL(fileURLWithPath: Bundle.main.resourcePath!)
            self.imgEncoder = try ImgEncoder(resourcesAt: baseURL)
            setupClient()
        } catch {
            appendLog("Initialization of ImgEncoder failed")
            self.imgEncoder = nil
        }
        loadSettings()
    }
    
    func saveSettings(newServerAddress: String, newClientKey: String) {
        if URL.isValidURL(newServerAddress) {
            DispatchQueue.main.async {
                self.serverAddress = newServerAddress
                self.clientKey = newClientKey
                UserDefaults.standard.set(newServerAddress, forKey: "ServerAddress")
                UserDefaults.standard.set(newClientKey, forKey: "ClientKey")
                UserDefaults.standard.synchronize()
                self.showAlert = false
            }
        } else {
            DispatchQueue.main.async {
                self.showAlert = true
            }
        }
    }

    func loadSettings() {
        serverAddress = UserDefaults.standard.string(forKey: "ServerAddress") ?? "ws://10.16.50.133:8765"
        clientKey = UserDefaults.standard.string(forKey: "ClientKey") ?? "12345"
    }

    
    private func setupClient() {
        guard let encoder = imgEncoder else { return }
        let serverURL = URL(string: serverAddress)!
        imageClient = WebSocketImageClient(serverURL: serverURL, encoder: encoder)
        imageClient?.onConnectionStatusChanged = { [weak self] isConnected in
            DispatchQueue.main.async {
                self?.isConnected = isConnected
            }
        }
        imageClient?.onProcessingCompleted = { [weak self] in
            DispatchQueue.main.async {
                self?.recordProcessingTime()
            }
        }
    }

    func connect() {
        setupClient()  // 确保 client 是最新的
        imageClient?.connect(withKey: clientKey)
        appendLog("Attempting to connect to \(serverAddress) with key \(clientKey)")
    }

    func disconnect() {
        imageClient?.disconnect()
        appendLog("Disconnected")
    }

    private func appendLog(_ message: String) {
        DispatchQueue.main.async {
            self.logMessages.append(message)
        }
    }

    private func recordProcessingTime() {
        lastProcessingTimes.append(Date())
        lastProcessingTimes = lastProcessingTimes.filter { Date().timeIntervalSince($0) <= 5 }
        if lastProcessingTimes.count > 1 {
            let total = Double(lastProcessingTimes.count - 1)
            let duration = lastProcessingTimes.last!.timeIntervalSince(lastProcessingTimes.first!)
            let average = total / duration
            averageSpeed = String(format: "%.2f imgae/sec", average)
        } else {
            averageSpeed = "N/A"
        }
    }
}

struct WebSocketView: View {
    @EnvironmentObject var viewModel: WebSocketViewModel

    var body: some View {
        VStack {
            HStack {
                // Server Address occupying two-thirds of the screen
                VStack(alignment: .leading) {
                    Text("Server Address:")
                    Text(viewModel.serverAddress)
                        .font(.system(size: 18))
                        .foregroundColor(.secondary)
                        .padding(.top, 2) // Slight padding for alignment
                }
                .padding(.horizontal)
                .frame(width: UIScreen.main.bounds.width * 2 / 3, alignment: .leading)

                Spacer() // Separates address and key

                // Key occupying one-third of the screen
                VStack(alignment: .leading) {
                    Text("Key:")
                    Text(viewModel.clientKey)
                        .font(.system(size: 18))
                        .foregroundColor(.secondary)
                        .padding(.top, 2)
                }
                .padding(.horizontal)
                .frame(width: UIScreen.main.bounds.width / 3, alignment: .leading)
            }
            .padding(.top)

            Button(action: {
                if viewModel.isConnected {
                    viewModel.disconnect()
                } else {
                    viewModel.connect()
                }
            }) {
                Text(viewModel.isConnected ? "Disconnect" : "Connect")
                    .foregroundColor(.white)
                    .padding()
                    .background(viewModel.isConnected ? Color.red : Color.blue)
                    .cornerRadius(10)
            }
            .padding()

            Text("Average Processing Speed: \(viewModel.averageSpeed)")
                .padding()

            ScrollView {
                ScrollViewReader { value in
                    VStack(alignment: .leading) {
                        ForEach(viewModel.logMessages, id: \.self) { msg in
                            Text(msg)
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .padding(3)
                        }
                    }
                    .frame(width: 350)
                }
            }
            .frame(width: 350, height: 370)
            .border(Color.gray, width: 1)
            .cornerRadius(10)
            .padding()
        }
    }
}

