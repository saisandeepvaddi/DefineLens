//
//  ModeChanger.swift
//  DefineLens
//
//  Created by Sai Sandeep Vaddi on 12/1/23.
//

import SwiftUI

struct ModeChanger: View {
    @EnvironmentObject var appState: AppState
    var body: some View {
        VStack {
            Spacer()
            HStack(spacing: 0) {
                ForEach(Modes.allCases, id: \.self.rawValue) { mode in
                    Text(mode.rawValue)
                        .frame(maxWidth: .infinity)
                        .background(Color.gray.opacity(mode == appState.mode ? 0.2 : 0))
                        .onTapGesture {
                            withAnimation {
                                appState.mode = mode
                            }
                        }
                }
            }
            .font(.title)
            .padding(.horizontal)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .foregroundColor(.white)
    }
}
