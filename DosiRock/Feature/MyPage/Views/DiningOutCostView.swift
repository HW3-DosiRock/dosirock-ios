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
                title: "my_eat_out_title",
                leadingTitle: "tab_my_page",
                onLeadingTap: { router.pop() }
            )

            VStack(alignment: .leading, spacing: Spacing.s) {
                titleRow
                    .zIndex(1)  // 툴팁이 입력칸에 가려지지 않게

                InputTextField(
                    placeHolder: "my_eat_out_title",
                    text: $vm.text,
                    inputType: .number,
                    suffix: "my_eat_out_unit",
                    errorMsg: vm.error ?? vm.errorMessage,
                    maxLength: 6,
                    labelColor: .appTextPrimary
                )
            }

            PrimaryButton(
                title: "common_save",
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

            Button("my_eat_out_default") { vm.useDefault() }
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
            Text("my_eat_out_title")
                .appFont(.heading)
                .foregroundStyle(Color.appTextPrimary)

            Image("info")
                .renderingMode(.template)
                .resizable()
                .scaledToFit()
                .frame(width: Size.Icon.medium)
                .foregroundStyle(Color.appTextSecondary)
                .appToolTip(String(localized: "my_eat_out_tip"))
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
