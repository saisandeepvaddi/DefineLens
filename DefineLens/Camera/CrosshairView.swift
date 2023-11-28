//
//  CrosshairView.swift
//  DefineLens
//
//  Created by Sai Sandeep Vaddi on 11/27/23.
//

import SwiftUI

struct CrosshairView: View {
    var body: some View {
        Image(systemName: "circle")
            .resizable()
            .scaledToFit()
            .frame(width: 15, height: 15)
            .foregroundColor(.red)
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
    }
}

#Preview {
    CrosshairView()
}
