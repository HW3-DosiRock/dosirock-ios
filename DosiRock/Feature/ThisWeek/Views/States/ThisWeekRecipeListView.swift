//
//  ThisWeekRecipeListView.swift
//  DosiRock
//
//  Created by Admin on 11/18/26.
//

import SwiftUI

struct ThisWeekRecipeListView: View {

    @Bindable var vm: ThisWeekViewModel
    @Environment(Router<ThisWeekRoute>.self) private var router

    var body: some View {

        VStack(spacing: 0) {

            ScrollView {

                VStack(alignment: .leading, spacing: Spacing.xl) {

                    //이번주 기간
                    Text(vm.weekRangeText)
                        .appFont(.heading)
                        .foregroundStyle(Color.appTextPrimary)

                    shortageCard
                    dayTabs
                    selectedDaySection

                }
                // 화면 폭 전체를 쓰게 해서, 툴팁처럼 내용 밖으로 그려지는 것이 잘리지 않게 함
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.bottom, Spacing.l)
            }
            .frame(
                maxWidth: .infinity,
                maxHeight: .infinity,
                alignment: .topLeading
            )

            if let message = vm.errorMessage {
                AppBanner(type: .attention, message: message)
                    .padding(.bottom, Spacing.s)
            }

            bottomButton
        }
    }

    // 확정 전: 계획 확정 / 확정 후: 선택한 날짜의 조리 완료 (이미 조리했으면 비활성화)
    @ViewBuilder
    private var bottomButton: some View {
        if !vm.isConfirmed {
            BottomActionBar(
                title: .thisweekConfirmPlan,
                isEnable: vm.regeneratingDate == nil,
                isLoading: vm.isConfirming
            ) {
                Task { await vm.confirm() }
            }
        } else if let day = vm.selectedDay {
            let cooked = vm.isCooked(day)
            BottomActionBar(
                title: cooked
                    ? .recipeDetailComplete
                    : LocalizedStringResource(
                        stringLiteral: String(
                            format: String(localized: "thisweek_cook_day_complete"),
                            day.dayText, day.weekdayText
                        )
                    ),
                isEnable: !cooked && vm.regeneratingDate == nil
            ) {
                // TODO: 조리 완료 API 나오면 연결
            }
        }
    }

    // 추가로 필요한 재료 요약 (부족 재료가 없으면 숨김)
    @ViewBuilder
    private var shortageCard: some View {
        if !vm.shortages.isEmpty {
            Button {
                router.push(.shortages)
            } label: {
                HStack(spacing: Spacing.m) {
                    AppIcon(.cart, size: Size.Icon.large)
                        .foregroundStyle(Color.appPrimary)
                        .frame(width: Size.Icon.xLarge, height: Size.Icon.xLarge)
                        .background(Circle().fill(Color.appSurfaceSubtle))
                        .accessibilityHidden(true)

                    VStack(alignment: .leading, spacing: Spacing.xs) {
                        Text(
                            String(
                                format: String(localized: "thisweek_shortage_title"),
                                vm.shortages.count
                            )
                        )
                        .appFont(.body)
                        .foregroundStyle(Color.appTextPrimary)

                        HStack(spacing: Spacing.xs) {
                            ForEach(vm.shortages.prefix(2), id: \.ingredientId) { item in
                                IngredientImage(code: item.imageName, size: Size.Icon.medium)
                                    .accessibilityHidden(true)
                            }
                            Text(vm.shortageSummary)
                                .appFont(.subbody)
                                .foregroundStyle(Color.appTextSecondary)
                        }
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)

                    AppIcon(.chevronRight)
                        .foregroundStyle(Color.appDisabled)
                }
                .thisWeekCard()
                .contentShape(Rectangle())
            }
            .buttonStyle(.plain)
        }
    }

    // 고른 요일의 도시락: 제목 · 메뉴 카드 · 밥 · 이날 다시 제안
    @ViewBuilder
    private var selectedDaySection: some View {
        if let day = vm.selectedDay {
            VStack(alignment: .leading, spacing: Spacing.m) {

                VStack(alignment: .leading, spacing: Spacing.xs) {
                    Text(String(format: String(localized: "thisweek_day_title"), day.weekdayFullText))
                        .appFont(.heading)
                        .foregroundStyle(Color.appTextPrimary)
                    Text(String(format: String(localized: "thisweek_day_subtitle"), day.totalCookMinutes))
                        .appFont(.subbody)
                        .foregroundStyle(Color.appTextSecondary)
                }

                if vm.regeneratingDate == day.date {
                    regeneratingContent(day)  // W-05: 이 요일만 AI가 다시 짜는 중
                } else {
                    dayMenus(day)
                }
            }
        }
    }

    private func dayMenus(_ day: MealPlanDay) -> some View {
        VStack(alignment: .leading, spacing: Spacing.m) {

            ForEach(Array(day.menus.enumerated()), id: \.offset) { index, menu in
                RecipeCard(
                    recipe: Recipe(
                        id: index,
                        name: menu.name,
                        cookTime: menu.cookMinutes,
                        // 카드에는 주재료 2개만 (아이콘도 최대 2개)
                        ingredients: menu.ingredients.prefix(2).map {
                            Ingredient(code: $0.imageName, name: $0.name)
                        },
                        badges: vm.badges(for: menu)
                    )
                ) {
                    router.push(.recipe(date: day.date, menuIndex: index))
                }
            }

            riceRow

            TextLinkButton(
                title: .thisweekResuggestDay,
                icon: .refresh,
                textColor: .appTextSecondary,
                isEnable: day.remainingResuggestionCount > 0 && !vm.isConfirming
            ) {
                Task { await vm.resuggestDay(day) }
            }
            .frame(maxWidth: .infinity)
        }
    }

    private func regeneratingContent(_ day: MealPlanDay) -> some View {
        VStack(spacing: Spacing.l) {
            Image(.logoStone)
                .resizable()
                .scaledToFit()
                .frame(width: 104)
                .accessibilityHidden(true)
            Text(String(format: String(localized: "thisweek_day_regenerating"), day.weekdayFullText))
                .appFont(.brandSubtitle)
                .foregroundStyle(Color.appTextPrimary)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, Spacing.xl * 2)
    }

    // 밥은 메뉴에 없지만 항상 같이 나감 (안내용 줄)
    private var riceRow: some View {
        HStack(spacing: Spacing.s) {
            AppIcon(.riceBowl)
                .foregroundStyle(Color.appTextSecondary)
            Text(.thisweekRiceIncluded)
                .appFont(.subbody)
                .foregroundStyle(Color.appTextSecondary)
            Spacer()
            Text(.thisweekRiceDefault)
                .appFont(.caption)
                .foregroundStyle(Color.appTextSecondary)
        }
        .padding(Spacing.m)
        .background(
            RoundedRectangle(cornerRadius: Radius.medium).fill(Color.appSurfaceSubtle)
        )
    }

    // 월~금 요일 선택
    private var dayTabs: some View {
        HStack(spacing: Spacing.s) {
            ForEach(vm.days, id: \.date) { day in
                DayTile(
                    dayOfWeek: day.weekdayText,
                    day: day.dayText,
                    isClicked: vm.selectedDay?.date == day.date
                ) {
                    vm.selectedDate = day.date
                }
            }
        }
    }
}

#if DEBUG
#Preview {
    let vm = ThisWeekViewModel(
        mealPlans: PreviewMealRepository(scenario: .hasPlan),
        inventory: PreviewInventoryRepository(),
                ingredients: PreviewIngredientRepository()
    )
    ThisWeekRecipeListView(vm: vm)
        .environment(Router<ThisWeekRoute>())
        .padding()
        .task { await vm.load() }  // 샘플 계획을 vm.plan에 넣음
}
#endif
