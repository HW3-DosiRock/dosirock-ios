//
//  InventoryRepositpry.swift
//  DosiRock
//
//  Created by Admin on 11/16/26.
//
import Foundation

protocol InventoryRepository {
    func fetch() async throws -> [InventoryItem]
    func add(_ ingredient: IngredientItem, quantity: Double?) async throws  // 이미 있으면 수량을 바꿈
    func remove(ingredientId: Int) async throws
}

//TODO 삭제 (API 구현 전까지)
struct EmptyInventoryRepository: InventoryRepository {

    func fetch() async throws -> [InventoryItem] {
        []
    }

    func add(_ ingredient: IngredientItem, quantity: Double?) async throws {

    }

    func remove(ingredientId: Int) async throws {

    }

}

#if DEBUG
    actor PreviewInventoryRepository: InventoryRepository {

        enum Scenario { case filled, empty, failure, slow }

        private let scenario: Scenario
        private var items: [InventoryItem]

        init(scenario: Scenario = .filled) {
            self.scenario = scenario
            self.items = (scenario == .empty) ? [] : Self.samples
        }

        func fetch() async throws -> [InventoryItem] {

            switch scenario {
            case .failure:
                try await Task.sleep(for: .milliseconds(500))
                throw AuthError.network
            case .slow:
                try await Task.sleep(for: .seconds(5))
            default:
                try await Task.sleep(for: .milliseconds(500))
            }
            return items  // 장부를 읽는다
        }

        func add(_ ingredient: IngredientItem, quantity: Double?) async throws {
            // 이미 있는 재료는 수량만 바꾸고, 없으면 새로 추가 (서버의 등록·수정과 같은 동작)
            if let index = items.firstIndex(where: { $0.ingredientId == ingredient.id }) {
                items[index].quantity = quantity
            } else {
                items.append(
                    InventoryItem(
                        id: UUID().uuidString,
                        name: ingredient.name,
                        ingredientId: ingredient.id,
                        quantity: quantity,
                        unit: ingredient.unit,
                        managementType: ingredient.managementType
                    )
                )
            }
        }

        func remove(ingredientId: Int) async throws {
            items.removeAll { $0.ingredientId == ingredientId }
        }

        static let samples: [InventoryItem] = [
            InventoryItem(
                id: "enoki",
                name: "팽이버섯",
                ingredientId: 25,
                quantity: 300,
                unit: "g"
            ),
            InventoryItem(
                id: "chicken",
                name: "닭고기",
                ingredientId: 35,
                quantity: 500,
                unit: "g"
            ),
            InventoryItem(
                id: "tofu",
                name: "두부",
                ingredientId: 40,
                quantity: 2,
                unit: "개"
            ),
            InventoryItem(
                id: "salt",
                name: "소금",
                ingredientId: 46,
                unit: "g",
                managementType: .presence
            ),
        ]

    }
#endif
