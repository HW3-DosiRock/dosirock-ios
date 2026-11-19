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
            current > 0,
            quantityError == nil,
            current != previous
        else { return nil }
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

    var isDeletingByZero: Bool {
        isExisting && quantity == 0
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
        guard let value = Double(quantityText) else {
            return String(localized: "fridge_register_error_not_number")
        }
        // 이미 있는 재료는 0 허용 (0 = 삭제), 처음 등록은 0보다 커야 함
        guard isExisting ? value >= 0 : value > 0 else {
            return String(localized: "fridge_register_error_not_positive")
        }

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
                    format: String(
                        localized: "fridge_register_error_decimal_limit"
                    ),
                    selectedItem.decimalPlaces
                )
        }
        return nil
    }

    //MARK: 소비기한 (기본값: 오늘 + 보관 일수, 기본 재료는 nil)
    var expirationDate: Date?

    //MARK: INIT
    init(
        selectedItem: IngredientItem,
        previousQuantity: Double? = nil,
        previousExpirationDate: Date? = nil,
        isExisting: Bool? = nil
    ) {
        self.selectedItem = selectedItem
        self.previousQuantity = previousQuantity
        self.isExisting = isExisting ?? (previousQuantity != nil)
        // 이미 있는 재료는 저장해 둔 수량을 입력칸에 미리 채움
        if let previousQuantity { quantityText = plain(previousQuantity) }
        // 이미 있는 재료는 저장해 둔 소비기한, 처음이면 권장일(오늘 + 보관 일수)
        expirationDate =
            previousExpirationDate
            ?? selectedItem.storageDays.flatMap {
                Calendar.current.date(byAdding: .day, value: $0, to: Date())
            }
    }

    //MARK: 재료 저장
    var canSave: Bool {
        selectedItem.managementType == .presence  // 기본 재료는 수량 입력이 없음
            || (!quantityText.isEmpty && quantityError == nil
                && expirationDate != nil)
    }

}
