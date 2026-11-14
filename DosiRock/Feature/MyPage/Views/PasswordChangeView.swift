//
//  PasswordChangeView.swift
//  DosiRock
//

import SwiftUI

struct PasswordChangeView: View {

    @Environment(Router<MyPageRoute>.self) private var router
    @State private var vm: PasswordChangeViewModel
    @State private var newFocused = false
    @State private var confirmFocused = false
    var onChanged: () -> Void = {}

    init(vm: PasswordChangeViewModel, onChanged: @escaping () -> Void = {}) {
        _vm = State(initialValue: vm)
        self.onChanged = onChanged
    }

    var body: some View {
        let f = Bindable(vm.fields)
        VStack(alignment: .leading, spacing: Spacing.l) {
            NavigationHeader(
                title: "my_password_title",
                leadingTitle: "my_profile_edit_title",
                onLeadingTap: { router.pop() }
            )

            InputTextField(
                label: "my_password_current",
                placeHolder: "my_password_current",
                text: $vm.current,
                inputType: .password,
                errorMsg: vm.currentError,
                submitLabel: .next,
                onSubmit: { newFocused = true },
                labelColor: .appTextPrimary
            )

            Button("my_password_forgot") { router.push(.findPassword) }
                .appFont(.subbody)
                .foregroundStyle(Color.appTextSecondary)
                .underline()

            InputTextField(
                label: "my_password_new",
                placeHolder: "my_password_new",
                text: f.password,
                inputType: .password,
                errorMsg: vm.newError,
                infoMsg: "my_password_new_help",
                showsErrorAfterBlur: true,
                submitLabel: .next,
                onSubmit: { confirmFocused = true },
                focused: $newFocused,
                labelColor: .appTextPrimary
            )

            InputTextField(
                label: "my_password_confirm",
                placeHolder: "my_password_confirm",
                text: f.passwordConfirm,
                inputType: .password,
                errorMsg: vm.confirmError ?? vm.errorMessage,
                showsErrorAfterBlur: true,
                onSubmit: { confirmFocused = false },
                focused: $confirmFocused,
                labelColor: .appTextPrimary
            )

            PrimaryButton(
                title: "my_password_submit",
                isEnable: vm.canSubmit,
                isLoading: vm.isSubmitting
            ) {
                Task {
                    if await vm.submit() {
                        onChanged()
                        router.pop()
                    }
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
}

#if DEBUG
    #Preview {
        PasswordChangeView(vm: PasswordChangeViewModel(users: PreviewUserRepository()))
            .environment(Router<MyPageRoute>())
    }
#endif
