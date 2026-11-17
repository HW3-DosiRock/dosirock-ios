//
//  IngredientRepository.swift
//  DosiRock
//
//  Created by Admin on 11/16/26.
//

import Foundation

// 재료 목록 (api 목록)
protocol IngredientRepository {
    func fetchAll() async throws -> [IngredientItem]
}

// 서버 응답: data { items, totalCount }
private nonisolated struct IngredientListResponse: Decodable {
    let items: [IngredientItem]
    let totalCount: Int
}

struct IngredientRepositoryImpl: IngredientRepository {

    private let client: APIClient

    init(baseURL: URL) {
        client = APIClient(baseURL: baseURL)
    }

    func fetchAll() async throws -> [IngredientItem] {
        let result = try await client.send(
            "ingredients",
            method: .get,
            authorized: true,
            as: IngredientListResponse.self
        )
        guard let result else { throw APIError.server }
        return result.items
    }
}

#if DEBUG
    // 프리뷰·화면 확인용 가짜
    struct PreviewIngredientRepository: IngredientRepository {
        enum Scenario { case filled, empty, failure }
        var scenario: Scenario = .filled

        func fetchAll() async throws -> [IngredientItem] {
            try await Task.sleep(for: .milliseconds(500))
            switch scenario {
            case .filled: return IngredientItem.samples
            case .empty: return []
            case .failure: throw APIError.network
            }
        }
    }
#endif
