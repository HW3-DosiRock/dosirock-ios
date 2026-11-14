//
//  DiningOutCostViewModel.swift
//  DosiRock
//

import Foundation

@Observable @MainActor
final class DiningOutCostViewModel {

    static let defaultCost = 12000
    static let range = 1000...100000

    private let users: UserRepository
    private let original: Int

    var text: String
    var isSaving = false
    var errorMessage: String?  // 저장 요청 실패 문구

    init(users: UserRepository, cost: Int) {
        self.users = users
        original = cost
        text = String(cost)
    }

    private var cost: Int? { Int(text) }

    var error: String? {
        if text.isEmpty { return String(localized: "my_eat_out_empty") }
        guard let cost else { return String(localized: "my_eat_out_not_number") }
        if cost <= 0 { return String(localized: "my_eat_out_not_positive") }
        if !Self.range.contains(cost) { return String(localized: "my_eat_out_range") }
        return nil
    }

    var canSave: Bool { error == nil && cost != original && !isSaving }

    func useDefault() { text = String(Self.defaultCost) }

    // 성공하면 저장된 금액을 돌려줌
    func save() async -> Int? {
        guard canSave, let cost else { return nil }
        isSaving = true
        errorMessage = nil
        defer { isSaving = false }
        do {
            try await users.updateDiningOutCost(cost)
            return cost
        } catch {
            errorMessage =
                (error as? AuthError)?.errorDescription
                ?? String(localized: "common_save_failed")
            return nil
        }
    }
}
