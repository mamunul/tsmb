//
//  ContentView.swift
//  TSMB
//
//  Created by Mamunul Mazid on 13/11/22.
//

import SwiftUI

struct ContentView: View {
    @StateObject var presenter = SocketNetworkService()
    var body: some View {
        VStack {
            Image(systemName: "globe")
                .imageScale(.large)
                .foregroundColor(.accentColor)
            Text("Hello, world!")
        }
        .padding()
        .onAppear {
            presenter.openWebSocket()
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}

class SocketNetworkService: ObservableObject {
    // https://appspector.com/blog/websockets-in-ios-using-urlsessionwebsockettask
    // https://jayeshkawli.ghost.io/using-websockets-on-ios-using/
    func openWebSocket() {
        let urlString = "https://punch.onlinewebshop.net?client-id=mac&exclude-me"
        guard let url = URL(string: urlString) else { return }
        var urlRequest = URLRequest(url: url)

        let session = URLSession(configuration: .default)
        let webSocket = session.webSocketTask(with: urlRequest)

//        let message = URLSessionWebSocketTask.Message.string("Hello Socket")
//        webSocket.send(message) { error in
//            if let error = error {
//                print("WebSocket sending error: \(error)")
//            }
//        }

        webSocket.receive { result in
            switch result {
            case let .failure(error):
                print("Failed to receive message: \(error)")
            case let .success(message):
                switch message {
                case let .string(text):
                    print("Received text message: \(text)")
                case let .data(data):
                    print("Received binary message: \(data)")
                @unknown default:
                    fatalError()
                }
            }
        }
        webSocket.resume()
    }
}
