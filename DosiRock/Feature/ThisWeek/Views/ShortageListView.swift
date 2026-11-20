//
//  ShortageListView.swift
//  DosiRock
//
//  Created by Admin on 11/20/26.
//

import SwiftUI

// W-03 추가로 필요한 재료: 이번 주 계획에서 부족한 재료와, 그 재료를 쓰는 메뉴
struct ShortageListView: View {

    @Environment(Router<ThisWeekRoute>.self) private var router

    let shortages: [Shortage]
    let days: [MealPlanDay]  // 재료마다 "어느 메뉴에 쓰이는지"를 찾는 데 씀

    var body: some View {

        VStack(spacing: 0) {

            NavigationHeader(
                title: .thisweekShortageNavTitle,
                leadingTitle: .thisweekShortageBack,
                titleStyle: .heading,
                onLeadingTap: { router.pop() }
            )

            ScrollView {
                VStack(spacing: Spacing.m) {
                    ForEach(shortages, id: \.ingredientId) { item in
                        shortageCard(item)
                    }
                }
                .frame(maxWidth: .infinity, alignment: .topLeading)
                .padding(Spacing.screenHorizontal)
 
            }
            
            BottomActionBar(
                title: .thisweekShortageRegister,
            ) {
                //TODO: TASK 
            }
        }
        .background(Color.appBackground.ignoresSafeArea())
        .navigationBarBackButtonHidden(true)  // 기본 뒤로 버튼 대신 NavigationHeader (스와이프 뒤로가기는 동작)
    }

    // 재료 한 칸: 아이콘 · 이름 · 쓰는 메뉴(최대 2줄) · "220g 부족"
    private func shortageCard(_ item: Shortage) -> some View {
        ListRow(
            iconCodes: [item.imageName],
            title: item.name,
            subtitle: menuNames(using: item),
            badgePlacement: .trailing,
            showsChevron: false,
            subtitleLineLimit: 2
        ) {
            RecipeBadge(
                type: .needMore,
                title: LocalizedStringKey(
                    String(
                        format: String(localized: "thisweek_shortage_lack_amount"),
                        item.amountText
                    )
                )
            )
        }
        // TODO: 참고 시세 줄 (서버에 시세 필드가 생기면 여기 아래에)
        .padding(Spacing.l)
        .background(
            RoundedRectangle(cornerRadius: Radius.large).fill(Color.appSurface)
        )
        .overlay(
            RoundedRectangle(cornerRadius: Radius.large).stroke(Color.appBorder)
        )
    }

    // 이 재료를 쓰는 메뉴 이름 (요일 순, 같은 메뉴는 한 번만): "닭고기 채소볶음 · 닭고기 채소덮밥"
    private func menuNames(using item: Shortage) -> String {
        var names: [String] = []
        for menu in days.flatMap(\.menus)
        where menu.ingredients.contains(where: { $0.ingredientId == item.ingredientId })
            && !names.contains(menu.name)
        {
            names.append(menu.name)
        }
        return names.joined(separator: " · ")
    }
}

#if DEBUG
    #Preview {
        let plan = PreviewMealRepository.samplePlan
        ShortageListView(shortages: plan.shortages, days: plan.days)
            .environment(Router<ThisWeekRoute>())
    }
#endif
