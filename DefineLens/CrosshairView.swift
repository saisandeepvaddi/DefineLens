//
//  CrosshairView.swift
//  DefineLens
//
//  Created by Sai Sandeep Vaddi on 11/21/23.
//

import SwiftUI

struct CrosshairView: View {
    var body: some View {
        Circle()
            .frame(width: 30, height: 30)
            .overlay(Circle().stroke(Color.black, lineWidth: 2))
    }
}
