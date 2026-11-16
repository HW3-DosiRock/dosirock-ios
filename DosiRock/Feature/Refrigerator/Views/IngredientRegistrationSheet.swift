//
//  IngredientRegistrationSheet.swift
//  DosiRock
//
//  Created by Admin on 11/16/26.
//

import SwiftUI

// 재료 등록 시트 (F-03): 지금 있는 양 · 권장 사용일 · (선택) 포장 소비기한
struct IngredientRegistrationSheet: View {

    @Environment(\.dismiss) private var dismiss
    @State private var vm: IngredientRegistrationViewModel
    @State private var showsExpiryPicker = false
    var onSave: (IngredientItem) -> Void = { _ in }

    init(
        ingredient: IngredientItem,
        onSave: @escaping (IngredientItem) -> Void = { _ in }
    ) {
        _vm = State(
            initialValue: IngredientRegistrationViewModel(selectedItem: ingredient)
        )
        self.onSave = onSave
    }

    private var item: IngredientItem { vm.selectedItem }

    var body: some View {
        @Bindable var vm = vm

        VStack(spacing: 0) {
            NavigationHeader(
                title: "fridge_register_title",
                leadingTitle: "fridge_register_back",
                titleStyle: .heading,
                onLeadingTap: { dismiss() }
            )

            ScrollView {
                VStack(alignment: .leading, spacing: Spacing.xl) {
                    ingredientHeader

                    // 기본 재료(있음/없음 관리)는 수량 입력이 없음
                    if item.managementType == .quantity {
                        InputTextField(
                            label: "fridge_register_quantity_label",
                            placeHolder: "fridge_register_quantity_placeholder",
                            text: $vm.quantityText,
                            inputType: .decimal,
                            suffix: LocalizedStringKey(item.unit),
                            errorMsg: vm.quantityError,
                            labelColor: .appTextPrimary
                        )
                    }

                    recommendedSection
                    expirySection
                }
                .padding(.horizontal, Spacing.screenHorizontal)
                .padding(.vertical, Spacing.l)
            }
            .scrollDismissesKeyboard(.interactively)

            PrimaryButton(title: "common_save", isEnable: vm.canSave) {
                onSave(item)
                dismiss()
            }
            .padding(.horizontal, Spacing.screenHorizontal)
            .padding(.bottom, Spacing.l)
        }
        .background(Color.appBackground)
        .presentationDetents([.height(580), .large])
        .presentationDragIndicator(.visible)
        .presentationCornerRadius(Radius.xLarge)
        .modifier(PageSheetSizing())
        .sheet(isPresented: $showsExpiryPicker) {
            ExpiryDatePickerSheet(initial: vm.expiryDate ?? Date()) { date in
                vm.expiryDate = date
                vm.showsExpiryInput = true
            }
        }
    }

    // 재료 이미지 + 이름
    private var ingredientHeader: some View {
        HStack(spacing: Spacing.s) {
            Image(item.imageName)
                .resizable()
                .scaledToFit()
                .frame(width: 48, height: 48)
            Text(item.name)
                .appFont(.brandSubtitle)
                .foregroundStyle(Color.appTextPrimary)
        }
    }

    // 권장 사용일: < 11/14(토) · 5일 안에 >  (보관 일수가 없는 재료는 숨김)
    @ViewBuilder
    private var recommendedSection: some View {
        if let date = vm.recommendedDate, let days = vm.daysUntilRecommended {
            VStack(alignment: .leading, spacing: Spacing.s) {
                
                HStack{
                    Text("fridge_register_recommended_title")
                        .appFont(.heading)
                        .foregroundStyle(Color.appTextPrimary)
                    Image("info")
                        .renderingMode(.template)  // 색을 입힐 수 있게 템플릿으로
                        .resizable()
                        .scaledToFit()
                        .frame(width: Size.Icon.medium)
                        .foregroundStyle(Color.appTextSecondary)
                        .appToolTip(
                            String(localized: "fridge_register_recommended_tooltip")
                        )
                        .zIndex(1)
                        .accessibilityAddTraits(.isButton)  //VoiceOver(화면 읽어주기)에게 버튼 선언
                }                .zIndex(1)  // 툴팁이 아래 입력 칸에 가려지지 않게 (zIndex는 같은 부모 안의 형제끼리만 비교됨)

                HStack {
                    stepButton("chevron.left", enabled: vm.canShiftEarlier) {
                        vm.shiftRecommended(by: -1)
                    }
                    Spacer()
                    Text(
                        String(
                            format: String(localized: "fridge_register_recommended_value"),
                            date.shortKorean,
                            days
                        )
                    )
                        .appFont(.body)
                        .foregroundStyle(Color.appTextPrimary)
                    Spacer()
                    stepButton("chevron.right", enabled: true) {
                        vm.shiftRecommended(by: 1)
                    }
                }
                .padding(.horizontal, Spacing.s)
                .frame(height: Size.buttonHeight)
                .background{
                    RoundedRectangle(cornerRadius: Radius.small).fill(
                        Color.appSurface
                    )
                    RoundedRectangle(cornerRadius: Radius.small).stroke(
                        Color.appBorder
                    )
                }
                .clipShape(RoundedRectangle(cornerRadius: Radius.small))
              

                if let basis = storageBasisText {
                    Text(basis)
                        .appFont(.subbody)
                        .foregroundStyle(Color.appTextSecondary)
                }
            }
        }
    }

    // "냉장 보관 5일 기준"
    private var storageBasisText: String? {
        guard let days = item.storageDays, let method = item.storageMethod else {
            return nil
        }
        let key: String
        switch method {
        case .roomTemperature: key = "fridge_register_basis_room"
        case .refrigerated: key = "fridge_register_basis_refrigerated"
        case .frozen: key = "fridge_register_basis_frozen"
        }
        return String(format: String(localized: String.LocalizationValue(key)), days)
    }

    private func stepButton(
        _ icon: String,
        enabled: Bool,
        action: @escaping () -> Void
    ) -> some View {
        Button(action: action) {
            Image(systemName: icon)
                .foregroundStyle(enabled ? Color.appTextPrimary : Color.appDisabled)
                .frame(width: Size.minTouch, height: Size.minTouch)
        }
        .buttonStyle(.plain)
        .disabled(!enabled)
    }

    // 포장 소비기한: 추가하면 날짜 칸이 생기고(누르면 달력), "지우기"로 제거
    @ViewBuilder
    private var expirySection: some View {
        if vm.showsExpiryInput, let date = vm.expiryDate {
            VStack(alignment: .leading, spacing: Spacing.s) {
                HStack {
                    Text("fridge_register_expiry_title")
                        .appFont(.heading)
                        .foregroundStyle(Color.appTextPrimary)
                    Spacer()
                    Button { vm.toggleExpiryInput() } label: {
                        Text("fridge_register_expiry_clear")
                            .appFont(.subbody)
                            .foregroundStyle(Color.appTextSecondary)
                    }
                    .buttonStyle(.plain)
                }

                Button { showsExpiryPicker = true } label: {
                    HStack {
                        Text(date.shortKorean)
                            .appFont(.body)
                            .foregroundStyle(Color.appTextPrimary)
                        Spacer()
                        Image(systemName: "calendar")
                            .foregroundStyle(Color.appTextSecondary)
                    }
                    .padding(.horizontal, Spacing.l)
                    .frame(height: Size.buttonHeight)
                    .background(Color.appSurface)
                    .clipShape(RoundedRectangle(cornerRadius: Radius.small))
                    .overlay(
                        RoundedRectangle(cornerRadius: Radius.small)
                            .stroke(Color.appBorder, lineWidth: 1)
                    )
                }
                .buttonStyle(.plain)
            }
        } else {
            TextLinkButton(
                title: "fridge_register_expiry_add",
                icon: "plus",
                textColor: .appTextPrimary,
                textStyle: .subbody
            ) { showsExpiryPicker = true }
        }
    }
}

#if DEBUG
    #Preview("수량 재료") {
        IngredientRegistrationSheet(ingredient: IngredientItem.samples[2])
    }
    #Preview("기본 재료") {
        IngredientRegistrationSheet(ingredient: IngredientItem.samples[4])
    }
#endif
