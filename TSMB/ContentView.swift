//
//  ContentView.swift
//  TSMB
//
//  Created by Mamunul Mazid on 13/11/22.
//

import Network
import NWWebSocket
import Starscream
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
//            Task {
                presenter.openWebSocket()
//                presenter.openUsingLibrary()
//                presenter.openSocketWithStarScream()
//            }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}

class SocketNetworkService: NSObject, ObservableObject {
    // https://appspector.com/blog/websockets-in-ios-using-urlsessionwebsockettask
    // https://jayeshkawli.ghost.io/using-websockets-on-ios-using/

    var webSocket: URLSessionWebSocketTask?
    var nwSocket: NWWebSocket?
    var starScreamSocket: WebSocket?

    let socketUrl =
//    "ws://punch.onlinewebshop.net?client-id=mac&exclude-me"
    "ws://socketsbay.com/wss/v2/2/demo/"
    let httpUrl = "http://punch.onlinewebshop.net?client-id=mac&exclude-me"
    
    var urlString = ""
    
    override init() {
        urlString = socketUrl
    }

    func openSocketWithStarScream() {
        var request = URLRequest(url: URL(string: urlString)!)
//        request.timeoutInterval = 5
        starScreamSocket = WebSocket(request: request)
        starScreamSocket?.delegate = self
        starScreamSocket?.connect()
    }

    func openUsingLibrary() {
        let url = URL(string: urlString)!
        nwSocket = NWWebSocket(url: url)
        nwSocket?.delegate = self
        nwSocket?.connect()

        // Use the WebSocket…

//        socket.disconnect()
    }

    func openWebSocket() {
        guard let url = URL(string: urlString) else { return }
        let urlRequest = URLRequest(url: url)
//        urlRequest.networkServiceType = .responsiveData
//        urlRequest.timeoutInterval = 10
        let session = URLSession(configuration: .default, delegate: self, delegateQueue: nil)
        webSocket = session.webSocketTask(with: urlRequest)

//        let message = URLSessionWebSocketTask.Message.string("Hello Socket")
//        webSocket.send(message) { error in
//            if let error = error {
//                print("WebSocket sending error: \(error)")
//            }
//        }
        webSocket?.resume()
        webSocket?.receive { result in
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
    }
}

extension SocketNetworkService: URLSessionWebSocketDelegate {
    func urlSession(_ session: URLSession, webSocketTask: URLSessionWebSocketTask, didOpenWithProtocol protocol: String?) {
        print("socket open")
    }

    func urlSession(_ session: URLSession, webSocketTask: URLSessionWebSocketTask, didCloseWith closeCode: URLSessionWebSocketTask.CloseCode, reason: Data?) {
        print("socket closed")
    }

    func urlSession(_ session: URLSession, task: URLSessionTask, didCompleteWithError: Error?) {
        print("socket error:\(didCompleteWithError)")
    }
}

extension SocketNetworkService: WebSocketDelegate {
    func didReceive(event: Starscream.WebSocketEvent, client: Starscream.WebSocket) {
        switch event {
        case let .connected(headers):
//            isConnected = true
            print("websocket is connected: \(headers)")
        case let .disconnected(reason, code):
//            isConnected = false
            print("websocket is disconnected: \(reason) with code: \(code)")
        case let .text(string):
            print("Received text: \(string)")
        case let .binary(data):
            print("Received data: \(data.count)")
        case .ping:
            break
        case .pong:
            break
        case .viabilityChanged:
            break
        case .reconnectSuggested:
            break
        case .cancelled:
            print("cancelled")
//            isConnected = false
        case let .error(error):
            print(error)
//            isConnected = false
//            handleError(error)
        }
    }
}

extension SocketNetworkService: WebSocketConnectionDelegate {
    func webSocketDidConnect(connection: WebSocketConnection) {
        // Respond to a WebSocket connection event
        print("socket connected")
    }

    func webSocketDidDisconnect(connection: WebSocketConnection,
                                closeCode: NWProtocolWebSocket.CloseCode, reason: Data?) {
        // Respond to a WebSocket disconnection event
        print("socket disconnect:\(reason)")
    }

    func webSocketViabilityDidChange(connection: WebSocketConnection, isViable: Bool) {
        // Respond to a WebSocket connection viability change event
        print("socket webSocketViabilityDidChange:\(isViable)")
    }

    func webSocketDidAttemptBetterPathMigration(result: Result<WebSocketConnection, NWError>) {
        // Respond to when a WebSocket connection migrates to a better network path
        // (e.g. A device moves from a cellular connection to a Wi-Fi connection)
        print("socket webSocketDidAttemptBetterPathMigration")
    }

    func webSocketDidReceiveError(connection: WebSocketConnection, error: NWError) {
        // Respond to a WebSocket error event
        print("socket receive error:\(error)")
    }

    func webSocketDidReceivePong(connection: WebSocketConnection) {
        // Respond to a WebSocket connection receiving a Pong from the peer
        print("socket receive pong")
    }

    func webSocketDidReceiveMessage(connection: WebSocketConnection, string: String) {
        // Respond to a WebSocket connection receiving a `String` message
        print("socket recieve string message:\(string)")
    }

    func webSocketDidReceiveMessage(connection: WebSocketConnection, data: Data) {
        // Respond to a WebSocket connection receiving a binary `Data` message
        print("socket receive data message:\(data)")
    }
}
