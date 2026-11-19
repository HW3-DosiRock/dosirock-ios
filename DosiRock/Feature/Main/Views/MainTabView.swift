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

    var body: some View {

        VStack(spacing: 0) {
            Group {
                switch activeTab {
                case .thisweek:
                    ThisWeekView(
                        vm: ThisWeekViewModel(
                            mealPlans: container.mealPlan,
                            inventory: container.inventory
                        )
                    )
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

    }
}

#Preview {
    MainTabView()
}
