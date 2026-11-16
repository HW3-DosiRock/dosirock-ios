//
//  RefrigeratorViewModel.swift
//  DosiRock
//
//  Created by Admin on 11/16/26.
//

import Foundation

@Observable @MainActor
final class RefrigeratorViewModel {

    enum State {
        case loading
        case failed
        case empty  // 재료가 하나도 없음 (초기 화면)
        case loaded([InventoryItem])
    }

    private let inventory: InventoryRepository
    private(set) var items: [InventoryItem] = []

    var state: State = .loading

    var showAddSheet = false

    // 이번에 시트를 연 뒤로 등록한 재료 수 (등록 완료 배너용)
    private(set) var registeredCount = 0

    func openAddSheet() {
        registeredCount = 0
        showAddSheet = true
    }

    var registeredIngredientIds: Set<Int> {
        Set(items.map(\.ingredientId))
    }
    
    init(inventory: InventoryRepository) {
        self.inventory = inventory
    }

    func load() async {
        state = .loading
        do {
            items = try await inventory.fetch()
            state = items.isEmpty ? .empty : .loaded(items)
        } catch {
            state = .failed
        }
    }

    func register(_ ingredient: IngredientItem) async throws {

        try await inventory.add(ingredient)  // 1. 장부에 적어 달라고 시킨다
        items = try await inventory.fetch()  // 2. 장부를 다시 읽어서 최신 상태로 맞춘다
        state = items.isEmpty ? .empty : .loaded(items)  // 첫 등록이면 빈 화면 → 목록 화면
        registeredCount += 1

    }
}
