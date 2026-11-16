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
            onAdd: { vm.openAddSheet() }
        )
        .task {
            await vm.load()
        }
        .sheet(isPresented: $vm.showAddSheet) {
            AddIngredientSheet(refrigerVm: vm)
        }
    }

}

struct RefrigeratorContentView: View {

    let state: RefrigeratorViewModel.State
    var registeredCount = 0  // 방금 등록한 재료 수 (0이면 배너 숨김)
    var onRetry: () -> Void = {}
    var onAdd: () -> Void = {}

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
        VStack(alignment: .leading, spacing: Spacing.m) {
            if registeredCount > 0 {
                AppBanner(
                    type: .success,
                    message: String(
                        format: String(localized: "fridge_registered_banner"),
                        registeredCount
                    )
                )
            }
            // TODO: 재료 목록 화면 (시안이 나오면)
            Text("재료 \(items.count)개")
            Spacer()
        }
        .frame(maxWidth: .infinity, alignment: .topLeading)
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
    #Preview("빈 냉장고") { RefrigeratorContentView(state: .empty) }
    #Preview("불러오기 실패") { RefrigeratorContentView(state: .failed) }
    #Preview("로딩") { RefrigeratorContentView(state: .loading) }
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
