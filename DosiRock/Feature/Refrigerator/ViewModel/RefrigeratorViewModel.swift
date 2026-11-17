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

    // 이 재료가 냉장고에 등록되어 있는지 (체크 표시 등에서 사용)
    func isRegistered(_ ingredient: IngredientItem) -> Bool {
        registeredIngredientIds.contains(ingredient.id)
    }
    
    // 이 재료의 냉장고 보유 수량 (등록 안 된 재료는 nil)
    func quantity(of ingredient: IngredientItem) -> Double? {
        items.first { $0.ingredientId == ingredient.id }?.quantity
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

    // 냉장고에서 삭제하고 목록을 다시 읽음 (마지막 재료였으면 빈 냉장고 화면)
    func remove(_ ingredient: IngredientItem) async throws {
        try await inventory.remove(ingredientId: ingredient.id)
        items = try await inventory.fetch()
        state = items.isEmpty ? .empty : .loaded(items)
    }

    func register(_ ingredient: IngredientItem, quantity: Double?) async throws {

        let isNew = !isRegistered(ingredient)  // 이미 있는 재료의 수정은 "N종 등록 완료"에 세지 않음
        try await inventory.add(ingredient, quantity: quantity)  // 1. 장부에 적어 달라고 시킨다
        items = try await inventory.fetch()  // 2. 장부를 다시 읽어서 최신 상태로 맞춘다
        state = items.isEmpty ? .empty : .loaded(items)  // 첫 등록이면 빈 화면 → 목록 화면
        if isNew { registeredCount += 1 }

    }
}
