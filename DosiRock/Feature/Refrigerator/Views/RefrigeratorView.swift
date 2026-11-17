//
//  RefrigeratorView.swift
//  DosiRock
//
//  Created by Admin on 11/12/26.
//

import SwiftUI

// 냉장고 탭 (임시 화면)
struct RefrigeratorView: View {

    @State private var vm: RefrigeratorViewModel
    @State private var editingItem: IngredientItem?  // 냉장고에서 누른 재료 (등록 시트용)

    //프리뷰용
    init(vm: RefrigeratorViewModel) {
        _vm = State(initialValue: vm)
    }

    //실기기용
    init() {
        self.init(
            vm: RefrigeratorViewModel(
                inventory: AppEnvironment.makeInventoryRepository()
            )
        )
    }

    var body: some View {

        RefrigeratorContentView(
            state: vm.state,
            registeredCount: vm.registeredCount,
            onRetry: { Task { await vm.load() } },
            onAdd: { vm.openAddSheet() },
            onSelectItem: { editingItem = vm.ingredient(for: $0) }
        )
        .task {
            await vm.load()
        }
        .sheet(isPresented: $vm.showAddSheet) {
            AddIngredientSheet(refrigerVm: vm)
        }
        .sheet(item: $editingItem) { item in
            IngredientRegistrationSheet(
                ingredient: item,
                refrigerVm: vm,
                previousQuantity: vm.quantity(of: item),
                isExisting: vm.isRegistered(item)
            )
        }
    }

}

struct RefrigeratorContentView: View {

    let state: RefrigeratorViewModel.State
    var registeredCount = 0  // 방금 등록한 재료 수 (0이면 배너 숨김)
    var onRetry: () -> Void = {}
    var onAdd: () -> Void = {}
    var onSelectItem: (InventoryItem) -> Void = { _ in }

    var body: some View {

        VStack {
            header
            Group {
                switch state {
                case .loading:
                    LoadingView()
                case .failed:
                    failedContent
                case .empty:
                    emptyContent
                case .loaded(let items):
                    loadedContent(items)
                }
            }
        }
        .padding(Spacing.screenHorizontal)
        .background(Color.appBackground.ignoresSafeArea())

    }

    // 제목 + (재료가 있을 때만) "+ 재료 추가"
    private var header: some View {
        HStack {
            Text("tab_fridge")
                .appFont(.brandTitle)
                .foregroundStyle(Color.appTextPrimary)
            Spacer()
            if case .loaded = state {
                TextLinkButton(
                    title: "fridge_header_add",
                    icon: "plus",
                    textColor: .appTextPrimary,
                    textStyle: .subbody
                ) { onAdd() }
            }
        }
    }

    private func loadedContent(_ items: [InventoryItem]) -> some View {
        ScrollView {
            VStack(alignment: .leading, spacing: Spacing.xl) {
                if registeredCount > 0 {
                    AppBanner(
                        type: .success,
                        message: String(
                            format: String(
                                localized: "fridge_registered_banner"
                            ),
                            registeredCount
                        ),
                        showIcon: true,
                        actionMessage: "fridge_registered_banner_action"
                    ) {
                        //TODO: 이번주 메뉴 제안 받기 실행
                    }
                }
                userPriority
                // 수량 재료 / 기본 재료(보유 여부만 관리)로 나눠서 보여줌
                inventorySection(
                    titleKey: "fridge_list_quantity_title",
                    captionKey: "fridge_list_quantity_sub",
                    items: items.filter { $0.managementType == .quantity },
                    showsQuantity: true
                )
                inventorySection(
                    titleKey: "fridge_list_presence_title",
                    captionKey: "fridge_list_presence_sub",
                    items: items.filter { $0.managementType == .presence },
                    showsQuantity: false
                )
            }
            .frame(maxWidth: .infinity, alignment: .topLeading)
        }
    }

    private var userPriority: some View {
        // TODO: 빨리 써야 할 재료 (재고에 권장 사용일이 생기면)
        VStack {
           
            EmptyView()
        }
    }

    private let gridColumns = Array(
        repeating: GridItem(.flexible(), spacing: Spacing.s),
        count: 3
    )

    // 섹션 하나: 제목(개수) + 타일 그리드. 재료가 없으면 섹션 자체를 숨김
    @ViewBuilder
    private func inventorySection(
        titleKey: LocalizedStringKey,
        captionKey: LocalizedStringKey,
        items: [InventoryItem],
        showsQuantity: Bool
    ) -> some View {
        if !items.isEmpty {
            VStack(alignment: .leading, spacing: Spacing.m) {
                SectionHeader(
                    title: titleKey,
                    titleStyle: .heading,
                    count: items.count,
                    caption: captionKey
                )
                LazyVGrid(columns: gridColumns, spacing: Spacing.s) {
                    ForEach(items) { item in
                        IngredientTile(
                            label: item.name,
                            imageName: item.imageName,
                            reservesNameSpace: true,
                            details: showsQuantity
                                ? [item.quantityText].compactMap { $0 } : [],
                            type: .selectable
                        ) { onSelectItem(item) }

                    }
                }
            }
        }
    }

    private var emptyContent: some View {

        VStack(spacing: Spacing.s) {

            Spacer()

            Image("logo-stone")
                .resizable()
                .scaledToFit()
                .frame(width: 104)
                .padding(.bottom, Spacing.xs)

            Text("fridge_empty_desc")
                .appFont(.brandSubtitle)
                .multilineTextAlignment(.center)  // 여러 줄일 때 가운데 정렬

            Text("fridge_empty_sub_desc")
                .appFont(.body)
                .foregroundStyle(Color.appTextSecondary)
                .multilineTextAlignment(.center)

            PrimaryButton(title: "fridge_add_ingredient") {
                onAdd()
            }
            .frame(width: 140)
            .padding(.top, Spacing.m)

            Spacer()

        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .padding(Spacing.screenHorizontal)
    }

    private var failedContent: some View {
        VStack(spacing: Spacing.l) {
            Spacer()
            Text("my_load_failed")
                .appFont(.body)
                .foregroundStyle(Color.appTextSecondary)
            PrimaryButton(title: "common_retry") { onRetry() }
                .frame(width: 160)
            Spacer()
        }
    }
}

#if DEBUG
    //    #Preview("빈 냉장고") { RefrigeratorContentView(state: .empty) }
    //    #Preview("불러오기 실패") { RefrigeratorContentView(state: .failed) }
    //    #Preview("로딩") { RefrigeratorContentView(state: .loading) }
    #Preview("목록") {
        RefrigeratorContentView(
            state: .loaded(PreviewInventoryRepository.samples)
        )
    }
    #Preview("등록 직후") {
        RefrigeratorContentView(
            state: .loaded(PreviewInventoryRepository.samples),
            registeredCount: 3
        )
    }
#endif
