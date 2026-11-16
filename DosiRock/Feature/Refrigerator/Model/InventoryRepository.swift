//
//  InventoryRepositpry.swift
//  DosiRock
//
//  Created by Admin on 11/16/26.
//
import Foundation

protocol InventoryRepository {
    func fetch() async throws -> [InventoryItem]
    func add(_ ingredient: IngredientItem) async throws
}

//TODO 삭제 (API 구현 전까지)
struct EmptyInventoryRepository: InventoryRepository {

    func fetch() async throws -> [InventoryItem] {
        []
    }

    func add(_ ingredient: IngredientItem) async throws {

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

        func add(_ ingredient: IngredientItem) async throws {
            items.append(
                InventoryItem(
                    id: UUID().uuidString,
                    name: ingredient.name,
                    ingredientId: ingredient.id
                )
            )
        }

        static let samples: [InventoryItem] = [
            InventoryItem(
                id: "enoki",
                name: "팽이버섯",
                ingredientId: 25
            ),
            InventoryItem(
                id: "chicken",
                name: "닭고기",
                ingredientId: 35
            ),
            InventoryItem(
                id: "tofu",
                name: "두부",
                ingredientId: 40
            ),
        ]

    }
#endif
