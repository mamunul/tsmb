//
//  ContentView.swift
//  TSMB
//
//  Created by Mamunul Mazid on 13/11/22.
//

//import Network
//import NWWebSocket
//import Starscream
import SwiftUI
import SMBClient

struct ContentView: View {
    let client = TCPClient(address: "punch.onlinewebshop.net", port: 80)
//    @StateObject var presenter = SocketNetworkService()
    var body: some View {
        VStack {
            Image(systemName: "globe")
                .imageScale(.large)
                .foregroundColor(.accentColor)
            Text("Hello, world!")
        }
        .padding()
        .onAppear {
            Task{
                let smbServer = SMBServer(hostname: "", ipAddress: 214312)
                let header = "GET / HTTP/1.1\r\nHost: punch.onlinewebshop.net \r\n\r\n"
                switch client.connect(timeout: 10) {
                case .success:
                    switch client.send(string: header ) {
                    case .success:
                        guard let data = client.read(1024*10) else { return }
                        
                        if let response = String(bytes: data, encoding: .utf8) {
                            print(response)
                        }
                    case .failure(let error):
                        print("fffailure")
                        print(error)
                    }
                case .failure(let error):
                    print("failure")
                    print(error)
                }
            }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
