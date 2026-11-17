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
    let refrigerVm: RefrigeratorViewModel
    @State private var selectedItem: IngredientItem?  // 눌린 재료 (두 번째 시트용)
    private let columns = Array(
        repeating: GridItem(.flexible(), spacing: Spacing.s),
        count: 4
    )

    init(
        refrigerVm: RefrigeratorViewModel,
        vm: IngredientPickerViewModel? = nil
    ) {
        self.refrigerVm = refrigerVm
        _vm = State(
            initialValue: vm
                ?? IngredientPickerViewModel(
                    repository: AppEnvironment.makeIngredientRepository()
                )
        )
    }
    var body: some View {

        VStack(spacing: 0) {
            NavigationHeader(
                title: "fridge_picker_title",
                leadingTitle: "common_close",
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
        .sheet(item: $selectedItem) { item in
            IngredientRegistrationSheet(
                ingredient: item,
                refrigerVm: refrigerVm,
                previousQuantity: refrigerVm.quantity(of: item)
            )
        }
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
            VStack(spacing: Spacing.l) {
                Text("my_load_failed")
                    .appFont(.body)
                    .foregroundStyle(Color.appTextSecondary)
                PrimaryButton(title: "common_retry") {
                    Task { await vm.load() }
                }
                .frame(width: 160)
            }
            .frame(maxWidth: .infinity)
            .padding(.top, Spacing.xl)
        case .loaded:
            loadedContent
        }
    }

    // 검색 결과가 없을 때 제목 (검색어가 있으면 검색어를 넣어서)
    private var emptyTitle: String {
        vm.query.isEmpty
            ? String(localized: "fridge_picker_empty")
            : String(format: String(localized: "fridge_picker_empty_query"), vm.query)
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
                                    label: IngredientNameBreak.display(item.mainName),
                                    imageName: item.imageName,
                                    subLabel: item.subName,
                                    reservesNameSpace: true,
                                    isChecked: refrigerVm.isRegistered(item)
                                ) { selectedItem = item }
                            }
                        }
                    }
                }
            }
        }
    }

}

#if DEBUG
    // 프리뷰는 실제 서버 대신 샘플 데이터를 쓴다 (vm을 안 넘기면 서버에 요청해서 프리뷰에서는 실패함)
    #Preview {
        AddIngredientSheet(
            refrigerVm: RefrigeratorViewModel(
                inventory: PreviewInventoryRepository()
            ),
            vm: IngredientPickerViewModel(
                repository: PreviewIngredientRepository(scenario: .filled)
            )
        )
    }
#endif

// iPad에서 시트가 가운데 작은 카드로 뜨지 않고 화면을 크게 채우게 함 (iOS 18+, 17은 기본 동작)
struct PageSheetSizing: ViewModifier {
    func body(content: Content) -> some View {
        if #available(iOS 18, *) {
            content.presentationSizing(.page)
        } else {
            content
        }
    }
}
