//
//  CookCompleteSheet.swift
//  DosiRock
//

import SwiftUI

// W-04 조리 완료: 그날 쓰는 재료를 확인하고 냉장고에 반영하며 완료한다
struct CookCompleteSheet: View {

    @Environment(\.dismiss) private var dismiss

    let loadUsage: () async -> [CookUsage]
    // 성공하면 시트를 닫고, 실패하면 시트에 안내
    let onComplete: (_ usage: [CookUsage]) async throws -> Void

    @State private var usage: [CookUsage]?  // nil이면 불러오는 중
    @State private var isSaving = false
    @State private var errorMessage: String?
    @State private var sheetHeight: CGFloat = 480
    @State private var contentHeight: CGFloat = 0

    var body: some View {
        VStack(spacing: Spacing.l) {
            NavigationHeader(
                title: .recipeDetailComplete,
                leadingTitle: .commonClose,
                showsBackIcon: false,
                titleStyle: .heading,
                onLeadingTap: { dismiss() }
            )

            Text(.thisweekCookUsedTitle)
                .appFont(.brandSubtitle)
                .foregroundStyle(Color.appTextPrimary)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.horizontal, Spacing.screenHorizontal)

            ScrollView {
                if let usage {
                    GroupedListCard(items: usage) { item in
                        HStack(spacing: Spacing.m) {
                            IngredientImage(code: item.imageName, size: Size.Icon.large)
                                .accessibilityHidden(true)
                            Text(item.name)
                                .appFont(.body)
                                .foregroundStyle(Color.appTextPrimary)
                            Spacer()
                            Text(item.amountText)
                                .appFont(.body)
                                .foregroundStyle(Color.appTextPrimary)
                        }
                    }
                    .padding(.horizontal, Spacing.screenHorizontal)
                    .onGeometryChange(for: CGFloat.self) {
                        $0.size.height
                    } action: {
                        contentHeight = $0
                    }
                } else {
                    LoadingSpinner()
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, Spacing.xl)
                }
            }
            .frame(maxHeight: contentHeight > 0 ? contentHeight : nil)

            VStack(alignment: .leading, spacing: Spacing.s) {
                if let errorMessage {
                    AppBanner(type: .attention, message: errorMessage)
                }
                PrimaryButton(
                    title: .thisweekCookApplyStock,
                    isEnable: usage != nil,
                    isLoading: isSaving
                ) { complete() }
            }
            .padding(.horizontal, Spacing.screenHorizontal)
            .padding(.bottom, Spacing.l)
        }
        .onGeometryChange(for: CGFloat.self) {
            $0.size.height + Self.windowBottomInset
        } action: {
            sheetHeight = $0
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
        .background(Color.appBackground)
        .presentationDragIndicator(.visible)
        .presentationCornerRadius(Radius.xLarge)
        .modifier(PageSheetSizing())
        .presentationDetents([.height(sheetHeight)])
        .interactiveDismissDisabled(isSaving)  // 저장 중에는 끌어서 닫지 못하게
        .task { usage = await loadUsage() }
    }

    // 홈 인디케이터 영역 높이
    private static var windowBottomInset: CGFloat {
        (UIApplication.shared.connectedScenes.first as? UIWindowScene)?
            .keyWindow?.safeAreaInsets.bottom ?? 0
    }

    private func complete() {
        guard let usage else { return }
        isSaving = true
        errorMessage = nil
        Task {
            do {
                try await onComplete(usage)
                dismiss()
            } catch {
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
                CookCompleteSheet(
                    loadUsage: {
                        [
                            CookUsage(id: 35, name: "닭고기", amount: 150, unit: "g"),
                            CookUsage(id: 1, name: "양파", amount: 50, unit: "g"),
                            CookUsage(id: 39, name: "달걀", amount: 3, unit: "개"),
                        ]
                    },
                    onComplete: { _ in }
                )
            }
    }
#endif
