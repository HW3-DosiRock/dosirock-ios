//
//  IngredientPickerContent.swift
//  DosiRock
//
//  Created by Seungyeon Jeon on 11/18/26.
//

import SwiftUI

/// 재료 고르기 화면의 안쪽 (검색창 + 카테고리별 재료 그리드).
/// "무엇이 체크인지"와 "누르면 무엇을 할지"는 쓰는 쪽이 정한다 → 냉장고 등록, 이번 주 먹고 싶은 재료 등에서 같이 쓴다.
struct IngredientPickerContent: View {

    let vm: IngredientPickerViewModel
    let isChecked: (IngredientItem) -> Bool
    let onTap: (IngredientItem) -> Void

    private let columns = Array(
        repeating: GridItem(.flexible(), spacing: Spacing.s),
        count: 4
    )

    var body: some View {
        VStack(spacing: 0) {
            searchField
                .padding(.horizontal, Spacing.screenHorizontal)
                .padding(.vertical, Spacing.s)

            ScrollView {
                content
                    .padding(.horizontal, Spacing.screenHorizontal)
                    .padding(.vertical, Spacing.l)
            }
        }
        .task { await vm.load() }
    }

    // 검색창: 돋보기 + 입력 + 지우기(✕)
    private var searchField: some View {
        @Bindable var vm = vm
        return HStack(spacing: Spacing.s) {
            Image(systemName: "magnifyingglass")
                .foregroundStyle(Color.appTextSecondary)

            TextField("fridge_picker_search_placeholder", text: $vm.query)
                .appFont(.body)
                .foregroundStyle(Color.appTextPrimary)
                .autocorrectionDisabled()

            if !vm.query.isEmpty {
                Button {
                    vm.query = ""
                } label: {
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
        switch vm.state {
        case .loading:
            LoadingView().frame(maxWidth: .infinity).padding(.top, Spacing.xl)
        case .failed:
            LoadFailedView(title: .fridgePickerLoadFailed) {
                Task { await vm.load() }
            }
            .padding(.top, Spacing.xl)
        case .loaded:
            loadedContent
        }
    }

    // 검색 결과가 없을 때 제목 (검색어가 있으면 검색어를 넣어서)
    private var emptyTitle: String {
        vm.query.isEmpty
            ? String(localized: "fridge_picker_empty")
            : String(
                format: String(localized: "fridge_picker_empty_query"),
                vm.query
            )
    }

    @ViewBuilder
    private var loadedContent: some View {

        if vm.isEmptyResult {
            VStack(spacing: Spacing.s) {
                Image("logo-stone")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 104)
                    .padding(.bottom, Spacing.xs)

                Text(emptyTitle)
                    .appFont(.brandSubtitle)
                    .foregroundStyle(Color.appTextPrimary)
                    .multilineTextAlignment(.center)

                if !vm.query.isEmpty {
                    Text("fridge_picker_search_hint")
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
                        Text(group.category.title)
                            .appFont(.subbody)
                            .foregroundStyle(Color.appTextSecondary)

                        LazyVGrid(columns: columns, spacing: Spacing.s) {
                            ForEach(group.items) { item in
                                IngredientTile(
                                    label: IngredientNameBreak.display(
                                        item.mainName
                                    ),
                                    imageName: item.imageName,
                                    subLabel: item.subName,
                                    reservesNameSpace: true,
                                    isChecked: isChecked(item)
                                ) { onTap(item) }
                            }
                        }
                    }
                }
            }
        }
    }
}
