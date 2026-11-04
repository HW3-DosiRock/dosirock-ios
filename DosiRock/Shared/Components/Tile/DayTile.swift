//
//  DayTile.swift
//  DosiRock
//
//  Created by Admin on 11/3/26.
//

import SwiftUI

struct DayTile: View {

    let dayOfWeek: String
    let day: String
    var isDone: Bool = false
    var isClicked: Bool = false
    var action: () -> Void = {}

    var body: some View {

        Button(action: action) {
            ZStack(alignment: .topTrailing) {
                VStack(spacing: Spacing.s) {

                    Text(dayOfWeek)
                        .appFont(.heading)
                        .lineLimit(1)

                    Text(day)
                        .appFont(.caption)
                        .lineLimit(1)

                }
                .foregroundStyle(
                    isClicked ? Color.appSurface : Color.appTextPrimary
                )
                .padding(Spacing.s)
                .frame(maxWidth: .infinity)
                .background(
                    isClicked ? Color.appPrimary : Color.appSurface
                )
                .clipShape(RoundedRectangle(cornerRadius: Radius.medium))
                .overlay(
                    RoundedRectangle(cornerRadius: Radius.medium)
                        .stroke(Color.appBorder, lineWidth: 1)
                )
                .animation(.easeOut(duration: 0.15), value: isClicked)

                if isDone {
                    Circle()
                        .fill(isClicked ? Color.appSurface : Color.appSuccess)
                        .frame(width: 4, height: 4)
                        .padding(Spacing.s)
                }
            }

        }
        .buttonStyle(TilePressStyle())
    }
    
}

#Preview {
    @Previewable @State var selectedDay = "11/5"

    let week = [
        ("월", "11/3", true),
        ("화", "11/4", true),
        ("수", "11/5", false),
        ("목", "11/6", false),
        ("금", "11/7", false),
        ("토", "11/8", false),
        ("일", "11/9", false),
    ]

    HStack(spacing: Spacing.xs) {
        ForEach(week, id: \.1) { dayOfWeek, day, isDone in
            DayTile(
                dayOfWeek: dayOfWeek,
                day: day,
                isDone: isDone,
                isClicked: selectedDay == day
            ) {
                selectedDay = day  // 누른 날짜로 선택 변경
            }
        }
    }
    .padding(Spacing.screenHorizontal)
    .background(Color.appBackground)
}
