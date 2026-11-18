//
//  IngredientPickerViewModel.swift
//  DosiRock
//
//  Created by Seungyeon Jeon on 11/15/26.
//

import Foundation

@Observable @MainActor
final class IngredientPickerViewModel {

    enum State { case loading, failed, loaded }

    private(set) var state: State = .loading
    private(set) var ingredients: [IngredientItem] = []
    var query = ""

    private let repository: IngredientRepository

    init(repository: IngredientRepository) {
        self.repository = repository
    }

    func load() async {
        state = .loading
        do {
            ingredients = try await repository.fetchAll()

            #if DEBUG
                let unmapped = ingredients.filter {
                    !IngredientImageMap.isMapped($0.name)
                }.map(\.name)
                if !unmapped.isEmpty { print("⚠️ 이미지 매핑 없음:", unmapped) }
            #endif

            state = .loaded
        } catch {
            state = .failed
        }
    }

    private var filtered: [IngredientItem] {
        // 자모로 풀어서 비교: "ㅍ", "패", "팽" 모두 "팽이버섯"에 매치
        let q = query.decomposedStringWithCompatibilityMapping
        return query.isEmpty
            ? ingredients
            : ingredients.filter {
                $0.name.decomposedStringWithCompatibilityMapping
                    .range(of: q, options: .literal) != nil
            }
    }
    var isEmptyResult: Bool { filtered.isEmpty }

    // 카테고리 정의 순서대로, 재료가 있는 카테고리만
    var grouped: [(category: IngredientItem.Category, items: [IngredientItem])]
    {
        IngredientItem.Category.allCases.compactMap { category in
            let items = filtered.filter { $0.category == category }
            return items.isEmpty ? nil : (category, items)
        }
    }
}
