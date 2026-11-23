//
//  MyPageView.swift
//  DosiRock
//
//  Created by Admin on 11/12/26.
//

import SwiftUI

// 마이페이지 탭
struct MyPageView: View {
    
    @Environment(\.container) private var container
    
    @State private var vm: MyPageViewModel
    @State private var router = Router<MyPageRoute>()
    @State private var viewportHeight: CGFloat = 0
    @State private var toast: LocalizedStringResource?

    init(vm: MyPageViewModel) {
        _vm = State(initialValue: vm)
    }

    var body: some View {

        NavigationStack(path: $router.path) {
            Group {
                switch vm.state {
                case .loading:
                    TabSkeletonView()
                        .padding(Spacing.screenHorizontal)
                case .failed:
                    failedView
                case .loaded(let profile):
                    content(profile)
                }
            }
            // 응답이 빠르면 스켈레톤이 순간 교체돼 깜빡여 보여서 페이드로 넘김 (프로필만 바뀔 땐 애니메이션 안 함)
            .animation(.easeInOut(duration: 0.25), value: isLoading)
            // NavigationStack이 자기 흰 배경을 칠해서, 바깥(MainTabView)의 배경이 안 보임 → 여기서 직접 칠함
            .background(Color.appBackground.ignoresSafeArea())
            .navigationDestination(for: MyPageRoute.self) { route in
                switch route {
                case .profileEdit:
                    if let profile = vm.profile {
                        ProfileEditView(
                            vm: ProfileEditViewModel(
                                users: vm.users,
                                profile: profile
                            ),
                            onSaved: {
                                vm.applyNickname($0)
                                toast = .myProfileSavedToast
                            }
                        )
                    }
                case .passwordChange:
                    PasswordChangeView(
                        vm: PasswordChangeViewModel(users: vm.users),
                        onChanged: { toast = .myPasswordChangedToast }
                    )
                case .findPassword:
                    findPasswordView
                case .priceInfo: PriceInfoView()
                case .appInfo: AppInfoView()
                case .privacyPolicy:
                    if let doc = TermDocument.privacyPolicy {
                        TermDocumentView(document: doc, backTitle: .tabMyPage)
                    }
                case .storageGuide:
                    if let doc = TermDocument.recommendedUseGuide {
                        TermDocumentView(document: doc, backTitle: .tabMyPage)
                    }
                case .diningOutCost:
                    if let profile = vm.profile {
                        DiningOutCostView(
                            vm: DiningOutCostViewModel(
                                users: vm.users,
                                cost: profile.diningOutCost
                            ),
                            onSaved: {
                                vm.applyDiningOutCost($0)
                                toast = .myEatOutSavedToast($0.formatted())
                            }
                        )
                    }
                }
            }
        }
        .environment(router)
        .toast($toast)
        // 탈퇴 완료: 토큰은 "확인"을 누를 때 지워서, 그 전에는 로그인 화면으로 넘어가지 않음
        .fullScreenCover(isPresented: $vm.showsWithdrawDone) {
            WithdrawCompleteView { SessionStore.shared.expire(message: nil) }
        }
        // task와 대화상자는 NavigationStack 바깥에 둔다 (안쪽에 두면 뒤로 돌아올 때마다 다시 실행/가려짐)
        .task { await vm.load() }
        .appDialog(
            isPresented: $vm.showLogoutDialog,
            title: .dialogLogoutTitle,
            message: "",
            cancelTitle: .commonCancel,
            confirmTitle: .dialogLogoutConfirm,
            onConfirm: { Task { await vm.logout() } }
        )
        .appDialog(
            isPresented: $vm.showWithdrawDialog,
            title: .dialogWithdrawTitle,
            message: .dialogWithdrawMessage,
            cancelTitle: .commonCancel,
            confirmTitle: .dialogWithdrawConfirm,
            onConfirm: {
                Task {
                    if await vm.withdraw() {
                        vm.showsWithdrawDone = true
                    } else {
                        toast = .myWithdrawFailed
                    }
                }
            }
        )
    }

    private var isLoading: Bool {
        if case .loading = vm.state { return true }
        return false
    }

    // 현재 비밀번호를 모를 때: 이메일 인증으로 재설정 (로그인 전 '비밀번호 찾기'와 같은 화면)
    private var findPasswordView: some View {
        let reset = FoundPasswordViewModel(
            service: container.auth
        )
        reset.onCompleted = {
            router.pop()  // 비밀번호 재설정 화면
            router.pop()  // 프로필 수정 화면
            toast = .findPasswordToastCompleted
        }
        return FoundPasswordView(
            vm: reset,
            leadingTitle: .myPasswordTitle,
            onBack: { router.pop() }
        )
    }

    // 서버에서 불러온 정보
    func content(_ profile: UserProfile) -> some View {

        // 화면이 크면 남는 공간을 섹션 사이에 고르게 나누고, 작으면 스크롤되게 한다
        GeometryReader { geo in

            ScrollView {

                VStack(alignment: .leading, spacing: 0) {

                    SectionHeader(title: .tabMyPage, titleStyle: .brandTitle)

                    Spacer(minLength: Spacing.xl)  // 최소 간격 xl, 남는 공간은 Spacer끼리 똑같이 나눠 가짐

                    //프로필
                    profileCard(profile)

                    Spacer(minLength: Spacing.xl)

                    // 예상 절약액
                    summary

                    Spacer(minLength: Spacing.xl)

                    // 설정
                    settingSection(profile)

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

    // 불러오기 실패 화면
    var failedView: some View {
        LoadFailedView(title: .myLoadFailedTitle) {
            Task { await vm.load() }
        }
        .padding(Spacing.screenHorizontal)
    }

    func profileCard(_ profile: UserProfile) -> some View {

        HStack(spacing: Spacing.l) {

            Image(.logoStone)
                .resizable()
                .scaledToFit()
                .frame(width: 72)

            VStack(alignment: .leading, spacing: 0) {
                Text(
                    String(
                        format: String(localized: "my_profile_name"),
                        profile.nickname
                    )
                )
                .appFont(.brandSubtitle)
                Text(profile.email)
                    .appFont(.caption)
                    .foregroundColor(.appTextSecondary)
            }

            Spacer()

            Button {
                router.push(.profileEdit)
            } label: {
                AppIcon(.settings, size: Size.Icon.large)
                    .foregroundStyle(Color.appTextPrimary)
            }
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

    var summary: some View {

        VStack(alignment: .leading, spacing: Spacing.s) {

            Text(vm.monthText)
                .appFont(.subbody)
                .foregroundStyle(Color.appTextSecondary)

            HStack(alignment: .top) {

                VStack(alignment: .leading, spacing: 0) {
                    Text(.myMenuCompleteSubtitle)
                        .appFont(.subbody)
                        .foregroundStyle(Color.appTextSecondary)
                    Text(vm.completedText)
                    .appFont(.brandEmphasis)
                    .foregroundStyle(Color.appTextPrimary)
                }

                Spacer()

                VStack(alignment: .leading, spacing: 0) {
                    HStack(spacing: Spacing.xs) {
                        Text(.myMenuCompletePrice)
                            .appFont(.subbody)
                            .foregroundStyle(Color.appTextSecondary)

                        AppIcon(.info, decorative: false)
                            .foregroundStyle(Color.appTextSecondary)
                            .appToolTip(.myMenuSavingTip)
                            .accessibilityAddTraits(.isButton)  //VoiceOver(화면 읽어주기)에게 버튼 선언
                    }
                    .zIndex(1)  // 툴팁이 바로 아래 금액 글자 위에 그려지게
                    Text(vm.savingText)
                        .appFont(.brandEmphasis)
                        .foregroundStyle(Color.appSuccess)
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(Spacing.l)
            .background {
                RoundedRectangle(cornerRadius: Radius.large).fill(
                    Color.appSurface
                )
                //테두리 최상단으로 오버레이 하면 툴팁위로 테두리 그려져서 백그라운드에 같이 그리게 위치 변경함
                RoundedRectangle(cornerRadius: Radius.large).stroke(
                    Color.appBorder
                )
            }

        }
    }

    // MARK: - 설정 · 안내

    private struct MenuItem: Identifiable {
        let id: String
        let title: LocalizedStringResource
        var trailing: String? = nil  // 오른쪽에 보여줄 값 (없으면 화살표만)
        var trailingStyle: AppTypography = .caption
    }

    func settingSection(_ profile: UserProfile) -> some View {
        VStack(alignment: .leading, spacing: Spacing.m) {
            SectionHeader(title: .myMenuSetting)
            GroupedListCard(
                items: [
                    MenuItem(
                        id: "diningOut",
                        title: .myEatOutTitle,
                        trailing: won(profile.diningOutCost),
                        trailingStyle: .heading
                    )
                ]
            ) { item in
                Button {
                    router.push(.diningOutCost)
                } label: {
                    menuRow(item).contentShape(Rectangle())
                }
                .buttonStyle(.plain)
            }
        }
    }

    var infoSection: some View {
        VStack(alignment: .leading, spacing: Spacing.m) {
            SectionHeader(title: .myMenuInfo)
            GroupedListCard(
                items: [
                    MenuItem(id: "privacy", title: .myMenuPrivacy),
                    MenuItem(id: "priceInfo", title: .myMenuPriceInfo),
                    MenuItem(id: "storageGuide", title: .myMenuStorageGuide),
                    MenuItem(
                        id: "appInfo",
                        title: .myMenuAppInfo,
                        trailing: AppInfo.appVersion
                    ),
                ]
            ) { item in
                Button {
                    openInfo(item.id)
                } label: {
                    menuRow(item).contentShape(Rectangle())
                }
                .buttonStyle(.plain)
            }
        }
    }

    private func openInfo(_ id: String) {
        switch id {
        case "privacy": router.push(.privacyPolicy)
        case "priceInfo": router.push(.priceInfo)
        case "storageGuide": router.push(.storageGuide)
        default: router.push(.appInfo)
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

            AppIcon(.chevronRight)
                .foregroundStyle(Color.appDisabled)
        }
    }

    // MARK: - 로그아웃 · 탈퇴

    var bottomActions: some View {
        HStack(spacing: Spacing.xl) {
            Button(.myMenuLogout) { vm.showLogoutDialog = true }
                .foregroundStyle(Color.appTextSecondary)
            Button(.myMenuWithdraw) { vm.showWithdrawDialog = true }
                .foregroundStyle(Color.appAttention)
        }
        .appFont(.subbody)
        .frame(maxWidth: .infinity)
        .padding(.bottom, Spacing.l)
    }

    // 12000 → "12,000원"
    private func won(_ value: Int) -> String {
        String(
            format: String(localized: "common_won_format"),
            value.formatted()
        )
    }
}

#if DEBUG
    #Preview {
        MyPageView(
            vm: MyPageViewModel(
                users: PreviewUserRepository(),
                auth: PreviewAuthService()
            )
        )
    }

    #Preview("불러오기 실패") {
        MyPageView(
            vm: MyPageViewModel(
                users: PreviewUserRepository(shouldFail: true),
                auth: PreviewAuthService()
            )
        )
    }
#endif
