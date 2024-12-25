//
//  ContentView.swift
//  MultipieerApp
//
//  Created by Вячеслав Вовк on 25.12.2024.
//

import SwiftUI

struct ContentView: View {
    @StateObject private var multipeerManager = MultipeerManager()
    @State private var message: String = ""
    
    var body: some View {
        NavigationView {
            VStack {
                List(multipeerManager.messages, id: \.self) { msg in
                    Text(msg)
                }
                HStack {
                    TextField("Enter message", text: $message)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                    Button(action: {
                        multipeerManager.sendMessage(message)
                        message = ""
                    }) {
                        Text("Send")
                    }
                }
                .padding()
            }
            .navigationBarTitle("Multipeer Chat")
        }
    }
}


#Preview {
    ContentView()
}
