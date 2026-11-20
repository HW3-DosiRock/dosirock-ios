//
//  ThisWeekView.swift
//  DosiRock
//
//  Created by Admin on 11/12/26.
//

import SwiftUI

// 이번주 탭 (임시 화면)
struct ThisWeekView: View {

    @State private var vm: ThisWeekViewModel

    init(vm: ThisWeekViewModel) {
        _vm = State(initialValue: vm)
    }

    var body: some View {

        VStack {

            header

            Group {
                switch vm.state {
                case .loading:
                    TabSkeletonView()
                case .emptyIngredient: ThisWeekEmptyIngredientView()
                case .emptyRecipe:
                    ThisWeekRecipeEmptyView(vm: vm)
                case .error:
                    LoadFailedView(title: .thisweekLoadFailed) {
                        Task { await vm.load() }
                    }
                case .makingRecipe:
                    ThisWeekMakingRecipe()
                case .recipeList:
                    ThisWeekRecipeListView(vm : vm)
                }
            }
            .task { await vm.load() }
        }
        .padding(Spacing.screenHorizontal)
        .background(Color.appBackground)
    }

    // 탭 제목. 레시피 목록일 때만 오른쪽에 "추천 조건 변경" 버튼
    private var header: some View {
        TabMainHeader(
            title: .tabThisWeek,
            actionTitle: vm.state == .recipeList
                ? .thisweekChangeCondition : nil,
            actionIcon: .sliders
        ) {
            // TODO: 조건 변경 화면 열기
        }
    }
}

#if DEBUG
    #Preview("계획 있음") {
        ThisWeekView(
            vm: ThisWeekViewModel(
                mealPlans: PreviewMealRepository(scenario: .hasPlan),
                inventory: PreviewInventoryRepository()
            )
        )
    }
    #Preview("추천 조건") {
        ThisWeekView(
            vm: ThisWeekViewModel(
                mealPlans: PreviewMealRepository(scenario: .noPlan),
                inventory: PreviewInventoryRepository()
            )
        )
    }
    #Preview("재료 없음") {
        ThisWeekView(
            vm: ThisWeekViewModel(
                mealPlans: PreviewMealRepository(scenario: .noInventory),
                inventory: PreviewInventoryRepository()
            )
        )
    }
    #Preview("불러오기 실패") {
        ThisWeekView(
            vm: ThisWeekViewModel(
                mealPlans: PreviewMealRepository(scenario: .failure),
                inventory: PreviewInventoryRepository()
            )
        )
    }
#endif
