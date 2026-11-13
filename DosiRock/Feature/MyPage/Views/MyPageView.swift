//
//  MyPageView.swift
//  DosiRock
//
//  Created by Admin on 11/12/26.
//

import SwiftUI

// 마이페이지 탭 (임시 화면)
struct MyPageView: View {

    var body: some View {

        // 화면이 크면 남는 공간을 섹션 사이에 고르게 나누고, 작으면 스크롤되게 한다
        GeometryReader { geo in

            ScrollView {

                VStack(alignment: .leading, spacing: 0) {

                    SectionHeader(title: "tab_my_page", titleStyle: .brandTitle)

                    Spacer(minLength: Spacing.xl)  // 최소 간격 xl, 남는 공간은 Spacer끼리 똑같이 나눠 가짐

                    //프로필
                    profile

                    Spacer(minLength: Spacing.xl)

                    // 예상 절약액
                    summary
                        .zIndex(1)  // 툴팁이 아래 섹션에 가려지지 않게

                    Spacer(minLength: Spacing.xl)

                    // 설정
                    settingSection

                    Spacer(minLength: Spacing.xl)

                    //안내
                    infoSection

                    Spacer(minLength: Spacing.xl)

                    // 로그아웃 · 탈퇴
                    bottomActions

                }
                .frame(maxWidth: .infinity, alignment: .topLeading)
                .padding(Spacing.screenHorizontal)
                .frame(minHeight: geo.size.height)  // 내용이 화면보다 작을 땐 화면 높이만큼 채움 (크면 스크롤)
            }
        }

    }

    var profile: some View {

        HStack(spacing: Spacing.l) {

            Image("logo-stone")
                .resizable()
                .scaledToFit()
                .frame(width: 72)

            VStack(alignment: .leading, spacing: 0) {
                Text("닉네임")
                    .appFont(.brandSubtitle)
                Text("이메일")
                    .appFont(.caption)
                    .foregroundColor(.appTextSecondary)
            }

            Spacer()

            Image("settings")
                .resizable()
                .scaledToFit()
                .frame(width: Size.Icon.large)
                .padding(.trailing, Spacing.l)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(Spacing.l)
        .clipShape(RoundedRectangle(cornerRadius: Radius.large))
        .background(
            Color.appSurface,
            in: RoundedRectangle(cornerRadius: Radius.large)
        )
        .overlay(
            RoundedRectangle(cornerRadius: Radius.large)
                .stroke(Color.appBorder)
        )
        .contentShape(Rectangle())

    }

    // MARK: - 예상 절약액

    // 임시 값: 월, 조리 완료 횟수, 예상 절약액은 서버 값으로 교체
    var summary: some View {

        VStack(alignment: .leading, spacing: Spacing.s) {

            Text("11월")
                .appFont(.subbody)
                .foregroundStyle(Color.appTextSecondary)

            HStack(alignment: .top) {

                VStack(alignment: .leading, spacing: 0) {
                    Text("조리 완료")
                        .appFont(.subbody)
                        .foregroundStyle(Color.appTextSecondary)
                    Text(
                        String(
                            format: String(localized: "my_menu_complete_count"),
                            4
                        )
                    )
                    .appFont(.brandEmphasis)
                    .foregroundStyle(Color.appTextPrimary)
                }

                Spacer()

                VStack(alignment: .leading, spacing: 0) {
                    HStack(spacing: Spacing.xs) {
                        Text("예상 절약액")
                            .appFont(.subbody)
                            .foregroundStyle(Color.appTextSecondary)

                        // TODO: feat/this-week가 dev에 머지되면 아래 줄 추가 (누르면 툴팁이 보였다가 사라짐)
                        //   .appToolTip(String(localized: "my_menu_saving_tip"))
                        //   .accessibilityAddTraits(.isButton)
                        Image("info")
                            .renderingMode(.template)
                            .resizable()
                            .scaledToFit()
                            .frame(width: Size.Icon.medium)
                            .foregroundStyle(Color.appTextSecondary)
                    }
                    Text(won(30774))
                        .appFont(.brandEmphasis)
                        .foregroundStyle(Color.appSuccess)
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(Spacing.l)
            .background(
                Color.appSurface,
                in: RoundedRectangle(cornerRadius: Radius.large)
            )
            .overlay(
                RoundedRectangle(cornerRadius: Radius.large)
                    .stroke(Color.appBorder)
            )
        }
    }

    // MARK: - 설정 · 안내

    private struct MenuItem: Identifiable {
        let id: String
        let title: LocalizedStringKey
        var trailing: String? = nil  // 오른쪽에 보여줄 값 (없으면 화살표만)
        var trailingStyle: AppTypography = .caption
    }

    var settingSection: some View {
        VStack(alignment: .leading, spacing: Spacing.m) {
            SectionHeader(title: "설정")
            GroupedListCard(
                items: [
                    // 임시 값: 외식 기준 금액은 서버 값으로 교체
                    MenuItem(
                        id: "diningOut",
                        title: "my_eat_out_title",
                        trailing: won(12000),
                        trailingStyle: .heading
                    )
                ]
            ) { menuRow($0) }
        }
    }

    var infoSection: some View {
        VStack(alignment: .leading, spacing: Spacing.m) {
            SectionHeader(title: "안내")
            GroupedListCard(
                items: [
                    MenuItem(id: "privacy", title: "my_menu_privacy"),
                    MenuItem(id: "priceInfo", title: "my_menu_price_info"),
                    // 임시 값: 앱 버전은 번들 정보로 교체
                    MenuItem(
                        id: "appInfo",
                        title: "my_menu_app_info",
                        trailing: "0.2 프로토타입"
                    ),
                ]
            ) { menuRow($0) }
        }
    }

    private func menuRow(_ item: MenuItem) -> some View {
        HStack {
            Text(item.title)
                .appFont(.body)
                .foregroundStyle(Color.appTextPrimary)

            Spacer()

            if let trailing = item.trailing {
                Text(trailing)
                    .appFont(item.trailingStyle)
                    .foregroundStyle(
                        item.trailingStyle == .caption
                            ? Color.appTextSecondary : Color.appTextPrimary
                    )
            }

            Image("chevron-right")
                .renderingMode(.template)
                .resizable()
                .scaledToFit()
                .frame(width: Size.Icon.medium, height: Size.Icon.medium)
                .foregroundStyle(Color.appDisabled)
                .accessibilityHidden(true)
        }
    }

    // MARK: - 로그아웃 · 탈퇴

    var bottomActions: some View {
        HStack(spacing: Spacing.xl) {
            Text("my_menu_logout")
                .foregroundStyle(Color.appTextSecondary)
            Text("my_menu_withdraw")
                .foregroundStyle(Color.appAttention)
        }
        .appFont(.subbody)
        .frame(maxWidth: .infinity)
    }

    // 12000 → "12,000원"
    private func won(_ value: Int) -> String {
        String(
            format: String(localized: "common_won_format"),
            value.formatted()
        )
    }
}

#Preview {
    MyPageView()
        .padding(Spacing.screenHorizontal)

}
