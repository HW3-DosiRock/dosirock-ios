//
//  BoughtListSheet.swift
//  DosiRock
//
//  Created by Admin on 11/20/26.
//

import SwiftUI

// 구매한 재료 등록 시트: 부족 재료마다 산 양을 입력 (기본 재료는 "샀어요"로 체크)
struct BoughtListSheet: View {

    @Environment(\.dismiss) private var dismiss

    let shortages: [Shortage]
    // 입력한 산 양(재료 ID → 양), "샀어요"로 체크한 기본 재료 ID. 성공하면 시트를 닫고, 실패하면 시트에 안내
    var onSave: (_ amounts: [Int: Double], _ bought: Set<Int>) async throws -> Void = { _, _ in }

    @State private var amountTexts: [Int: String] = [:]  // 재료 ID → 입력 글자
    @State private var bought: Set<Int> = []
    @State private var showsEmptyError = false
    @State private var isSaving = false
    @State private var errorMessage: String?  // 저장 실패 안내
    @State private var sheetHeight: CGFloat = 560  // 시트 높이 (내용 높이를 재서 갱신)
    @State private var contentHeight: CGFloat = 0  // 목록 본래 높이 (넘치면 스크롤)

    var body: some View {
        VStack(spacing: Spacing.l) {
            NavigationHeader(
                title: .thisweekShortageRegister,
                leadingTitle: .commonClose,
                showsBackIcon: false,
                titleStyle: .heading,
                onLeadingTap: { dismiss() }
            )

            ScrollView {
                GroupedListCard(items: shortages) { item in
                    row(item)
                }
                .padding(.horizontal, Spacing.screenHorizontal)
                .onGeometryChange(for: CGFloat.self) {
                    $0.size.height
                } action: {
                    contentHeight = $0
                }
            }
            // 재료가 적으면 내용만큼, 많으면 화면 안에서 스크롤
            .frame(maxHeight: contentHeight > 0 ? contentHeight : nil)
            .scrollDismissesKeyboard(.interactively)

            VStack(alignment: .leading, spacing: Spacing.s) {
                if showsEmptyError {
                    Text(.thisweekShortageRegisterEmpty)
                        .appFont(.subbody)
                        .foregroundStyle(Color.appAttention)
                }
                if let errorMessage {
                    AppBanner(type: .attention, message: errorMessage)
                }
                PrimaryButton(title: .commonSave, isLoading: isSaving) { save() }
            }
            .padding(.horizontal, Spacing.screenHorizontal)
            .padding(.bottom, Spacing.l)
        }
        // 1) 내용 자체의 높이를 잼 (ExpiryDatePickerSheet와 같은 방식). 아래 frame보다 먼저 와야 내용 높이가 나옴
        // 하단 여백은 창(window) 값을 씀: 이 시트는 입력칸이 있어서, 시트의 safeAreaInsets를 쓰면
        // 키보드 높이가 섞여 시트가 커질수록 값도 커짐 → 높이 계산이 끝없이 반복되며 앱이 멈춤 (재료 등록 시트와 같은 이유)
        .onGeometryChange(for: CGFloat.self) {
            $0.size.height + Self.windowBottomInset
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
        .interactiveDismissDisabled(isSaving)  // 저장 중에는 끌어서 닫지 못하게
        .onChange(of: amountTexts) { showsEmptyError = false }
        .onChange(of: bought) { showsEmptyError = false }
    }

    // 홈 인디케이터 영역 높이 (키보드와 무관)
    private static var windowBottomInset: CGFloat {
        (UIApplication.shared.connectedScenes.first as? UIWindowScene)?
            .keyWindow?.safeAreaInsets.bottom ?? 0
    }

    // 재료 한 줄: 아이콘 · 이름 · "부족 220g" · 산 양 입력 (기본 재료는 "샀어요")
    private func row(_ item: Shortage) -> some View {
        HStack(spacing: Spacing.m) {
            IngredientImage(code: item.imageName, size: Size.Icon.large)
                .accessibilityHidden(true)

            VStack(alignment: .leading, spacing: Spacing.xs) {
                Text(item.name)
                    .appFont(.body)
                    .foregroundStyle(Color.appTextPrimary)
                if !item.isPresence {
                    Text(
                        String(
                            format: String(localized: "thisweek_shortage_register_lack"),
                            item.amountText
                        )
                    )
                    .appFont(.caption)
                    .foregroundStyle(Color.appTextSecondary)
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)

            if item.isPresence {
                boughtToggle(item)
            } else {
                InputTextField(
                    placeHolder: .thisweekShortageRegisterPlaceholder,
                    text: amountBinding(item),
                    inputType: .decimal,
                    suffix: LocalizedStringResource(stringLiteral: item.unit),
                    height: Size.minTouch
                )
                .frame(width: 120)
            }
        }
    }

    // 기본 재료(깨 등): 양 대신 "샀어요" 체크
    private func boughtToggle(_ item: Shortage) -> some View {
        let isOn = bought.contains(item.ingredientId)
        return Button {
            if isOn {
                bought.remove(item.ingredientId)
            } else {
                bought.insert(item.ingredientId)
            }
        } label: {
            HStack(spacing: Spacing.xs) {
                AppIcon(.check, size: Size.Icon.small)
                Text(.thisweekShortageRegisterBought)
                    .appFont(.subbody)
            }
            .foregroundStyle(isOn ? Color.appSurface : Color.appTextPrimary)
            .padding(.horizontal, Spacing.l)
            .frame(minHeight: Size.minTouch)
            .background(Capsule().fill(isOn ? Color.appPrimary : Color.appSurface))
            .overlay(Capsule().stroke(isOn ? Color.appPrimary : Color.appBorder))
            .contentShape(Capsule())
        }
        .buttonStyle(.plain)
        .accessibilityAddTraits(isOn ? .isSelected : [])
    }

    private func amountBinding(_ item: Shortage) -> Binding<String> {
        Binding(
            get: { amountTexts[item.ingredientId] ?? "" },
            set: { amountTexts[item.ingredientId] = $0 }
        )
    }

    // 산 양이 하나도 없으면 안내만, 있으면 서버에 저장 → 성공하면 닫기
    private func save() {
        let amounts = amountTexts.compactMapValues { text -> Double? in
            guard let value = Double(text), value > 0 else { return nil }
            return value
        }
        guard !amounts.isEmpty || !bought.isEmpty else {
            showsEmptyError = true
            return
        }
        isSaving = true
        errorMessage = nil
        Task {
            do {
                try await onSave(amounts, bought)
                dismiss()
            } catch {
                // 입력한 값은 그대로 두고 이유만 안내
                errorMessage = (error as? LocalizedError)?.errorDescription
                    ?? String(localized: .commonSaveFailed)
            }
            isSaving = false
        }
    }
}

#if DEBUG
    #Preview {
        Color.appBackground
            .sheet(isPresented: .constant(true)) {
                BoughtListSheet(
                    shortages: PreviewMealRepository.sampleShortages + [
                        Shortage(ingredientId: 35, name: "닭고기", amount: 220, unit: "g", managementType: .quantity, menuNames: ["닭고기 간장조림"], priceInfo: nil, purchaseUrl: nil),
                        Shortage(ingredientId: 4, name: "애호박", amount: 0.5, unit: "개", managementType: .quantity, menuNames: [], priceInfo: nil, purchaseUrl: nil),
                        Shortage(ingredientId: 70, name: "깨", amount: 5, unit: "g", managementType: .presence, menuNames: [], priceInfo: nil, purchaseUrl: nil),
                    ]
                )
            }
    }
#endif
