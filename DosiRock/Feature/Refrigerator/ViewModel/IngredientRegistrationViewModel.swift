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

    // 이미 냉장고에 있는 수량 (처음 등록하는 재료는 nil)
    // TODO: 재고 API 명세가 나오면 InventoryItem의 수량에서 가져온다
    let previousQuantity: Double?

    // 이미 냉장고에 있는 재료인지 (기본 재료는 수량이 없어서 previousQuantity만으로는 알 수 없음)
    let isExisting: Bool

    // "지금 4개 → 14개 변경" (이미 등록된 재료이고, 입력이 올바르고, 값을 바꿨을 때만)
    var changeSummary: String? {
        guard let previous = previousQuantity,
              let current = Double(quantityText),
              quantityError == nil,
              current != previous else { return nil }
        return String(
            format: String(localized: "fridge_register_change_summary"),
            plain(previous) + selectedItem.unit,
            plain(current) + selectedItem.unit
        )
    }

    // 저장할 수량 (기본 재료는 수량이 없으므로 nil)
    var quantity: Double? {
        selectedItem.managementType == .quantity ? Double(quantityText) : nil
    }

    // 4 → "4", 4.5 → "4.5" (소수 자릿수는 재료의 decimalPlaces까지만, 천 단위 쉼표 없음)
    private func plain(_ value: Double) -> String {
        value.formatted(
            .number.grouping(.never)
                .precision(.fractionLength(0...selectedItem.decimalPlaces))
        )
    }
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
    init(
        selectedItem: IngredientItem,
        previousQuantity: Double? = nil,
        isExisting: Bool? = nil
    ) {
        self.selectedItem = selectedItem
        self.previousQuantity = previousQuantity
        self.isExisting = isExisting ?? (previousQuantity != nil)
        // 이미 있는 재료는 저장해 둔 수량을 입력칸에 미리 채움
        if let previousQuantity { quantityText = plain(previousQuantity) }
    }

    //MARK: 재료 저장
    var canSave: Bool {
        selectedItem.managementType == .presence  // 기본 재료는 수량 입력이 없음
            || (!quantityText.isEmpty && quantityError == nil)
    }

}
