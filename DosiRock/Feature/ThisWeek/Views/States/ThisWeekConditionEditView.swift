//
//  ThisWeekConditionEditView.swift
//  DosiRock
//

import SwiftUI

// W-06 추천 조건 변경: 이미 있는 계획을 새 조건으로 다시 제안받는다
struct ThisWeekConditionEditView: View {

    @Environment(Router<ThisWeekRoute>.self) private var router
    @Bindable var vm: ThisWeekViewModel
    @State private var showsReplaceConfirm = false

    var body: some View {
        VStack(spacing: 0) {

            NavigationHeader(
                title: .thisweekChangeCondition,
                leadingTitle: .tabThisWeek,
                titleStyle: .brandSubtitle,
                onLeadingTap: { router.pop() }
            )

            ThisWeekRecipeEmptyView(vm: vm, showsWeekRange: false) {
                // D-03: 확정한 계획은 바꾸기 전에 한 번 더 묻는다
                if vm.isConfirmed {
                    showsReplaceConfirm = true
                } else {
                    resuggest()
                }
            }
        }
        .padding(Spacing.screenHorizontal)
        .background(Color.appBackground.ignoresSafeArea())
        .navigationBarBackButtonHidden(true)
        .alert(
            String(localized: "thisweek_replace_dialog_title"),
            isPresented: $showsReplaceConfirm
        ) {
            Button(String(localized: "common_cancel"), role: .cancel) {}
            Button(String(localized: "thisweek_replace_dialog_confirm"), role: .destructive) {
                resuggest()
            }
        } message: {
            Text("thisweek_replace_dialog_message")
        }
    }

    // 목록으로 돌아가면 로딩(.makingRecipe) 화면이 보이고, 실패하면 목록에 안내가 뜬다
    private func resuggest() {
        router.pop()
        Task { await vm.resuggest() }
    }
}
