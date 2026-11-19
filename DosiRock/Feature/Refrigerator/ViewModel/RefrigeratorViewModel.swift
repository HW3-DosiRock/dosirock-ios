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
    private(set) var priorityItems: [InventoryPriorityItem] = []

    var state: State = .loading

    var showAddSheet = false

    // 이번에 시트를 연 뒤로 새로 등록한 재료 (등록 완료 배너용, 삭제하면 빠짐)
    private var registeredThisSession: Set<Int> = []
    var registeredCount: Int { registeredThisSession.count }

    func openAddSheet() {
        registeredThisSession = []
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

    // 이 재료의 저장된 소비기한 (등록 안 된 재료는 nil)
    func expirationDate(of ingredient: IngredientItem) -> Date? {
        items.first { $0.ingredientId == ingredient.id }?.recommendedDate
    }

    // 재료 기준 정보 (id → 재료). 냉장고 타일을 눌렀을 때 등록 시트에 넘길 재료를 찾는 데 씀
    private let ingredientRepository: IngredientRepository
    private var ingredients: [Int: IngredientItem] = [:]

    func ingredient(for ingredientId: Int) -> IngredientItem? {
        ingredients[ingredientId]
    }

    init(
        inventory: InventoryRepository,
        ingredientRepository: IngredientRepository
    ) {
        self.inventory = inventory
        self.ingredientRepository = ingredientRepository
    }

    func load() async {
        state = .loading
        do {
            try await reload()
        } catch {
            state = .failed
        }
        if let list = try? await ingredientRepository.fetchAll() {
            ingredients = Dictionary(
                list.map { ($0.id, $0) },
                uniquingKeysWith: { first, _ in first }
            )
        }
    }

    private func reload() async throws {
        async let all = inventory.fetch()
        async let soon = try? inventory.fetchPriority()
        items = try await all
        priorityItems = await soon ?? []
        state = items.isEmpty ? .empty : .loaded(items)
    }

    // 냉장고에서 삭제하고 목록을 다시 읽음 (마지막 재료였으면 빈 냉장고 화면)
    func remove(_ ingredient: IngredientItem) async throws {
        try await inventory.remove(ingredientId: ingredient.id)
        registeredThisSession.remove(ingredient.id)  // 방금 등록한 걸 지우면 배너 숫자도 줄어듦
        try await reload()
    }

    func register(
        _ ingredient: IngredientItem,
        quantity: Double?,
        recommendedDate: Date?
    ) async throws {

        let isNew = !isRegistered(ingredient)  // 이미 있는 재료의 수정은 "N종 등록 완료"에 세지 않음
        try await inventory.add(
            ingredient,
            quantity: quantity,
            recommendedDate: recommendedDate
        )  // 1. 장부에 적어 달라고 시킨다
        try await reload()  // 2. 냉장고·빨리 쓸 재료를 다시 읽어서 최신 상태로 맞춘다 (첫 등록이면 빈 화면 → 목록 화면)
        if isNew { registeredThisSession.insert(ingredient.id) }

    }
}
