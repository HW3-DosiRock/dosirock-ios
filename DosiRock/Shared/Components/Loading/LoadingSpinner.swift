//
//  LoadingSpinner.swift
//  DosiRock
//
//  Created by Admin on 11/3/26.
//

import SwiftUI

struct LoadingSpinner: View {
    
    var color: Color = .appPrimary
    var size: CGFloat = Size.Spinner.small
    var lineWidth: CGFloat = 2.5

    @State private var isRotating = false

    var body: some View {
        Circle()
            .trim(from: 0, to: 0.75)
            .stroke(color, style: StrokeStyle(lineWidth: lineWidth, lineCap: .round))
            .frame(width: size, height: size)
            .rotationEffect(.degrees(isRotating ? 360 : 0))
            .animation(
                .linear(duration: 0.8).repeatForever(autoreverses: false),
                value: isRotating
            )
            .onAppear { isRotating = true }
    }
}

#Preview {
    HStack(spacing: Spacing.xl) {
        LoadingSpinner()
        LoadingSpinner(size: 30, lineWidth: 4)
    }
}
