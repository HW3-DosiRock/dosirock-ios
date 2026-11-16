//
//  InventoryRepositpry.swift
//  DosiRock
//
//  Created by Admin on 11/16/26.
//

protocol InventoryRepository {
    func fetch() async throws -> [InventoryItem]
}

//TODO 삭제 (API 구현 전까지)
struct EmptyInventoryRepository: InventoryRepository {

    func fetch() async throws -> [InventoryItem] {
        []
    }

}

#if DEBUG
    struct PreviewInventoryRepository: InventoryRepository {

        enum Scenario { case filled, empty, failure, slow }
        var scenario: Scenario = .filled

        func fetch() async throws -> [InventoryItem] {

            switch scenario {
            case .filled:
                try await Task.sleep(for: .milliseconds(500))
                return Self.samples
            case .empty:
                try await Task.sleep(for: .milliseconds(500))
                return []
            case .failure:
                try await Task.sleep(for: .milliseconds(500))
                throw AuthError.network
            case .slow:
                try await Task.sleep(for: .seconds(5))
                return Self.samples
            }
        }

        static let samples: [InventoryItem] = [
            InventoryItem(
                id: "enoki",
                name: "팽이버섯",
                imageName: "ingredient_mushroom_enoki"
            ),
            InventoryItem(
                id: "chicken",
                name: "닭고기",
                imageName: "ingredient_meat_chicken"
            ),
            InventoryItem(
                id: "tofu",
                name: "두부",
                imageName: "ingredient_etc_tofu"
            ),
        ]

    }
#endif
