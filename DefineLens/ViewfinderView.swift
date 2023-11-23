//
//  ViewfinderView.swift
//  DefineLens
//
//  Created by Sai Sandeep Vaddi on 11/22/23.
//

import SwiftUI

struct ViewfinderView: View {
    @Binding var image: Image?

    var body: some View {
        GeometryReader { geometry in
            if let image = image {
                image
                    .resizable()
                    .scaledToFill()
                    .frame(width: geometry.size.width, height: geometry.size.height)
            }
        }
    }
}
