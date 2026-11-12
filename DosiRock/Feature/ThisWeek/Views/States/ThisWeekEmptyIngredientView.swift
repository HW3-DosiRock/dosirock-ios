//
//  ThisWeekEmptyIngredientView.swift
//  DosiRock
//
//  Created by Admin on 11/12/26.
//

import SwiftUI

// 상태 1 . 재료 등록이 없을 때 (초기)
struct ThisWeekEmptyIngredientView: View {
    var body: some View {
        VStack{
            Image("logo-stone")
                .resizable()
                .scaledToFit()
                .frame(width: 104)
                .padding(.bottom, Spacing.xs)

            Text("thisweek_empty_desc")
                .appFont(.brandSubtitle)
                .multilineTextAlignment(.center)  // 여러 줄일 때 가운데 정렬
        }
        .frame(maxWidth: .infinity , maxHeight: .infinity)
        .background(Color.appBackground)
    }
}

#Preview {
    ThisWeekEmptyIngredientView()
}
