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
            
            Spacer()

            // TODO: 버튼 문구와 동작은 기획에 맞게 교체 (지금은 다른 화면에서 복사해 온 자리 표시)
            BottomActionBar(title: "다음") {}

        }
        .padding(Spacing.screenHorizontal)  // BottomActionBar는 이 여백이 있다고 가정함
        .frame(maxWidth: .infinity , maxHeight: .infinity)
        .background(Color.appBackground)
    }
}

#Preview {
    ThisWeekEmptyIngredientView()
}
