//
//  ThisWeekRecipeEmptyView.swift
//  DosiRock
//
//  Created by Admin on 11/12/26.
//

import SwiftUI

//상태 2 . 재료 등록은 있지만 이번주 레시피 없을 때
struct ThisWeekRecipeEmptyView: View {

    let weekRangeText: String  // 예: "11월 9일~13일"

    var body: some View {

        ScrollView {
            VStack(alignment: .leading) {

                //이번주 기간
                Text(weekRangeText)
                    .appFont(.heading)
                    .foregroundStyle(Color.appTextPrimary)

                //재료 사용 우선 순위
                ingredientPriorityView
                // 이번주 먹고 싶은 재료 추가

                // 국물 메뉴 세그먼트

                //이번 주 메뉴 제안 받기 버튼
            }
            // 화면 폭 전체를 쓰게 해서, 툴팁처럼 내용 밖으로 그려지는 것이 잘리지 않게 함
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        .frame(
            maxWidth: .infinity,
            maxHeight: .infinity,
            alignment: .topLeading
        )

    }

    var ingredientPriorityView: some View {

        VStack {
            HStack {
                Text("thisweek_ingredient_priority")
                    .appFont(.heading)
                    .foregroundStyle(Color.appTextPrimary)

                // 누르면 툴팁이 보였다가 몇 초 뒤 저절로 사라짐 (상태 변수는 modifier 안에서 관리)
                Image("info")
                    .renderingMode(.template)  // 색을 입힐 수 있게 템플릿으로
                    .resizable()
                    .scaledToFit()
                    .frame(width: Size.Icon.medium)
                    .foregroundStyle(Color.appTextSecondary)
                    .appToolTip(
                        String(
                            localized: "thisweek_show_ingredientPriorityInfo"
                        )
                    )
                    .accessibilityAddTraits(.isButton)  //VoiceOver(화면 읽어주기)에게 버튼 선언
            }
            
             
            
        }

    }
}

#Preview {
    ThisWeekRecipeEmptyView(
        weekRangeText: "11월 9일~13일 도시락",
    )
    .padding()

}
