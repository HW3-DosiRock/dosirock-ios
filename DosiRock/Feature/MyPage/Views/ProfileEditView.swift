//
//  ProfileEditView.swift
//  DosiRock
//
//  Created by Admin on 11/13/26.
//

import SwiftUI

struct ProfileEditView: View {

    @Environment(Router<MyPageRoute>.self) private var router

    var body: some View {
        VStack {
            NavigationHeader(
                title: "my_profile_edit_title",
                leadingTitle: "tab_my_page",
                onLeadingTap: { router.pop() }
            )
            Spacer()
        }
        .padding(Spacing.screenHorizontal)
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
        .background(Color.appBackground.ignoresSafeArea())
        .navigationBarBackButtonHidden(true)
    }
}
#Preview {
    ProfileEditView()
        .environment(Router<MyPageRoute>())
}
