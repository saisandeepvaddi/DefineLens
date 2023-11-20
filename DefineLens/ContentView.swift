//
//  ContentView.swift
//  DefineLens
//
//  Created by Sai Sandeep Vaddi on 11/19/23.
//

import SwiftUI

struct ContentView: View {
    @State private var isARSessionActive = false

    var body: some View {
        VStack {
            ARTextView(isActive: $isARSessionActive)
                .edgesIgnoringSafeArea(.all)
                .disabled(!isARSessionActive)

            Button(action: {
                isARSessionActive.toggle()
            }) {
                Text(isARSessionActive ? "Stop" : "Start")
            }
            .padding()
            .background(Color.blue)
            .foregroundColor(.white)
            .cornerRadius(10)
        }
    }
}

#Preview {
    ContentView()
}
