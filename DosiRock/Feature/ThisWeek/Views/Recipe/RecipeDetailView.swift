//
//  RecipeDetailView.swift
//  DosiRock
//

import SwiftUI

// W-02 레시피 상세: 이번 주 목록에서 메뉴를 누르면 이동
struct RecipeDetailView: View {

    // AI가 레시피(조리 순서)를 만드는 단계
    enum Phase { case generating, failed, ready }

    @Environment(Router<ThisWeekRoute>.self) private var router

    let day: MealPlanDay
    let menu: Menu
    var recipe: RecipeDetail? = nil  // 서버가 만든 상세 레시피 (재료 상태 · 조리 순서 · 예상 재료비)
    var badges: [RecipeState] = []  // 이름 아래 뱃지 (빨리 쓸 재료 사용 · 추가 재료 필요)
    var isConfirmed = false  // 계획이 확정돼야 조리 완료 가능
    var phase: Phase = .ready
    var isCooked = false
    var onRetry: () -> Void = {}
    var onComplete: () -> Void = {}

    private var hasShortage: Bool { recipe?.ingredients.contains { $0.isShort } == true }

    var body: some View {
        VStack(spacing: 0) {

            NavigationHeader(
                title: LocalizedStringResource(stringLiteral: "\(day.weekdayText) \(day.dayText)"),  // "월 11/9"
                leadingTitle: .recipeDetailBack,
                onLeadingTap: { router.pop() }
            )

            switch phase {
            case .generating:
                VStack(alignment: .leading, spacing: Spacing.m) {
                    titleBlock
                    Spacer()
                    generatingContent
                    Spacer()
                }
                .padding(.horizontal, Spacing.screenHorizontal)
            case .failed:
                VStack(alignment: .leading, spacing: Spacing.m) {
                    titleBlock
                    AppBanner(
                        type: .attention,
                        message: String(localized: .recipeDetailFailed),
                        actionMessage: .commonRetry,
                        action: onRetry
                    )
                    Spacer()
                }
                .padding(.horizontal, Spacing.screenHorizontal)
            case .ready:
                ScrollView {
                    VStack(alignment: .leading, spacing: Spacing.m) {
                        titleBlock
                        if let recipe {
                            ingredientsSection(recipe)
                            stepsSection(recipe.steps)
                            if let cost = recipe.costText { costRow(cost) }
                        }
                    }
                    .padding(.horizontal, Spacing.screenHorizontal)
                    .padding(.bottom, Spacing.xl)
                }
            }

            bottomButton
                .padding(.horizontal, Spacing.screenHorizontal)
                .padding(.bottom, Spacing.m)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.appBackground.ignoresSafeArea())
        .navigationBarBackButtonHidden(true)  // 기본 뒤로 버튼 대신 NavigationHeader (스와이프 뒤로가기는 동작)
    }

    // 메뉴 이름 · 조리 시간 · 뱃지
    private var titleBlock: some View {
        VStack(alignment: .leading, spacing: 0) {
            Text(menu.name)
                .appFont(.brandEmphasis)
                .foregroundStyle(Color.appTextPrimary)
            Text(String(format: String(localized: "recipe_detail_minutes"), menu.cookMinutes))
                .appFont(.subbody)
                .foregroundStyle(Color.appTextSecondary)
            let shown = isCooked ? [RecipeState.cooked] : badges
            if !shown.isEmpty {
                HStack(spacing: Spacing.xs) {
                    ForEach(shown, id: \.self) { RecipeBadge(type: $0) }
                }
                .padding(.top, Spacing.s)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    private var generatingContent: some View {
        VStack(spacing: Spacing.l) {
            Image(.logoStone)
                .resizable()
                .scaledToFit()
                .frame(width: 104)
                .accessibilityHidden(true)
            Text(.recipeDetailGenerating)
                .appFont(.brandSubtitle)
                .foregroundStyle(Color.appTextPrimary)
        }
        .frame(maxWidth: .infinity)
    }

    // 재료: 3열 타일 (부족한 재료는 빨간 타일) + 추가로 필요한 재료 보기
    private func ingredientsSection(_ recipe: RecipeDetail) -> some View {
        VStack(alignment: .leading, spacing: Spacing.m) {
            HStack {
                Text(.recipeDetailIngredients)
                    .appFont(.heading)
                    .foregroundStyle(Color.appTextPrimary)
                Spacer()
                Text(.recipeDetailUsageBasis)
                    .appFont(.subbody)
                    .foregroundStyle(Color.appTextSecondary)
            }
            .padding(.top, Spacing.s)

            LazyVGrid(
                columns: Array(repeating: GridItem(.flexible(), spacing: Spacing.s), count: 3),
                spacing: Spacing.s
            ) {
                ForEach(recipe.ingredients, id: \.ingredientId) { item in
                    IngredientTile(
                        label: item.name,
                        imageName: item.imageName,
                        details: [item.amountText],
                        badge: tileBadge(item),
                        type: !isCooked && item.isShort ? .shortage : .info
                    )
                }
            }

            if hasShortage && !isCooked {
                Button {
                    router.push(.shortages)
                } label: {
                    HStack(spacing: Spacing.s) {
                        AppIcon(.cart, size: Size.Icon.small)
                        Text(.recipeDetailShowShortages)
                            .appFont(.heading)
                    }
                    .foregroundStyle(Color.appTextPrimary)
                    .frame(maxWidth: .infinity, minHeight: Size.minTouch)
                    .background(
                        RoundedRectangle(cornerRadius: Radius.medium).fill(Color.appSurfaceSubtle)
                    )
                    .contentShape(Rectangle())
                }
                .buttonStyle(.plain)
            }
        }
    }

    // 조리 전: 충분 / 부족 (기본 재료는 보유 / 부족), 조리 후: 사용함
    private func tileBadge(_ item: RecipeIngredient) -> RecipeBadge {
        if isCooked {
            return RecipeBadge(type: .used)
        }
        if item.isShort {
            return RecipeBadge(type: .lacking)
        }
        return RecipeBadge(
            type: .useSoon,
            title: item.managementType == .presence ? "recipe_tile_owned" : "recipe_tile_enough"
        )
    }

    // 조리 순서: 번호 원 + 문장
    private func stepsSection(_ steps: [RecipeStep]) -> some View {
        VStack(alignment: .leading, spacing: Spacing.m) {
            Text(.recipeDetailSteps)
                .appFont(.heading)
                .foregroundStyle(Color.appTextPrimary)
                .padding(.top, Spacing.s)

            VStack(alignment: .leading, spacing: 10) {
                ForEach(steps, id: \.stepNumber) { step in
                    HStack(alignment: .top, spacing: 10) {
                        Text("\(step.stepNumber)")
                            .appFont(.caption)
                            .foregroundStyle(Color.appSurface)
                            .frame(width: Size.Icon.large, height: Size.Icon.large)
                            .background(Circle().fill(Color.appTextPrimary))
                        Text(step.instruction)
                            .appFont(.body)
                            .foregroundStyle(Color.appTextPrimary)
                            .frame(maxWidth: .infinity, alignment: .leading)
                    }
                }
            }
            .padding(.vertical, 14)
            .padding(.horizontal, Spacing.l)
            .recipeCard()
        }
    }

    private func costRow(_ cost: Int) -> some View {
        HStack {
            Text(.recipeDetailCost)
                .appFont(.body)
                .foregroundStyle(Color.appTextSecondary)
            Spacer()
            Text(String(format: String(localized: "common_won_format"), cost.formatted()))
                .appFont(.body)
                .foregroundStyle(Color.appTextPrimary)
        }
        .padding(.vertical, Spacing.m)
        .padding(.horizontal, Spacing.l)
        .recipeCard()
    }

    // 하단 버튼: 생성 중 · 확정 전 · 조리 완료 후에는 누를 수 없음
    @ViewBuilder
    private var bottomButton: some View {
        switch phase {
        case .generating:
            BottomActionBar(title: .recipeDetailGeneratingButton, isEnable: false, isLoading: true) {}
        case .failed:
            BottomActionBar(title: .recipeDetailComplete, isEnable: false) {}
        case .ready:
            BottomActionBar(
                title: isConfirmed || isCooked ? .recipeDetailComplete : .recipeDetailCompleteLocked,
                isEnable: isConfirmed && !isCooked,
                action: onComplete  // TODO: 조리 완료 API 나오면 연결
            )
        }
    }
}

// 레시피 상세의 흰 카드 (조리 순서 · 예상 재료비)
private extension View {
    func recipeCard() -> some View {
        self
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(RoundedRectangle(cornerRadius: Radius.large).fill(Color.appSurface))
            .overlay(RoundedRectangle(cornerRadius: Radius.large).stroke(Color.appBorder))
    }
}

#if DEBUG
    private let previewDay = PreviewMealRepository.samplePlan.days[1]  // 화: 대파가 없는 메뉴
    private let previewMenu = PreviewMealRepository.samplePlan.days[1].menus[0]
    private let previewRecipe = PreviewMealRepository.sampleRecipe(for: previewMenu)
    private let previewShortRecipe = PreviewMealRepository.sampleRecipe(for: previewMenu, shortageIds: [2])

    #Preview("확정 전") {
        RecipeDetailView(day: previewDay, menu: previewMenu, recipe: previewRecipe, badges: [.useSoon])
            .environment(Router<ThisWeekRoute>())
    }
    #Preview("확정 후 · 부족 재료") {
        RecipeDetailView(day: previewDay, menu: previewMenu, recipe: previewShortRecipe, badges: [.needMore], isConfirmed: true)
            .environment(Router<ThisWeekRoute>())
    }
    #Preview("조리 완료") {
        RecipeDetailView(day: previewDay, menu: previewMenu, recipe: previewRecipe, isConfirmed: true, isCooked: true)
            .environment(Router<ThisWeekRoute>())
    }
    #Preview("AI 생성 중") {
        RecipeDetailView(day: previewDay, menu: previewMenu, badges: [.useSoon], phase: .generating)
            .environment(Router<ThisWeekRoute>())
    }
    #Preview("생성 실패") {
        RecipeDetailView(day: previewDay, menu: previewMenu, badges: [.useSoon], phase: .failed)
            .environment(Router<ThisWeekRoute>())
    }
#endif
