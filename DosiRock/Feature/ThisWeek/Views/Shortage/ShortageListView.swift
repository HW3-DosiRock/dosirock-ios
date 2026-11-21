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
    @Environment(\.openURL) private var openURL
    @Environment(\.scenePhase) private var scenePhase

    let shortages: [Shortage]
    // 구매한 재료 저장 (서버 저장 + 이번 주 데이터 새로고침은 부르는 쪽 ViewModel이 함)
    var onRegisterBought:
        (_ amounts: [Int: Double], _ bought: Set<Int>) async throws -> Void = {
            _,
            _ in
        }

    @State private var showsBoughtSheet = false
    @State private var didRegister = false  // 저장 성공 → 시트가 닫힌 뒤 이 화면도 닫기
    @State private var didOpenCoupang = false  // 쿠팡 링크를 열었는지 (앱으로 돌아오면 등록 안내)
    @State private var showsRegisterBanner = false  // 쿠팡에서 돌아온 뒤 "산 양을 등록해 주세요" 안내

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
                    if showsRegisterBanner {
                        AppBanner(
                            type: .info,
                            message: String(localized: "thisweek_shortage_register_banner"),
                            actionMessage: .thisweekShortageRegister
                        ) {
                            showsBoughtSheet = true
                        }
                    }
                    ForEach(shortages, id: \.ingredientId) { item in
                        shortageCard(item)
                    }
                    purchaseSection
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
        // 쿠팡 링크를 열었다가 앱으로 돌아오면 등록 안내 (링크를 열지 않고 나갔다 온 경우는 제외)
        .onChange(of: scenePhase) { _, phase in
            if phase == .active, didOpenCoupang {
                showsRegisterBanner = true
                didOpenCoupang = false
            }
        }
        .navigationBarBackButtonHidden(true)  // 기본 뒤로 버튼 대신 NavigationHeader (스와이프 뒤로가기는 동작)
        // 시트가 완전히 내려간 뒤에 이 화면을 닫음 (시트와 화면을 동시에 닫으면 전환이 꼬일 수 있음)
        .sheet(
            isPresented: $showsBoughtSheet,
            onDismiss: {
                if didRegister { router.pop() }
            }
        ) {
            BoughtListSheet(shortages: shortages) { amounts, bought in
                try await onRegisterBought(amounts, bought)
                didRegister = true
                showsRegisterBanner = false
            }
        }
    }

    // 구매 링크 (쿠팡 파트너스 광고): 링크가 등록된 재료만, 하나도 없으면 섹션 전체 숨김
    @ViewBuilder
    private var purchaseSection: some View {
        let linked = shortages.compactMap { item in
            item.purchaseUrl.flatMap(URL.init(string:)).map { (item, $0) }
        }
        if !linked.isEmpty {
            VStack(alignment: .leading, spacing: Spacing.m) {

                HStack {
                    Text(.thisweekShortageBuyTitle)
                        .appFont(.heading)
                        .foregroundStyle(Color.appTextPrimary)
                    Spacer()
                    Text(.thisweekShortageBuyOptional)
                        .appFont(.subbody)
                        .foregroundStyle(Color.appTextSecondary)
                }

                // 쿠팡 파트너스 안내
                HStack(alignment: .top, spacing: Spacing.s) {
                    AppIcon(.info, size: Size.Icon.small)
                        .foregroundStyle(Color.appTextSecondary)
                        .padding(.top, 2)
                    Text(.thisweekShortageBuyNotice)
                        .appFont(.subbody)
                        .foregroundStyle(Color.appTextSecondary)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .fixedSize(horizontal: false, vertical: true)
                }
                .padding(Spacing.m)
                .background(
                    RoundedRectangle(cornerRadius: Radius.medium).fill(Color.appSurfaceSubtle)
                )

                VStack(spacing: 0) {
                    ForEach(Array(linked.enumerated()), id: \.element.0.ingredientId) { index, entry in
                        let (item, url) = entry
                        if index > 0 { Divider().overlay(Color.appBorder) }
                        HStack(spacing: Spacing.m) {
                            IngredientImage(code: item.imageName, size: Size.Icon.medium)
                                .accessibilityHidden(true)
                            Text(item.name)
                                .appFont(.body)
                                .foregroundStyle(Color.appTextPrimary)
                            Spacer()
                            Button {
                                openURL(url)
                                didOpenCoupang = true
                            } label: {
                                HStack(spacing: Spacing.s) {
                                    Text(.thisweekShortageBuyLink)
                                        .appFont(.heading)
                                    AppIcon(.externalLink, size: Size.Icon.small)
                                }
                                .foregroundStyle(Color.appTextPrimary)
                                .padding(.horizontal, Spacing.l)
                                .frame(minHeight: Size.minTouch)
                                .background(
                                    RoundedRectangle(cornerRadius: Radius.medium)
                                        .fill(Color.appSurfaceSubtle)
                                )
                                .contentShape(Rectangle())
                            }
                            .buttonStyle(.plain)
                        }
                        .padding(.horizontal, Spacing.l)
                        .padding(.vertical, Spacing.s)
                    }
                }
                .background(
                    RoundedRectangle(cornerRadius: Radius.large).fill(Color.appSurface)
                )
                .overlay(
                    RoundedRectangle(cornerRadius: Radius.large).stroke(Color.appBorder)
                )
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.top, Spacing.m)
        }
    }

    // 재료 한 칸: 아이콘 · 이름 · 쓰는 메뉴(최대 2줄) · "220g 부족"
    private func shortageCard(_ item: Shortage) -> some View {
        VStack(alignment: .leading, spacing: Spacing.s) {
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
                        item.isPresence
                            ? String(
                                format: String(localized: "thisweek_shortage_none")
                            )
                            : String(
                                format: String(localized: "thisweek_shortage_lack_amount"),
                                item.amountText
                            )

                    )
                )
            }

            // 참고 시세 (아이콘 너비만큼 들여써서 메뉴 이름과 줄을 맞춤)
            if let priceText = item.priceText {
                Text(priceText)
                    .appFont(.caption)
                    .foregroundStyle(Color.appTextSecondary)
                    .padding(.leading, Size.Icon.large + Spacing.xl)
            }
        }
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
