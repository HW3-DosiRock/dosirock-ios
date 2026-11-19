//
//  InventoryRepository.swift
//  DosiRock
//
//  Created by Admin on 11/16/26.
//
import Foundation

protocol InventoryRepository {
    func fetch() async throws -> [InventoryItem]
    func fetchPriority() async throws -> [InventoryPriorityItem]
    func add(
        _ ingredient: IngredientItem,
        quantity: Double?,
        recommendedDate: Date?
    ) async throws  // 이미 있으면 값을 바꿈
    func remove(ingredientId: Int) async throws
}

// 서버 응답: data { items, totalCount }
private nonisolated struct InventoryListResponse: Decodable {
    let items: [Item]
    let totalCount: Int

    struct Item: Decodable {
        let ingredientId: Int
        let name: String
        let unit: String
        let managementType: IngredientItem.ManagementType
        let quantity: Double?
        let expirationDate: String?
        let present: Bool?
        let category: String
        let decimalPlaces: Int
        let storageMethod: String?
        let storageDays: Int?
    }
}

private nonisolated struct InventoryPriorityListResponse: Decodable {
    let items: [Item]
    let totalCount: Int

    struct Item: Decodable {
        let ingredientId: Int
        let name: String
        let quantity: Double
        let unit: String
        let expirationDate: String
        let remainingDays: Int
    }
}
struct InventoryRepositoryImpl: InventoryRepository {

    let client: APIClient

    func fetch() async throws -> [InventoryItem] {

        let result = try await client.sendRequired(
            "inventory",
            method: .get,
            authorized: true,
            as: InventoryListResponse.self
        )

        return result.items.map { item in
            InventoryItem(
                name: item.name,
                ingredientId: item.ingredientId,
                quantity: item.quantity,
                unit: item.unit,
                managementType: item.managementType,
                recommendedDate: item.expirationDate.flatMap {
                    try? Date(
                        $0,
                        strategy: Date.ISO8601FormatStyle(timeZone: .current)
                            .year().month().day()
                    )
                }
            )
        }
    }

    func fetchPriority() async throws -> [InventoryPriorityItem] {

        let result = try await client.sendRequired(
            "inventory/priority",
            method: .get,
            authorized: true,
            as: InventoryPriorityListResponse.self
        )

        return result.items.map { item in
            InventoryPriorityItem(
                name: item.name,
                ingredientId: item.ingredientId,
                quantity: item.quantity,
                unit: item.unit,
                expirationDate: (try? Date(
                    item.expirationDate,
                    strategy: Date.ISO8601FormatStyle(timeZone: .current).year()
                        .month().day()
                )) ?? Date(),
                remainingDays: item.remainingDays
            )
        }
    }

    func add(
        _ ingredient: IngredientItem,
        quantity: Double?,
        recommendedDate: Date?
    ) async throws {

        let body: [String: Any]

        switch ingredient.managementType {

        case .quantity:
            guard let quantity, let recommendedDate else {
                throw APIError.unknown
            }
            body = [
                "quantity": quantity,
                "expirationDate": recommendedDate.formatted(
                    Date.ISO8601FormatStyle(timeZone: .current).year().month()
                        .day()
                ),
            ]

        case .presence:
            body = ["present": true]
        }

        _ = try await client.send(
            "inventory/\(ingredient.id)",
            method: .put,
            body: body,
            authorized: true,
            as: Empty.self
        )
    }

    func remove(ingredientId: Int) async throws {

        _ = try await client.send(
            "inventory/\(ingredientId)",
            method: .delete,
            authorized: true,
            as: Empty.self
        )

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
                throw APIError.network
            case .slow:
                try await Task.sleep(for: .seconds(5))
            default:
                try await Task.sleep(for: .milliseconds(500))
            }
            return items  // 장부를 읽는다
        }

        func fetchPriority() async throws -> [InventoryPriorityItem] {
            items.compactMap { item in
                guard let quantity = item.quantity, let date = item.recommendedDate,
                      let days = item.daysUntilRecommended(), days <= 7 else { return nil }
                return InventoryPriorityItem(
                    name: item.name, ingredientId: item.ingredientId,
                    quantity: quantity, unit: item.unit,
                    expirationDate: date, remainingDays: days
                )
            }
        }
        
        func add(
            _ ingredient: IngredientItem,
            quantity: Double?,
            recommendedDate: Date?
        ) async throws {
            // 이미 있는 재료는 수량만 바꾸고, 없으면 새로 추가 (서버의 등록·수정과 같은 동작)
            if let index = items.firstIndex(where: {
                $0.ingredientId == ingredient.id
            }) {
                items[index].quantity = quantity
                items[index].recommendedDate = recommendedDate
            } else {
                items.append(
                    InventoryItem(
                        name: ingredient.name,
                        ingredientId: ingredient.id,
                        quantity: quantity,
                        unit: ingredient.unit,
                        managementType: ingredient.managementType,
                        recommendedDate: recommendedDate
                    )
                )
            }
        }

        func remove(ingredientId: Int) async throws {
            items.removeAll { $0.ingredientId == ingredientId }
        }

        // 오늘로부터 n일 뒤 (샘플 권장 사용일용)
        private static func day(_ n: Int) -> Date {
            Calendar.current.date(byAdding: .day, value: n, to: Date())
                ?? Date()
        }

        static let samples: [InventoryItem] = [
            InventoryItem(
                name: "팽이버섯",
                ingredientId: 25,
                quantity: 300,
                unit: "g",
                recommendedDate: day(1)
            ),
            InventoryItem(
                name: "닭고기",
                ingredientId: 35,
                quantity: 500,
                unit: "g",
                recommendedDate: day(1)
            ),
            InventoryItem(
                name: "두부",
                ingredientId: 40,
                quantity: 2,
                unit: "개",
                recommendedDate: day(2)
            ),
            InventoryItem(
                name: "소금",
                ingredientId: 46,
                unit: "g",
                managementType: .presence
            ),
        ]

    }
#endif
