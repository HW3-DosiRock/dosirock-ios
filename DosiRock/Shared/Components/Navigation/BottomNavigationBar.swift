//
//  BottomNavigation.swift
//  DosiRock
//
//  Created by Admin on 11/6/26.
//

import SwiftUI

struct BottomNavigationBar: View {
    
    @Binding var activeTab: Navigation  // 선택 상태는 부모가 관리

    var body: some View {

        HStack {
            ForEach(Navigation.allCases, id: \.self) { item in
                NavigationItem(navItem: item, isActive: activeTab == item) {
                    activeTab = item
                }
            }
        }
    }
}

#Preview {
    @Previewable @State var tab = Navigation.thisweek
    BottomNavigationBar(activeTab: $tab)
}
