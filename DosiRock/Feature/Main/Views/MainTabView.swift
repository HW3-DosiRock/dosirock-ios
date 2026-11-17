//
//  MainTabView.swift
//  DosiRock
//
//  Created by Admin on 11/12/26.
//

import SwiftUI

struct MainTabView: View {

    @State var activeTab: Navigation = Navigation.thisweek

    var body: some View {

        VStack(spacing: 0) {
            Group {
                switch activeTab {
                case .thisweek: ThisWeekView()
                case .fridge: RefrigeratorView()
                case .mypage: MyPageView()
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
