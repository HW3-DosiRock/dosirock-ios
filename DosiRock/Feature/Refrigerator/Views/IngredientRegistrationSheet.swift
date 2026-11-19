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
    @State private var isSaving = false
    @State private var errorMessage: String?  // 저장·삭제 실패 안내
    @State private var showsDeleteDialog = false
    @State private var sheetHeight: CGFloat = 400  // 시트 초기 높이
    @State private var contentHeight: CGFloat = 0  // ScrollView 안쪽 내용 높이

    let refrigerVm: RefrigeratorViewModel  // 저장하면 냉장고에 등록하고 체크 표시·배너까지 갱신

    init(
        ingredient: IngredientItem,
        refrigerVm: RefrigeratorViewModel,
        previousQuantity: Double? = nil,
        previousExpirationDate: Date? = nil,
        isExisting: Bool? = nil
    ) {
        _vm = State(
            initialValue: IngredientRegistrationViewModel(
                selectedItem: ingredient,
                previousQuantity: previousQuantity,
                previousExpirationDate: previousExpirationDate,
                isExisting: isExisting
            )
        )
        self.refrigerVm = refrigerVm
    }

    private var item: IngredientItem { vm.selectedItem }

    var body: some View {
        @Bindable var vm = vm

        VStack(spacing: 0) {
            NavigationHeader(
                title: refrigerVm.isRegistered(item)
                    ? .fridgeRegisterTitle2 : .fridgeRegisterTitle,
                leadingTitle: .fridgeRegisterBack,
                titleStyle: .heading,
                onLeadingTap: { dismiss() }
            )

            ScrollView {
                VStack(alignment: .leading, spacing: Spacing.xl) {
                    ingredientHeader

                    // 기본 재료(있음/없음 관리)는 수량 입력이 없음
                    if item.managementType == .quantity {
                        InputTextField(
                            label: .fridgeRegisterQuantityLabel,
                            placeHolder: .fridgeRegisterQuantityPlaceholder,
                            text: $vm.quantityText,
                            inputType: .decimal,
                            suffix: LocalizedStringResource(
                                stringLiteral: item.unit
                            ),
                            errorMsg: vm.quantityError,
                            labelColor: .appTextPrimary
                        )
                    }

                    // 이미 있는 재료를 다시 등록할 때: "지금 4개 → 14개 변경"
                    if let summary = vm.changeSummary {
                        AppBanner(
                            type: .success,
                            message: summary,
                            showIcon: false
                        )
                    }

                    // 기본 재료는 소비기한이 없음
                    if item.managementType == .quantity {
                        expirySection
                    }
                }
                .padding(.horizontal, Spacing.screenHorizontal)
                .padding(.vertical, Spacing.l)
                // ScrollView가 아니라 내용의 본래 높이를 잼 (padding 뒤에서)
                .onGeometryChange(for: CGFloat.self) {
                    $0.size.height
                } action: {
                    contentHeight = $0
                }
            }
            // 내용만큼만 커지게 (처음 측정 전에는 제한 없음). 넘치면 스크롤
            .frame(maxHeight: contentHeight > 0 ? contentHeight : nil)
            .scrollDismissesKeyboard(.interactively)

            VStack(spacing: Spacing.s) {
                if let errorMessage {
                    AppBanner(type: .attention, message: errorMessage)
                }
                PrimaryButton(
                    title: vm.isDeletingByZero
                        ? .fridgeRegisterDelete : .commonSave,
                    isEnable: vm.canSave,
                    isLoading: isSaving
                ) { save() }

                // 이미 냉장고에 있는 재료만
                if vm.isExisting {
                    TextLinkButton(
                        title: .fridgeRegisterDelete,
                        textColor: .appAttention,
                        textStyle: .heading,
                        isEnable: !isSaving
                    ) { showsDeleteDialog = true }
                }
            }
            .padding(.horizontal, Spacing.screenHorizontal)
            .padding(.bottom, Spacing.l)
        }
        // 1) 내용 자체의 높이를 잼 (하단 안전 영역 포함). 아래 frame보다 먼저 와야 내용 높이가 나옴
        .onGeometryChange(for: CGFloat.self) {
            $0.size.height + $0.safeAreaInsets.bottom
        } action: {
            sheetHeight = $0
        }
        // 2) iPad처럼 시트가 크게 뜨면 내용은 위쪽에 붙이고, 배경색은 시트 전체에 칠함
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
        .background(Color.appBackground)
        .presentationDragIndicator(.visible)
        .presentationCornerRadius(Radius.xLarge)
        .modifier(PageSheetSizing())
        .presentationDetents([.height(sheetHeight)])
        .appDialog(
            isPresented: $showsDeleteDialog,
            title: .fridgeDeleteDialogTitle,
            message: .fridgeDeleteDialogMessage,
            cancelTitle: .commonCancel,
            confirmTitle: .fridgeDeleteDialogConfirm,
            onConfirm: { delete() }
        )
        .sheet(isPresented: $showsExpiryPicker) {
            ExpiryDatePickerSheet(initial: vm.expirationDate ?? Date()) {
                date in
                vm.expirationDate = date
            }
        }
    }

    // 저장: 성공하면 시트를 닫고, 실패하면 입력값은 그대로 두고 안내 배너를 보여 줌
    private func save() {

        if vm.isDeletingByZero {  //0이면 저장 x , 삭제 o
            showsDeleteDialog = true
            return
        }

        isSaving = true
        errorMessage = nil
        Task {
            do {
                try await refrigerVm.register(
                    item,
                    quantity: vm.quantity,
                    recommendedDate: vm.expirationDate
                )
                dismiss()
            } catch {
                errorMessage = String(localized: .commonSaveFailed)
            }
            isSaving = false
        }
    }

    // 삭제: 성공하면 시트를 닫고, 실패하면 안내 배너
    private func delete() {
        isSaving = true
        errorMessage = nil
        Task {
            do {
                try await refrigerVm.remove(item)
                dismiss()
            } catch {
                errorMessage = String(
                    localized: .fridgeRegisterDeleteFailed
                )
            }
            isSaving = false
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

    // 소비기한: 제목(+툴팁) · 날짜 칸(누르면 달력) · "냉장 보관 5일 권장"
    private var expirySection: some View {
        VStack(alignment: .leading, spacing: Spacing.s) {

            HStack {
                Text(.fridgeRegisterExpiryTitle)
                    .appFont(.heading)
                    .foregroundStyle(Color.appTextPrimary)
                Image("info")
                    .renderingMode(.template)  // 색을 입힐 수 있게 템플릿으로
                    .resizable()
                    .scaledToFit()
                    .frame(width: Size.Icon.medium)
                    .foregroundStyle(Color.appTextSecondary)
                    .appToolTip(.fridgeRegisterRecommendedTooltip)
                    .zIndex(1)
                    .accessibilityAddTraits(.isButton)  //VoiceOver(화면 읽어주기)에게 버튼 선언
            }.zIndex(1)  // 툴팁이 아래 날짜 칸에 가려지지 않게 (zIndex는 같은 부모 안의 형제끼리만 비교됨)

            Button {
                showsExpiryPicker = true
            } label: {
                HStack {
                    Text(vm.expirationDate?.longKorean ?? "")
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

            if let basis = storageBasisText {
                Text(basis)
                    .appFont(.subbody)
                    .foregroundStyle(Color.appTextSecondary)
            }
        }
    }

    // "냉장 보관 5일 권장"
    private var storageBasisText: String? {
        guard let days = item.storageDays, let method = item.storageMethod
        else {
            return nil
        }
        let key: String
        switch method {
        case .roomTemperature: key = "fridge_register_basis_room"
        case .refrigerated: key = "fridge_register_basis_refrigerated"
        case .frozen: key = "fridge_register_basis_frozen"
        }
        return String(
            format: String(localized: String.LocalizationValue(key)),
            days
        )
    }
}

#if DEBUG
    #Preview("수량 재료") {
        IngredientRegistrationSheet(
            ingredient: IngredientItem.samples[2],
            refrigerVm: RefrigeratorViewModel(
                inventory: PreviewInventoryRepository(),
                ingredientRepository: PreviewIngredientRepository()
            )
        )
    }
    #Preview("이미 있는 재료") {
        IngredientRegistrationSheet(
            ingredient: IngredientItem.samples[2],
            refrigerVm: RefrigeratorViewModel(
                inventory: PreviewInventoryRepository(),
                ingredientRepository: PreviewIngredientRepository()
            ),
            previousQuantity: 4
        )
    }
    #Preview("기본 재료") {
        IngredientRegistrationSheet(
            ingredient: IngredientItem.samples[4],
            refrigerVm: RefrigeratorViewModel(
                inventory: PreviewInventoryRepository(),
                ingredientRepository: PreviewIngredientRepository()
            )
        )
    }
    #Preview("저장 실패") {
        IngredientRegistrationSheet(
            ingredient: IngredientItem.samples[2],
            refrigerVm: RefrigeratorViewModel(
                inventory: PreviewInventoryRepository(scenario: .failure),
                ingredientRepository: PreviewIngredientRepository()
            )
        )
    }
#endif
