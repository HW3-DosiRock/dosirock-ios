//
//  RefrigeratorView.swift
//  DosiRock
//
//  Created by Admin on 11/12/26.
//

import SwiftUI

// 냉장고 탭 (임시 화면)
struct RefrigeratorView: View {

    @Environment(\.container) private var container

    @State private var vm: RefrigeratorViewModel
    @State private var editingItem: IngredientItem?  // 냉장고에서 누른 재료 (등록 시트용)

    init(vm: RefrigeratorViewModel) {
        _vm = State(initialValue: vm)
    }

    var body: some View {

        RefrigeratorContentView(
            state: vm.state,
            priorityItems: vm.priorityItems,
            registeredCount: vm.registeredCount,
            onRetry: { Task { await vm.load() } },
            onAdd: { vm.openAddSheet() },
            onSelectItem: { editingItem = vm.ingredient(for: $0) }  // 재료 ID로 수정 시트 열기
        )
        .task {
            await vm.load()
        }
        .sheet(isPresented: $vm.showAddSheet) {
            AddIngredientSheet(
                refrigerVm: vm,
                vm: IngredientPickerViewModel(repository: container.ingredients)
            )
        }
        .sheet(item: $editingItem) { item in
            IngredientRegistrationSheet(
                ingredient: item,
                refrigerVm: vm,
                previousQuantity: vm.quantity(of: item),
                previousExpirationDate: vm.expirationDate(of: item),
                isExisting: vm.isRegistered(item)
            )
            .id(item.id)    // 재료가 바뀌면 새 시트로 ( 안하면 이전에 선택 했던 재료로 노출됨) 
        }
    }

}

struct RefrigeratorContentView: View {

    let state: RefrigeratorViewModel.State
    var priorityItems: [InventoryPriorityItem] = []  // 빨리 써야 할 재료 (서버가 급한 순으로 줌)
    var registeredCount = 0  // 방금 등록한 재료 수 (0이면 배너 숨김)
    var onRetry: () -> Void = {}
    var onAdd: () -> Void = {}
    var onSelectItem: (Int) -> Void = { _ in }  // 누른 재료의 ingredientId

    var body: some View {

        VStack {
            header
            Group {
                switch state {
                case .loading:
                    TabSkeletonView()
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

    // 빨리 써야 할 재료: 서버가 기한 7일 이내·지난 재료를 급한 순으로 줌 (없으면 섹션 숨김)
    @ViewBuilder
    private var userPriority: some View {
        if !priorityItems.isEmpty {
            VStack(alignment: .leading, spacing: Spacing.m) {
                SectionHeader(
                    title: "fridge_list_priority_title",
                    titleStyle: .heading,
                    caption: "fridge_list_priority_sub"
                )
                GroupedListCard(items: priorityItems) { item in
                    Button {
                        onSelectItem(item.ingredientId)  // 타일과 같은 재료 수정 시트
                    } label: {
                        ListRow(
                            iconCodes: [item.imageName],
                            title: item.name,
                            subtitle: String(
                                format: String(localized: "fridge_priority_subtitle"),
                                item.quantityText,
                                item.expirationDate.shortKorean
                            ),
                            badgePlacement: .trailing
                        ) {
                            priorityBadge(item.remainingDays)
                        }
                        .contentShape(Rectangle())
                    }
                    .buttonStyle(.plain)
                }
            }
        }
    }

    // 오늘·내일·N일 안에 (같은 분홍색 뱃지)
    // shortcut: 기한 지난 재료(음수)도 "오늘까지"로 보임, 지난 재료 디자인 나오면 분리
    private func priorityBadge(_ days: Int) -> some View {
        let title: LocalizedStringKey =
            switch days {
            case ...0: "fridge_priority_badge_today"
            case 1: "recipe_badge_tomorrow"
            default:
                LocalizedStringKey(
                    String(
                        format: String(localized: "fridge_priority_badge_days"),
                        days
                    )
                )
            }
        return RecipeBadge(type: .tomorrow, title: title)
    }

    private let gridColumns = Array(
        repeating: GridItem(.flexible(), spacing: Spacing.s),
        count: 3
    )

    // 섹션 하나: 제목(개수) + 타일 그리드. 재료가 없으면 섹션 자체를 숨김
    @ViewBuilder
    private func inventorySection(
        titleKey: LocalizedStringResource,
        captionKey: LocalizedStringResource,
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
                        ) { onSelectItem(item.ingredientId) }

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
        LoadFailedView(title: .fridgeLoadFailed, onRetry: onRetry)
    }
}

#if DEBUG
    //    #Preview("빈 냉장고") { RefrigeratorContentView(state: .empty) }
    //    #Preview("불러오기 실패") { RefrigeratorContentView(state: .failed) }
    //    #Preview("로딩") { RefrigeratorContentView(state: .loading) }
    #Preview("목록") {
        RefrigeratorContentView(
            state: .loaded(PreviewInventoryRepository.samples),
            priorityItems: [
                InventoryPriorityItem(
                    name: "양파", ingredientId: 1, quantity: 300, unit: "g",
                    expirationDate: Date(), remainingDays: -2
                ),
                InventoryPriorityItem(
                    name: "달걀", ingredientId: 39, quantity: 4, unit: "개",
                    expirationDate: Date().addingTimeInterval(60 * 60 * 24 * 7),
                    remainingDays: 7
                ),
            ]
        )
    }
    #Preview("등록 직후") {
        RefrigeratorContentView(
            state: .loaded(PreviewInventoryRepository.samples),
            registeredCount: 3
        )
    }
#endif
