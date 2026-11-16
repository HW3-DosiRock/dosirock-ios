//
//  IngredientRegistrationViewModel.swift
//  DosiRock
//
//  Created by Admin on 11/16/26.
//

import Foundation

@Observable @MainActor
final class IngredientRegistrationViewModel {

    let selectedItem: IngredientItem

    //MARK: - 현재 소유 양
    var quantityText = ""
    var quantityError: String? {

        guard !quantityText.isEmpty else { return nil }  // 입력 전엔 오류 없음
        guard let value = Double(quantityText) else { return String(localized: "fridge_register_error_not_number") }
        guard value > 0 else { return String(localized: "fridge_register_error_not_positive") }

        // "." 기준으로 나누기: "150.55" → ["150", "55"]
        let parts = quantityText.split(
            separator: ".",
            omittingEmptySubsequences: false
        )
        let decimalCount = parts.count > 1 ? parts[1].count : 0

        if decimalCount > selectedItem.decimalPlaces {
            return selectedItem.decimalPlaces == 0
                ? String(localized: "fridge_register_error_integer_only")
                : String(
                    format: String(localized: "fridge_register_error_decimal_limit"),
                    selectedItem.decimalPlaces
                )
        }
        return nil
    }

    //MARK: 권장 사용일 입력
    var registeredAt = Date()  //오늘
    var recommendedOffset = 0  // 사용자가 < > 로 조정한 일수
    var recommendedDate: Date? {
        guard let days = selectedItem.storageDays else { return nil }
        return Calendar.current.date(
            byAdding: .day,
            value: days + recommendedOffset,
            to: registeredAt
        )
    }
    // 오늘부터 며칠 뒤인지 ("5일 안에")
    var daysUntilRecommended: Int? {
        guard let date = recommendedDate else { return nil }
        let cal = Calendar.current
        return cal.dateComponents(
            [.day],
            from: cal.startOfDay(for: registeredAt),
            to: cal.startOfDay(for: date)
        ).day
    }
    var canShiftEarlier: Bool { (daysUntilRecommended ?? 0) > 0 }  // 오늘보다 앞으론 못 감
    func shiftRecommended(by days: Int) { recommendedOffset += days }

    //MARK: 포장에 적힌 소비기한 입력 on/off
    var showsExpiryInput = false
    func toggleExpiryInput() {
        showsExpiryInput.toggle()
        expiryDate = showsExpiryInput ? Date() : nil  // 열면 오늘, 닫으면 값도 버림
    }

    //MARK: 포장에 적힌 소비기한 입력
    var expiryDate: Date?

    //MARK: INIT
    init(selectedItem: IngredientItem) {
        self.selectedItem = selectedItem
    }

    //MARK: 재료 저장
    var canSave: Bool {
        selectedItem.managementType == .presence  // 기본 재료는 수량 입력이 없음
            || (!quantityText.isEmpty && quantityError == nil)
    }

}
