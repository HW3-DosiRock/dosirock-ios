//
//  AppToolTip.swift
//  DosiRock
//
//  Created by Admin on 11/3/26.
//

import SwiftUI

struct AppToolTip: View {

    let message: String
    var arrowOffset: CGFloat = Spacing.xl
    
    var body: some View {

        VStack(alignment: .leading, spacing: 0) {

            //삼각형
            Triangle()
                .fill(Color.appTextPrimary)
                .frame(width: 16,height: 8)
                .padding(.leading,arrowOffset)
            
            //사각형
            Text(message)
                .appFont(.body)
                .foregroundStyle(Color.appSurface)
                .fixedSize(horizontal: false, vertical: true)
                .padding(.horizontal, Spacing.l)
                .padding(.vertical, Spacing.m)
                .background(Color.appTextPrimary)
                .clipShape(RoundedRectangle(cornerRadius: Radius.large))

        }
    }

    private struct Triangle: Shape {
        func path(in rect: CGRect) -> Path {
            Path { p in
                p.move(to: CGPoint(x: rect.midX, y: rect.minY))  // 위 꼭짓점
                p.addLine(to: CGPoint(x: rect.maxX, y: rect.maxY))  // 오른쪽 아래
                p.addLine(to: CGPoint(x: rect.minX, y: rect.maxY))  // 왼쪽 아래
                p.closeSubpath()
            }
        }
    }
}

#Preview {
    AppToolTip(message: "외식 한 끼 기준 \n 새로 완료하는 도시락부터 적용")
        .padding(Spacing.xl)
        .background(Color.appBackground)
}
