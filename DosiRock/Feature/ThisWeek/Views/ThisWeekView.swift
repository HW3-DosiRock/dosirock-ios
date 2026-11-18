//
//  ThisWeekView.swift
//  DosiRock
//
//  Created by Admin on 11/12/26.
//

import SwiftUI

// 이번주 탭 (임시 화면)
struct ThisWeekView: View {

    @State private var vm = ThisWeekViewModel()

    var body: some View {

        VStack {
            
            header
            
            Group {
                switch vm.state {
                case .loading:
                    TabSkeletonView()
                case .emptyIngredient: ThisWeekEmptyIngredientView()
                case .emptyRecipe:
                    ThisWeekRecipeEmptyView(
                        weekRangeText: vm.weekRangeText
                    )
                case .error:
                    LoadFailedView(title: .thisweekLoadFailed) {
                        Task { await vm.load() }
                    }
                case .makingRecipe:
                    ThisWeekMakingRecipe()
                        .task { await vm.waitForRecipe() }  // 200초 지나면 이전 화면으로
                case .recipeList:
                    ThisWeekRecipeListView()
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
            actionTitle: vm.state == .recipeList ? .thisweekChangeCondition : nil,
            actionIcon: "slider.horizontal.3"
        ) {
            // TODO: 조건 변경 화면 열기
        }
    }
}

#Preview {
    ThisWeekView()
}
