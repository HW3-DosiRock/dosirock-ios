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
    // 구매한 재료 저장 (서버 저장 + 이번 주 데이터 새로고침은 부르는 쪽 ViewModel이 함)
    var onRegisterBought: (_ amounts: [Int: Double], _ bought: Set<Int>) async throws -> Void = { _, _ in }

    @State private var showsBoughtSheet = false
    @State private var didRegister = false  // 저장 성공 → 시트가 닫힌 뒤 이 화면도 닫기

    var body: some View {

        VStack(spacing: 0) {

            NavigationHeader(
                title: .thisweekShortageNavTitle,
                leadingTitle: .thisweekShortageBack,
                titleStyle: .brandSubtitle,
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
                showsBoughtSheet = true
            }
        }
        .padding(Spacing.screenHorizontal)
        .background(Color.appBackground.ignoresSafeArea())
        .navigationBarBackButtonHidden(true)  // 기본 뒤로 버튼 대신 NavigationHeader (스와이프 뒤로가기는 동작)
        // 시트가 완전히 내려간 뒤에 이 화면을 닫음 (시트와 화면을 동시에 닫으면 전환이 꼬일 수 있음)
        .sheet(isPresented: $showsBoughtSheet, onDismiss: {
            if didRegister { router.pop() }
        }) {
            BoughtListSheet(shortages: shortages) { amounts, bought in
                try await onRegisterBought(amounts, bought)
                didRegister = true
            }
        }
    }

    // 재료 한 칸: 아이콘 · 이름 · 쓰는 메뉴(최대 2줄) · "220g 부족"
    private func shortageCard(_ item: Shortage) -> some View {
        ListRow(
            iconCodes: [item.imageName],
            title: item.name,
            subtitle: item.menuNames.joined(separator: " · "),
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
}

#if DEBUG
    #Preview {
        ShortageListView(shortages: PreviewMealRepository.sampleShortages)
            .environment(Router<ThisWeekRoute>())
    }
#endif
