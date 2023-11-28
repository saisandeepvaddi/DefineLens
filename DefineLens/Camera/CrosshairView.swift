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
            .frame(width: 20, height: 20)
            .foregroundColor(.red)
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
    }
}

//
// #Preview {
//    CrosshairView()
// }

// struct CrosshairView: View {
//    var body: some View {
//        GeometryReader { geometry in
//            let frame = geometry.frame(in: .local)
//
//            let midX = frame.midX
//            let midY = frame.midY
//
//            Path { path in
//                // Vertical line
//                path.move(to: CGPoint(x: midX, y: midY - 15))
//                path.addLine(to: CGPoint(x: midX, y: midY + 15))
//
//                // Horizontal line
//                path.move(to: CGPoint(x: midX - 15, y: midY))
//                path.addLine(to: CGPoint(x: midX + 15, y: midY))
//            }
//            .stroke(lineWidth: 2)
//            .foregroundColor(.red)
//        }
//    }
// }
