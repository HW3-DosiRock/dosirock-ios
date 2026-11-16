//
//  RecipeBadge.swift
//  DosiRock
//
//  Created by Admin on 11/4/26.
//

import SwiftUI

enum RecipeState: String, Codable {
    case useSoon
    case tomorrow
    case cooked
    case used
    case nextWeek

    var title: LocalizedStringKey {
        switch self {
        case .useSoon: "recipe_badge_use_soon"
        case .tomorrow: "recipe_badge_tomorrow"
        case .cooked: "recipe_badge_cooked"
        case .used: "recipe_badge_used"
        case .nextWeek: "recipe_badge_next_week"
        }
    }

    var background: Color {
        switch self {
        case .useSoon: .appSuccessBackground
        case .tomorrow: .appAttentionBackground
        case .cooked: .appTextPrimary
        case .used: .appSurfaceSubtle
        case .nextWeek: .appInfoBackground
        }
    }

    var foreground: Color {
        switch self {
        case .useSoon: .appSuccess
        case .tomorrow: .appAttention
        case .cooked: .appSurface
        case .used: .appTextSecondary
        case .nextWeek: .appInfo
        }
    }
}

struct RecipeBadge: View {

    let type: RecipeState

    var body: some View {
        
        Text(type.title)
            .lineLimit(1)
            .fixedSize(horizontal: true, vertical: false)  // 뱃지 안에서 줄바꿈·잘림 방지
            .padding(.horizontal, Spacing.s)
            .padding(.vertical, Spacing.xs)
            .appFont(.caption)
            .foregroundStyle(type.foreground)
            .background(type.background)
            .clipShape(Capsule())
    }
}

#Preview {
    VStack(spacing: Spacing.s) {
        RecipeBadge(type: .useSoon)
        RecipeBadge(type: .tomorrow)
        RecipeBadge(type: .cooked)
        RecipeBadge(type: .used)
        RecipeBadge(type: .nextWeek)
    }
    .padding(Spacing.screenHorizontal)
    .background(Color.appBackground)
}
