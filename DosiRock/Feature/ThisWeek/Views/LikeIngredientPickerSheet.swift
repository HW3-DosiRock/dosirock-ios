//
//  LikeIngredientPickerSheet.swift
//  DosiRock
//
//  Created by Seungyeon Jeon on 11/18/26.
//

import SwiftUI

// 이번 주 먹고 싶은 재료 고르기 시트. 누르면 체크만 켜고 끈다 (냉장고 등록과 무관)
struct LikeIngredientPickerSheet: View {

    @Environment(\.dismiss) private var dismiss
    @State private var vm: IngredientPickerViewModel
    @Binding var selected: [IngredientItem]  // 고른 순서대로

    init(vm: IngredientPickerViewModel, selected: Binding<[IngredientItem]>) {
        _vm = State(initialValue: vm)
        _selected = selected
    }

    var body: some View {
        VStack(spacing: 0) {
            NavigationHeader(
                title: .fridgePickerTitle,
                leadingTitle: .commonClose,
                showsBackIcon: false,
                titleStyle: .heading,
                onLeadingTap: { dismiss() }
            )

            IngredientPickerContent(
                vm: vm,
                isChecked: { item in selected.contains { $0.id == item.id } },
                onTap: { item in
                    // 이미 골랐으면 빼고, 아니면 맨 뒤에 추가
                    if selected.contains(where: { $0.id == item.id }) {
                        selected.removeAll { $0.id == item.id }
                    } else {
                        selected.append(item)
                    }
                }
            )
        }
        .background(Color.appBackground)
        .presentationDragIndicator(.visible)
        .presentationCornerRadius(Radius.xLarge)
        .modifier(PageSheetSizing())
    }
}

#if DEBUG
    #Preview {
        @Previewable @State var selected: [IngredientItem] = []
        LikeIngredientPickerSheet(
            vm: IngredientPickerViewModel(
                repository: PreviewIngredientRepository(scenario: .filled)
            ),
            selected: $selected
        )
    }
#endif
