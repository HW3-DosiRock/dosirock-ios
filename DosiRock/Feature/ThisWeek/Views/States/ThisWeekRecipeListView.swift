//
//  ThisWeekRecipeListView.swift
//  DosiRock
//
//  Created by Admin on 11/18/26.
//

import SwiftUI

struct ThisWeekRecipeListView: View {

    @Bindable var vm: ThisWeekViewModel

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

            //이번 주 계획 확정
            BottomActionBar(title: .thisweekConfirmPlan) {
                // TODO: 계획 확정 (20번 API 전환 후)
            }
        }
    }

    // 추가로 필요한 재료 요약 (부족 재료가 없으면 숨김)
    @ViewBuilder
    private var shortageCard: some View {
        if !vm.shortages.isEmpty {
            Button {
                // TODO: 부족 재료 전체 목록 (시안 확인 후)
            } label: {
                HStack(spacing: Spacing.m) {
                    Image("cart")
                        .renderingMode(.template)
                        .resizable()
                        .scaledToFit()
                        .frame(width: Size.Icon.large, height: Size.Icon.large)
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

                    Image("chevron-right")
                        .renderingMode(.template)
                        .resizable()
                        .scaledToFit()
                        .frame(width: Size.Icon.medium, height: Size.Icon.medium)
                        .foregroundStyle(Color.appDisabled)
                        .accessibilityHidden(true)
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
                        // TODO: 메뉴 상세 (시안 확인 후)
                    }
                }

                riceRow

                TextLinkButton(
                    title: .thisweekResuggestDay,
                    icon: "arrow.clockwise",
                    textColor: .appTextSecondary
                ) {
                    // TODO: 이날 메뉴 다시 제안 (21번 API)
                }
                .frame(maxWidth: .infinity)
            }
        }
    }

    // 밥은 메뉴에 없지만 항상 같이 나감 (안내용 줄)
    private var riceRow: some View {
        HStack(spacing: Spacing.s) {
            Image("rice-bowl")
                .renderingMode(.template)
                .resizable()
                .scaledToFit()
                .frame(width: Size.Icon.medium, height: Size.Icon.medium)
                .foregroundStyle(Color.appTextSecondary)
                .accessibilityHidden(true)
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

#Preview {
    let vm = ThisWeekViewModel(
        mealPlans: PreviewMealRepository(scenario: .hasPlan),
        inventory: PreviewInventoryRepository()
    )
    ThisWeekRecipeListView(vm: vm)
        .padding()
        .task { await vm.load() }  // 샘플 계획을 vm.plan에 넣음
}
