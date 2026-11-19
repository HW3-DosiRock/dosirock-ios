//
//  AddIngredientSheet.swift
//  DosiRock
//
//  Created by Seungyeon Jeon on 11/15/26.
//

import SwiftUI

struct AddIngredientSheet: View {

    @Environment(\.dismiss) private var dismiss
    @State private var vm: IngredientPickerViewModel
    let refrigerVm: RefrigeratorViewModel
    @State private var selectedItem: IngredientItem?  // 눌린 재료 (두 번째 시트용)

    init(
        refrigerVm: RefrigeratorViewModel,
        vm: IngredientPickerViewModel
    ) {
        self.refrigerVm = refrigerVm
        _vm = State(
            initialValue: vm
        )
    }
    var body: some View {

        VStack(spacing: 0) {
            NavigationHeader(
                title: "fridge_picker_title",
                leadingTitle: "common_close",
                showsBackIcon: false,
                titleStyle: .heading,
                onLeadingTap: { dismiss() }
            )

            // 체크 = 냉장고에 등록된 재료, 누르면 수량 입력 시트
            IngredientPickerContent(
                vm: vm,
                isChecked: { refrigerVm.isRegistered($0) },
                onTap: { selectedItem = $0 }
            )
        }
        .background(Color.appBackground)
        .presentationDragIndicator(.visible)
        .presentationCornerRadius(Radius.xLarge)
        .modifier(PageSheetSizing())
        .sheet(item: $selectedItem) { item in
            IngredientRegistrationSheet(
                ingredient: item,
                refrigerVm: refrigerVm,
                previousQuantity: refrigerVm.quantity(of: item),
                previousExpirationDate: refrigerVm.expirationDate(of: item),
                isExisting: refrigerVm.isRegistered(item)
            )
        }
    }

}

#if DEBUG
    // 프리뷰는 실제 서버 대신 샘플 데이터를 쓴다 (vm을 안 넘기면 서버에 요청해서 프리뷰에서는 실패함)
    #Preview {
        AddIngredientSheet(
            refrigerVm: RefrigeratorViewModel(
                inventory: PreviewInventoryRepository(),
                ingredientRepository: PreviewIngredientRepository()
            ),
            vm: IngredientPickerViewModel(
                repository: PreviewIngredientRepository(scenario: .filled)
            )
        )
    }
#endif

// iPad에서 시트가 가운데 작은 카드로 뜨지 않고 화면을 크게 채우게 함 (iOS 18+, 17은 기본 동작)
struct PageSheetSizing: ViewModifier {
    func body(content: Content) -> some View {
        if #available(iOS 18, *) {
            content.presentationSizing(.page)
        } else {
            content
        }
    }
}

// iPad에서 시트가 내용 크기만큼만 뜨게 함 (내용이 짧은 시트용, iOS 18+, 17은 기본 동작)
struct FittedSheetSizing: ViewModifier {
    func body(content: Content) -> some View {
        if #available(iOS 18, *) {
            content.presentationSizing(.fitted)
        } else {
            content
        }
    }
}
