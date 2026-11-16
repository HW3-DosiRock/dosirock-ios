//
//  AddIngredientSheet.swift
//  DosiRock
//
//  Created by Seungyeon Jeon on 11/15/26.
//

import SwiftUI

struct AddIngredientSheet: View {

    @Environment(\.dismiss) private var dismiss
    @State private var vm: IngredientPickerViewModel
    @State private var selectedItem: IngredientItem?  // 눌린 재료 (두 번째 시트용)
    private let columns = Array(
        repeating: GridItem(.flexible(), spacing: Spacing.s),
        count: 4
    )

    // 프리뷰용
    init(vm: IngredientPickerViewModel) { _vm = State(initialValue: vm) }

    // 실기기용
    init() {
        self.init(
            vm: IngredientPickerViewModel(
                repository: AppEnvironment.makeIngredientRepository()
            )
        )
    }

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
        .task { await vm.load() }
        .presentationDetents([.large])
        .presentationDragIndicator(.visible)
        .presentationCornerRadius(Radius.xLarge)
        .modifier(PageSheetSizing())
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
        switch vm.state {
        case .loading:
            LoadingView().frame(maxWidth: .infinity).padding(.top, Spacing.xl)
        case .failed:
            VStack(spacing: Spacing.l) {
                Text("my_load_failed")
                    .appFont(.body)
                    .foregroundStyle(Color.appTextSecondary)
                PrimaryButton(title: "common_retry") { Task { await vm.load() } }
                    .frame(width: 160)
            }
            .frame(maxWidth: .infinity)
            .padding(.top, Spacing.xl)
        case .loaded:
            loadedContent
        }
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
                        Text(group.category.title)
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

}

#Preview {
    AddIngredientSheet()
}

// iPad에서 시트가 가운데 작은 카드로 뜨지 않고 화면을 크게 채우게 함 (iOS 18+, 17은 기본 동작)
private struct PageSheetSizing: ViewModifier {
    func body(content: Content) -> some View {
        if #available(iOS 18, *) {
            content.presentationSizing(.page)
        } else {
            content
        }
    }
}
