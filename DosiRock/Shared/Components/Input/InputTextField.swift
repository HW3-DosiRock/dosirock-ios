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
    var showsErrorAfterBlur = false  // true면 한 번 포커스를 잃은 뒤부터 에러 표시 (입력 중 깜빡임 방지)
    var submitLabel: SubmitLabel = .done  // 키보드 Return 키 모양 (다음/완료)
    var onSubmit: () -> Void = {}  // Return을 눌렀을 때 (예: 다음 칸으로 이동)
    var focused: Binding<Bool>? = nil  // 바깥에서 포커스를 옮기고 싶을 때 연결
    var maxLength: Int? = nil  // 이 글자 수를 넘는 입력은 바로 잘라냄
    var reserveMessageSpace = false  // 문구가 없을 때도 한 줄 높이를 비워 둠

    // 스타일 (기본값 = 기존 모습)
    var labelColor: Color = .appTextSecondary
    var bgColor: Color = .appSurface
    var height: CGFloat = Size.buttonHeight
    var trailing: AnyView? = nil  // 입력 박스 오른쪽 같은 줄에 붙는 뷰 (예: 전송 버튼)

    @FocusState private var isFocused: Bool
    @State private var hasBlurred = false

    private var shownError: String? {
        showsErrorAfterBlur && !hasBlurred ? nil : errorMsg
    }

    // 상태별 테두리 색: 에러 > 포커스 > 기본
    private var borderColor: Color {
        if shownError != nil { return .appAttention }
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
            if let shownError {
                Text(shownError)
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
                .submitLabel(submitLabel)
                .onSubmit(onSubmit)

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
        .onChange(of: isFocused) { _, now in
            if !now { hasBlurred = true }
            if focused?.wrappedValue != now { focused?.wrappedValue = now }
        }
        .onChange(of: text) { _, new in
            // 모델이 아니라 뷰에서 정리해야 입력칸 표시도 같이 되돌아감
            var cleaned = inputType == .number
                ? new.filter { $0.isASCII && $0.isNumber } : new
            if let maxLength { cleaned = String(cleaned.prefix(maxLength)) }
            if cleaned != new { text = cleaned }
        }
        .onChange(of: focused?.wrappedValue) { _, want in
            if let want, want != isFocused { isFocused = want }
        }
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
