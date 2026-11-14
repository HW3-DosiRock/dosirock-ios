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
            
            SectionHeader(title: "tab_this_week" , titleStyle: .brandTitle)
            
            Group {
                switch vm.state {
                case .loading:
                    Text("로딩 화면")  //TODO
                case .emptyIngredient: ThisWeekEmptyIngredientView()
                case .emptyRecipe:
                    ThisWeekRecipeEmptyView(
                        weekRangeText: vm.weekRangeText
                    )
                case .error:
                    Text("에러 화면")  // TODO
                case .makingRecipe:
                    Text("레시피 만드는 중")  // TODO
                case .recipeList:
                    Text("레시피 목록")  // TODO
                }
            }
            .task { await vm.load() }
        }
        .padding(Spacing.screenHorizontal)
        .background(Color.appBackground)
    }
}

#Preview {
    ThisWeekView()
}
