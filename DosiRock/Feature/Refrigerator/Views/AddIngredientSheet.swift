//
//  AddIngredientSheet.swift
//  DosiRock
//
//  Created by Seungyeon Jeon on 11/15/26.
//

import SwiftUI

struct AddIngredientSheet: View {

    @Environment(\.dismiss) private var dismiss
    @State private var vm = IngredientPickerViewModel()
    @State private var selectedItem: IngredientItem?  // 눌린 재료 (두 번째 시트용)
    private let columns = Array(
        repeating: GridItem(.flexible(), spacing: Spacing.s),
        count: 4
    )

    var body: some View {

        VStack(spacing: 0) {
            NavigationHeader(
                title: "재료 선택",
                leadingTitle: "닫기",
                showsBackIcon: false,
                titleStyle: .heading,
                onLeadingTap: { dismiss() }
            )

            searchField
                .padding(.horizontal, Spacing.screenHorizontal)
                .padding(.vertical, Spacing.s)

            ScrollView {
                content
                    .padding(.horizontal, Spacing.screenHorizontal)
                    .padding(.vertical, Spacing.l)
            }
        }
        .background(Color.appBackground)
        .presentationDetents([.large])
        .presentationDragIndicator(.visible)
        .presentationCornerRadius(Radius.xLarge)
    }

    // 검색창: 돋보기 + 입력 + 지우기(✕)
    private var searchField: some View {
        @Bindable var vm = vm
        return HStack(spacing: Spacing.s) {
            Image(systemName: "magnifyingglass")
                .foregroundStyle(Color.appTextSecondary)

            TextField("재료 이름 검색", text: $vm.query)
                .appFont(.body)
                .foregroundStyle(Color.appTextPrimary)
                .autocorrectionDisabled()

            if !vm.query.isEmpty {
                Button { vm.query = "" } label: {
                    Image(systemName: "xmark")
                        .foregroundStyle(Color.appTextSecondary)
                }
            }
        }
        .padding(.horizontal, Spacing.l)
        .frame(height: Size.buttonHeight)
        .background(Color.appSurfaceSubtle)
        .clipShape(RoundedRectangle(cornerRadius: Radius.small))
    }

    @ViewBuilder
    private var content: some View {

        if vm.isEmptyResult {
            VStack(spacing: Spacing.s) {
                Image("logo-stone")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 104)
                    .padding(.bottom, Spacing.xs)

                Text(
                    vm.query.isEmpty
                        ? "재료가 목록에 없어요"
                        : "'\(vm.query)' 재료가 목록에 없어요"
                )
                .appFont(.brandSubtitle)
                .foregroundStyle(Color.appTextPrimary)
                .multilineTextAlignment(.center)

                if !vm.query.isEmpty {
                    Text("다른 재료명으로 검색해보세요.")
                        .appFont(.body)
                        .foregroundStyle(Color.appTextSecondary)
                }
            }
            .frame(maxWidth: .infinity)
            .padding(.top, Spacing.xl)
        } else {
            LazyVStack(alignment: .leading, spacing: Spacing.xl) {
                ForEach(vm.grouped, id: \.category) { group in
                    VStack(alignment: .leading, spacing: Spacing.m) {
                        Text(categoryTitle(group.category))
                            .appFont(.subbody)
                            .foregroundStyle(Color.appTextSecondary)

                        LazyVGrid(columns: columns, spacing: Spacing.s) {
                            ForEach(group.items) { item in
                                IngredientTile(
                                    label: item.name,
                                    imageName: item.imageName
                                ) { selectedItem = item }
                            }
                        }
                    }
                }
            }
        }
    }

    private func categoryTitle(_ key: String) -> String {
        switch key {
        case "meat": "고기"
        case "mushroom": "버섯"
        case "vegetable": "채소"
        default: key
        }
    }
}

#Preview {
    AddIngredientSheet()
}
