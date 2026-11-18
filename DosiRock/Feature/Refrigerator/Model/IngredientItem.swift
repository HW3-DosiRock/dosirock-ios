//
//  IngredientItem.swift
//  DosiRock
//
//  Created by Seungyeon Jeon on 11/15/26.
//

nonisolated struct IngredientItem: Codable, Identifiable, Hashable {
    let id: Int
    let name: String
    let category: Category
    let unit: String
    let decimalPlaces: Int
    let managementType: ManagementType
    let storageMethod: StorageMethod?  // 기본 재료는 null
    let storageDays: Int?  // 기본 재료는 null

    enum Category: String, Codable, CaseIterable {
        case vegetable = "VEGETABLE"
        case mushroom = "MUSHROOM"
        case meat = "MEAT"
        case seafood = "SEAFOOD"
        case other = "OTHER"
        case basic = "BASIC"
    }
    enum ManagementType: String, Codable {
        case quantity = "QUANTITY"
        case presence = "PRESENCE"
    }
    enum StorageMethod: String, Codable {
        case roomTemperature = "ROOM_TEMPERATURE"
        case refrigerated = "REFRIGERATED"
        case frozen = "FROZEN"
    }
}

nonisolated extension IngredientItem.Category {
    var title: String {
        switch self {
        case .vegetable: "채소"
        case .mushroom: "버섯"
        case .meat: "육류"
        case .seafood: "수산"
        case .other: "기타"
        case .basic: "기본 재료"
        }
    }
}

nonisolated extension IngredientItem {
    // TODO: 한국어 이름 → 에셋 이름 매핑 (58종 이름 목록 받으면 채움)
    var imageName: String { IngredientImageMap.assetName(for: name) }

    // "삼겹살(수입)" → mainName "삼겹살", subName "수입" (괄호가 없으면 subName은 nil)
    var mainName: String {
        guard let open = name.firstIndex(of: "(") else { return name }
        return String(name[..<open])
    }
    var subName: String? {
        guard let open = name.firstIndex(of: "("),
              let close = name.lastIndex(of: ")"),
              open < close else { return nil }
        return String(name[name.index(after: open)..<close])
    }

    static let samples: [IngredientItem] = [
        .init(id: 1, name: "삼겹살", category: .meat, unit: "g", decimalPlaces: 0,
              managementType: .quantity, storageMethod: .refrigerated, storageDays: 5),
        .init(id: 2, name: "닭고기", category: .meat, unit: "g", decimalPlaces: 0,
              managementType: .quantity, storageMethod: .refrigerated, storageDays: 3),
        .init(id: 3, name: "팽이버섯", category: .mushroom, unit: "g", decimalPlaces: 0,
              managementType: .quantity, storageMethod: .refrigerated, storageDays: 7),
        .init(id: 4, name: "애호박", category: .vegetable, unit: "개", decimalPlaces: 1,
              managementType: .quantity, storageMethod: .refrigerated, storageDays: 7),
        .init(id: 5, name: "소금", category: .basic, unit: "g", decimalPlaces: 0,
              managementType: .presence, storageMethod: nil, storageDays: nil),
    ]
}
