//
//  SignUpNicknameSection.swift
//  DosiRock
//
//  Created by Admin on 11/9/26.
//

import SwiftUI

struct SignUpNicknameSection: View {
    
    @Bindable var vm: SignUpViewModel
    
    var body: some View {
        VStack(alignment: .leading) {

            SectionHeader(
                title: "sign_up_nickname_section_title",
                titleStyle: .brandEmphasis
            )
            .frame(maxWidth: .infinity)

            InputTextField(
                label: "sign_up_nickname_label",
                placeHolder: "sign_up_nickname_placeholder",
                text: $vm.nickName,
                infoMsg: "sign_up_nickname_description",
                labelColor: .appTextPrimary
            )
        }
    }
}

#Preview {
    SignUpNicknameSection(vm: .init(service: MockAuthService()))
        .background(Color.appBackground)
        .padding()
}
