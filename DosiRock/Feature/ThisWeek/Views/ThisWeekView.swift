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
    @State private var router = Router<ThisWeekRoute>()

    init(vm: ThisWeekViewModel) {
        _vm = State(initialValue: vm)
    }

    var body: some View {

        NavigationStack(path: $router.path) {
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
            }
            .padding(Spacing.screenHorizontal)
            // NavigationStack이 자기 흰 배경을 칠해서 → 여기서 직접 칠함 (마이페이지와 같음)
            .background(Color.appBackground.ignoresSafeArea())
            .navigationDestination(for: ThisWeekRoute.self) { route in
                switch route {
                case .shortages:
                    ShortageListView(shortages: vm.shortages) {
                        try await vm.registerBought(amounts: $0, bought: $1)
                    }
                case .editCondition:
                    ThisWeekConditionEditView(vm: vm)
                case .recipe(let date, let menuIndex):
                    if let day = vm.days.first(where: { $0.date == date }),
                        day.menus.indices.contains(menuIndex)
                    {
                        let menu = day.menus[menuIndex]
                        let load = vm.recipes[menu.menuId]
                        RecipeDetailView(
                            day: day,
                            menu: menu,
                            recipe: load?.detail,
                            badges: vm.badges(for: menu),
                            isConfirmed: vm.isConfirmed,
                            phase: load?.phase ?? .generating,
                            isCooked: vm.isCooked(day),
                            onRetry: { Task { await vm.loadRecipe(menuId: menu.menuId) } }
                        )
                        // 처음 열 때 서버가 레시피를 만들어 저장, 다시 열면 저장본
                        .task { await vm.loadRecipe(menuId: menu.menuId) }
                    }
                }
            }
        }
        .toast($vm.toastMessage)
        .environment(router)
        // task는 NavigationStack 바깥에 둔다 (안쪽에 두면 뒤로 돌아올 때마다 다시 실행됨)
        .task { await vm.load() }
    }

    // 탭 제목. 레시피 목록일 때만 오른쪽에 "추천 조건 변경" 버튼
    private var header: some View {
        TabMainHeader(
            title: .tabThisWeek,
            actionTitle: vm.state == .recipeList
                ? .thisweekChangeCondition : nil,
            actionIcon: .sliders
        ) {
            router.push(.editCondition)
        }
    }
}

#if DEBUG
    #Preview("계획 있음") {
        ThisWeekView(
            vm: ThisWeekViewModel(
                mealPlans: PreviewMealRepository(scenario: .hasPlan),
                inventory: PreviewInventoryRepository(),
                ingredients: PreviewIngredientRepository()
            )
        )
    }
    #Preview("추천 조건") {
        ThisWeekView(
            vm: ThisWeekViewModel(
                mealPlans: PreviewMealRepository(scenario: .noPlan),
                inventory: PreviewInventoryRepository(),
                ingredients: PreviewIngredientRepository()
            )
        )
    }
    #Preview("재료 없음") {
        ThisWeekView(
            vm: ThisWeekViewModel(
                mealPlans: PreviewMealRepository(scenario: .noInventory),
                inventory: PreviewInventoryRepository(),
                ingredients: PreviewIngredientRepository()
            )
        )
    }
    #Preview("불러오기 실패") {
        ThisWeekView(
            vm: ThisWeekViewModel(
                mealPlans: PreviewMealRepository(scenario: .failure),
                inventory: PreviewInventoryRepository(),
                ingredients: PreviewIngredientRepository()
            )
        )
    }
#endif
