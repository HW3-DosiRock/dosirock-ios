//
//  DiningOutCostView.swift
//  DosiRock
//

import SwiftUI

struct DiningOutCostView: View {

    @Environment(Router<MyPageRoute>.self) private var router
    @State private var vm: DiningOutCostViewModel
    var onSaved: (Int) -> Void = { _ in }  // 저장된 금액을 마이페이지에 알림

    init(vm: DiningOutCostViewModel, onSaved: @escaping (Int) -> Void = { _ in }) {
        _vm = State(initialValue: vm)
        self.onSaved = onSaved
    }

    var body: some View {
        VStack(alignment: .leading, spacing: Spacing.l) {
            NavigationHeader(
                title: .myEatOutTitle,
                leadingTitle: .tabMyPage,
                onLeadingTap: { router.pop() }
            )

            VStack(alignment: .leading, spacing: Spacing.s) {
                titleRow
                    .zIndex(1)  // 툴팁이 입력칸에 가려지지 않게

                InputTextField(
                    placeHolder: .myEatOutTitle,
                    text: $vm.text,
                    inputType: .number,
                    suffix: .myEatOutUnit,
                    errorMsg: vm.error ?? vm.errorMessage,
                    maxLength: 6,
                    labelColor: .appTextPrimary
                )
            }

            PrimaryButton(
                title: .commonSave,
                isEnable: vm.canSave,
                isLoading: vm.isSaving
            ) {
                Task {
                    if let cost = await vm.save() {
                        onSaved(cost)
                        router.pop()
                    }
                }
            }

            Button(.myEatOutDefault) { vm.useDefault() }
                .appFont(.body)
                .foregroundStyle(Color.appPrimary)
                .frame(maxWidth: .infinity)

            Spacer()
        }
        .padding(Spacing.screenHorizontal)
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
        .background(Color.appBackground.ignoresSafeArea())
        .navigationBarBackButtonHidden(true)
        .dismissKeyboardOnTap()
    }

    // "외식 기준 금액 ⓘ" (ⓘ를 누르면 설명이 잠깐 보임)
    private var titleRow: some View {
        HStack(spacing: Spacing.xs) {
            Text(.myEatOutTitle)
                .appFont(.heading)
                .foregroundStyle(Color.appTextPrimary)

            AppIcon(.info, decorative: false)
                .foregroundStyle(Color.appTextSecondary)
                .appToolTip(.myEatOutTip)
                .accessibilityAddTraits(.isButton)  //VoiceOver(화면 읽어주기)에게 버튼 선언
 
        }
       
    }
}

#if DEBUG
    #Preview {
        DiningOutCostView(
            vm: DiningOutCostViewModel(users: PreviewUserRepository(), cost: 12000)
        )
        .environment(Router<MyPageRoute>())
    }
#endif
