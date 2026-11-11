//
//  InputTextField.swift
//  DosiRock
//
//  Created by Admin on 11/3/26.
//

import SwiftUI

struct InputTextField: View {

    var label: LocalizedStringKey? = nil
    let placeHolder: LocalizedStringKey
    @Binding var text: String
    var inputType: InputType = .text
    var suffix: LocalizedStringKey? = nil  // ← 추가: "원", "개", "g" 등 단위
    var errorMsg: String? = nil
    var infoMsg: LocalizedStringKey? = nil
    var reserveMessageSpace = false  // 문구가 없을 때도 한 줄 높이를 비워 둠

    // 스타일 (기본값 = 기존 모습)
    var labelColor: Color = .appTextSecondary
    var bgColor: Color = .appSurface
    var height: CGFloat = Size.buttonHeight
    var trailing: AnyView? = nil  // 입력 박스 오른쪽 같은 줄에 붙는 뷰 (예: 전송 버튼)

    @FocusState private var isFocused: Bool

    // 상태별 테두리 색: 에러 > 포커스 > 기본
    private var borderColor: Color {
        if errorMsg != nil { return .appAttention }
        if isFocused { return .appTextSecondary }
        return .appBorder
    }

    var body: some View {

        VStack(alignment: .leading, spacing: Spacing.s) {

            //라벨
            if let label {
                Text(label)
                    .appFont(.heading)
                    .foregroundStyle(labelColor)
            }
            //입력
            HStack(spacing: Spacing.s) {
                fieldBox
                if let trailing { trailing }
            }

            // 아래 문구: 에러가 있으면 에러, 없으면 안내
            if let errorMsg {
                Text(errorMsg)
                    .appFont(.subbody)
                    .foregroundStyle(Color.appAttention)
            } else if let infoMsg {
                Text(infoMsg)
                    .appFont(.subbody)
                    .foregroundStyle(Color.appTextSecondary)
            } else if reserveMessageSpace {
                Text(" ").appFont(.subbody)
            }

        }
    }
    // 입력 박스 (입력창 + 단위)
    private var fieldBox: some View {
        HStack(spacing: Spacing.s) {
            inputField
                .appFont(.body)
                .foregroundStyle(Color.appTextPrimary)
                .keyboardType(inputType.keyboardType)
                .textInputAutocapitalization(.never)
                .autocorrectionDisabled()

            if let suffix {
                Text(suffix)
                    .appFont(.body)
                    .foregroundStyle(Color.appTextSecondary)
            }
        }
        .padding(.horizontal, Spacing.l)
        .frame(height: height)
        .background(bgColor)
        .clipShape(RoundedRectangle(cornerRadius: Radius.small))
        .overlay(
            RoundedRectangle(cornerRadius: Radius.small)
                .stroke(borderColor, lineWidth: isFocused ? 1.5 : 1)
        )
        .contentShape(Rectangle())
        .onTapGesture { isFocused = true }
        .animation(.easeOut(duration: 0.15), value: isFocused)
    }

    @ViewBuilder
    private var inputField: some View {
        if inputType.isSecure {
            SecureField(placeHolder, text: $text)
                .focused($isFocused)
        } else {
            TextField(placeHolder, text: $text)
                .focused($isFocused)
        }
    }
}

#Preview {
    @Previewable @State var email = ""
    @Previewable @State var price = "500"

    VStack(spacing: Spacing.xl) {
        // 시안 1: 기본
        InputTextField(
            placeHolder: "example@email.com",
            text: $email,
            inputType: .email
        )

        // 시안 2: 단위 + 에러
        InputTextField(
            placeHolder: "금액",
            text: $price,
            inputType: .number,
            suffix: "원",
            errorMsg: "1,000원 이상 입력해주세요"
        )

        // 라벨 있는 버전
        InputTextField(
            label: "이메일",
            placeHolder: "이메일을 입력해주세요",
            text: $email,
            inputType: .email,
            infoMsg: "로그인에 사용돼요"
        )
    }
    .padding(Spacing.screenHorizontal)
    .background(Color.appBackground)
}
