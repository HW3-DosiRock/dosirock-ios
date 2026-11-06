//
//  NavigationItem.swift
//  DosiRock
//
//  Created by Admin on 11/6/26.
//

import SwiftUI

struct NavigationItem: View {

    let navItem: Navigation
    var isActive: Bool
    var action: () -> Void

    var body: some View {
        
        let tint = isActive ? Color.appTextPrimary : Color.appTextPrimary.opacity(0.7)

        Button(action: action) {
            VStack(spacing: Spacing.xs) {
                //ic
                Image(isActive ? navItem.icActive : navItem.icDef)
                    .renderingMode(isActive ? .original : .template) // original 원본, template 투명 만 빼고 foreground 컬러로 덮기
                    .resizable()
                    .scaledToFit()
                    .frame(width: Size.Icon.medium, height: Size.Icon.medium)
                //label
                Text(navItem.label)
                    .appFont(.caption)
            }
            .foregroundStyle(tint)
            .frame(maxWidth: .infinity, minHeight: Size.minTouch)  // 가로 균등 분할, 세로 최소 터치 영역 44
            .contentShape(Rectangle())                             // 빈 여백까지 눌리게
        }
    }
}

#Preview {
    HStack {
        NavigationItem(navItem: Navigation.thisweek, isActive: true, action: {})
        NavigationItem(navItem: Navigation.thisweek, isActive: false, action: {})
    }.padding()
}
