//
//  SettingsView.swift
//  DefineLens
//
//  Created by Sai Sandeep Vaddi on 11/26/23.
//

import SwiftUI

struct SettingsView: View {
    @AppStorage("videoPreview") var videoPreview: Bool = true
    var body: some View {
        Form {
            Toggle(isOn: $videoPreview) {
                Text("Video Preview")
            }
        }
        .navigationTitle("Settings")
    }
}

#Preview {
    SettingsView()
}
