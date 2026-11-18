//
//  ProfileEditView.swift
//  DosiRock
//
//  Created by Admin on 11/13/26.
//

import SwiftUI

struct ProfileEditView: View {

    @Environment(Router<MyPageRoute>.self) private var router
    @State private var vm: ProfileEditViewModel
    var onSaved: (String) -> Void = { _ in }  // 새 닉네임을 마이페이지에 알림

    init(vm: ProfileEditViewModel, onSaved: @escaping (String) -> Void = { _ in }) {
        _vm = State(initialValue: vm)
        self.onSaved = onSaved
    }

    var body: some View {
        VStack(alignment: .leading, spacing: Spacing.l) {
            NavigationHeader(
                title: "my_profile_edit_title",
                leadingTitle: "tab_my_page",
                onLeadingTap: { router.pop() }
            )

            // 이메일은 바꿀 수 없음
            InputTextField(
                label: "my_profile_email",
                placeHolder: "",
                text: .constant(vm.email),
                inputType: .email,
                labelColor: .appTextPrimary,
                bgColor: Color.appBorder.opacity(0.5)
            )
            .disabled(true)

            InputTextField(
                label: "my_profile_nickname",
                placeHolder: "sign_up_nickname_placeholder",
                text: $vm.nickname,
                errorMsg: vm.error ?? vm.errorMessage,
                infoMsg: "my_profile_nickname_help",
                showsErrorAfterBlur: true,
                labelColor: .appTextPrimary
            )

            PrimaryButton(
                title: "common_save",
                isEnable: vm.canSave,
                isLoading: vm.isSaving
            ) {
                Task {
                    if let name = await vm.save() {
                        onSaved(name)
                        router.pop()
                    }
                }
            }

            VStack(alignment: .leading, spacing: Spacing.m) {
                SectionHeader(title: "my_profile_account")
                GroupedListCard(items: [Account(id: "password")]) { _ in
                    Button { router.push(.passwordChange) } label: {
                        HStack {
                            Text("my_profile_password_reset")
                                .appFont(.body)
                                .foregroundStyle(Color.appTextPrimary)
                            Spacer()
                            Image("chevron-right")
                                .renderingMode(.template)
                                .resizable()
                                .scaledToFit()
                                .frame(width: Size.Icon.medium, height: Size.Icon.medium)
                                .foregroundStyle(Color.appDisabled)
                                .accessibilityHidden(true)
                        }
                        .contentShape(Rectangle())
                    }
                    .buttonStyle(.plain)
                }
            }

            Spacer()
        }
        .padding(Spacing.screenHorizontal)
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
        .background(Color.appBackground.ignoresSafeArea())
        .navigationBarBackButtonHidden(true)
        .dismissKeyboardOnTap()
    }

    private struct Account: Identifiable { let id: String }
}

#if DEBUG
    #Preview {
        ProfileEditView(
            vm: ProfileEditViewModel(
                users: PreviewUserRepository(),
                profile: UserProfile(
                    email: "dosirak@example.com",
                    nickname: "배고픈돌멩",
                    diningOutCost: 12000
                )
            )
        )
        .environment(Router<MyPageRoute>())
    }
#endif
