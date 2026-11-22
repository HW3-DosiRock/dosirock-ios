//
//  MainTabView.swift
//  DosiRock
//
//  Created by Admin on 11/12/26.
//

import SwiftUI

struct MainTabView: View {

    @Environment(\.container) private var container

    @State var activeTab: Navigation = Navigation.thisweek
    // 탭을 바꿔도 이번 주 탭의 상태(메뉴 만드는 중 등)가 이어지도록 여기서 한 번만 만들어 들고 있음
    @State private var thisWeekVM: ThisWeekViewModel?

    var body: some View {

        VStack(spacing: 0) {
            Group {
                switch activeTab {
                case .thisweek:
                    if let thisWeekVM { ThisWeekView(vm: thisWeekVM) }
                case .fridge:
                    RefrigeratorView(
                        vm: RefrigeratorViewModel(
                            inventory: container.inventory,
                            ingredientRepository: container.ingredients
                        )
                    )
                case .mypage:
                    MyPageView(
                        vm: MyPageViewModel(
                            users: container.user,
                            auth: container.auth
                        )
                    )
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(Color.appBackground.ignoresSafeArea())

            BottomNavigationBar(activeTab: $activeTab)
                .background(Color.appSurface)
        }
        .onAppear {
            if thisWeekVM == nil {
                thisWeekVM = ThisWeekViewModel(
                    mealPlans: container.mealPlan,
                    inventory: container.inventory,
                    ingredients: container.ingredients
                )
            }
        }

    }
}

#Preview {
    MainTabView()
}
