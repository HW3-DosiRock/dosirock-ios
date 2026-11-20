//
//  ThisWeekRecipeEmptyView.swift
//  DosiRock
//
//  Created by Admin on 11/12/26.
//

import SwiftUI

//상태 2 . 재료 등록은 있지만 이번주 레시피 없을 때
struct ThisWeekRecipeEmptyView: View {

    @Environment(\.container) private var container
    @Bindable var vm: ThisWeekViewModel
    @State private var showsLikeIngredientPicker = false

    var body: some View {

        VStack(spacing: 0) {

            ScrollView {

                VStack(alignment: .leading, spacing: Spacing.xl) {

                    //이번주 기간
                    Text(vm.weekRangeText)
                        .appFont(.heading)
                        .foregroundStyle(Color.appTextPrimary)

                    // 툴팁은 아래로 펼쳐지므로, 위 섹션일수록 zIndex를 크게 줘서 아래 카드에 안 가려지게 함
                    // (zIndex는 같은 부모 안의 형제끼리만 비교됨)

                    //재료 사용 우선 순위
                    ingredientPriorityView
                        .zIndex(3)

                    // 이번주 먹고 싶은 재료 추가
                    likeIngredientView
                        .zIndex(2)

                    // 국물 메뉴 세그먼트
                    soupMenuView
                        .zIndex(1)
                }
                // 화면 폭 전체를 쓰게 해서, 툴팁처럼 내용 밖으로 그려지는 것이 잘리지 않게 함
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.bottom, Spacing.l)
            }
            .frame(
                maxWidth: .infinity,
                maxHeight: .infinity,
                alignment: .topLeading
            )

            //이번 주 메뉴 제안 받기 버튼 (스크롤 밖에 둬서 하단에 고정)
            BottomActionBar(
                title: .thisweekSuggestWithCondition,
                icon: .sparkle
            ) {
                Task { await vm.suggest() }
            }
        }
    }

    //MARK: 섹션 제목 옆 정보 아이콘
    // 누르면 툴팁이 보였다가 몇 초 뒤 저절로 사라짐 (상태 변수는 modifier 안에서 관리)
    private func infoIcon(_ message: LocalizedStringResource) -> some View {
        AppIcon(.info, decorative: false)
            .foregroundStyle(Color.appTextSecondary)
            .appToolTip(message)
            .accessibilityAddTraits(.isButton)
    }

    //MARK: 이번 주 먹고 싶은 재료
    var likeIngredientView: some View {

        VStack(spacing: Spacing.m) {
            HStack {
                Text(.thisweekLikeIngredientTitle)
                    .appFont(.heading)
                    .foregroundStyle(Color.appTextPrimary)

                infoIcon(.thisweekShowLikeIngredientInfo)

                Spacer()

                TextLinkButton(
                    title: .thisweekLikeIngredientSub,
                    textColor: .appTextSecondary,
                    textStyle: .subbody
                ) {
                    showsLikeIngredientPicker = true
                }
            }
            .zIndex(1)  // 툴팁이 바로 아래 카드에 가려지지 않게

            // 고른 재료 칩들 + 재료 선택 칩 (폭이 모자라면 다음 줄로)
            FlowLayout {
                ForEach(vm.likeIngredients) { item in
                    selectedIngredientChip(item)
                }

                Button {
                    showsLikeIngredientPicker = true
                } label: {
                    HStack(spacing: Spacing.s) {
                        AppIcon(.plus, size: Size.Icon.small)
                        Text(.thisweekLikeIngredientAdd)
                    }
                    .appFont(.subbody)
                    .foregroundStyle(Color.appTextPrimary)
                    .padding(.horizontal, Spacing.l)
                    .frame(minHeight: Size.minTouch)
                    .overlay(Capsule().stroke(Color.appBorder))
                    .contentShape(Capsule())
                }
                .buttonStyle(.plain)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .animation(.easeOut(duration: 0.15), value: vm.likeIngredients)
            .thisWeekCard()
        }
        .sheet(isPresented: $showsLikeIngredientPicker) {
            LikeIngredientPickerSheet(
                vm: IngredientPickerViewModel(
                    repository: container.ingredients
                ),
                selected: $vm.likeIngredients
            )
        }
    }

    // 고른 재료 칩: 누르면 목록에서 빠짐
    private func selectedIngredientChip(_ item: IngredientItem) -> some View {
        Button {
            vm.likeIngredients.removeAll { $0.id == item.id }
        } label: {
            HStack(spacing: Spacing.s) {
                Text(item.name)
                AppIcon(.close, size: Size.Icon.small)
            }
            .appFont(.subbody)
            .foregroundStyle(Color.appSurface)
            .padding(.horizontal, Spacing.l)
            .frame(minHeight: Size.minTouch)
            .background(Capsule().fill(Color.appTextPrimary))
            .contentShape(Capsule())
        }
        .buttonStyle(.plain)
    }

    //MARK: 국물 메뉴
    var soupMenuView: some View {

        VStack(spacing: Spacing.m) {
            HStack {
                Text(.thisweekSoupTitle)
                    .appFont(.heading)
                    .foregroundStyle(Color.appTextPrimary)

                infoIcon(.thisweekShowSoupInfo)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .zIndex(1)  // 툴팁이 바로 아래 카드에 가려지지 않게

            SegmentControl(items: SoupOption.allCases, selected: $vm.soupOption)
            {
                String(localized: $0.title)
            }
            .thisWeekCard()
        }
    }

    //MARK: 재료 사용 우선 순위
    var ingredientPriorityView: some View {

        VStack {
            HStack {
                Text(.thisweekIngredientPriority)
                    .appFont(.heading)
                    .foregroundStyle(Color.appTextPrimary)

                infoIcon(.thisweekShowIngredientPriorityInfo)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .zIndex(1)  // 툴팁이 바로 아래 카드에 가려지지 않게

            VStack {

                VStack {
                    Text(.thisweekPriorityFirstUse)
                }
                .frame(maxWidth: .infinity, alignment: .trailing)

                VStack {
                    //TODO: 임시 , api나오면 목록으로 교체
                    priorityListContent

                }
            }
            .thisWeekCard()

        }

    }

    var priorityListContent: some View {

        VStack(spacing: 0) {
            ForEach($vm.priorityItems) { $item in

                HStack(spacing: Spacing.l) {

                    IngredientImage(code: item.code, size: Size.Icon.xLarge)

                    // 이름 · 양 / 권장 사용일
                    VStack(alignment: .leading, spacing: Spacing.s) {
                        HStack(
                            alignment: .firstTextBaseline,
                            spacing: Spacing.s
                        ) {
                            Text(item.name)
                                .appFont(.heading)
                                .foregroundStyle(Color.appTextPrimary)
                            Text(item.amount)
                                .appFont(.caption)
                                .foregroundStyle(Color.appTextSecondary)
                        }
                        Text("권장 사용일까지 \(item.daysLeft)일")
                            .appFont(.subbody)
                            .foregroundStyle(Color.appTextSecondary)
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)

                    ToggleSwitch(isOn: $item.isOn)
                }
                .padding(.vertical, Spacing.m)

                // 마지막 줄 뒤에는 구분선 없음
                if item.id != vm.priorityItems.last?.id {
                    Rectangle()
                        .fill(Color.appBorder)
                        .frame(height: 1)
                }
            }
        }
    }
}

// 이번 주 화면 섹션 카드 (흰 배경 + 테두리)
extension View {
    func thisWeekCard() -> some View {
        self
            .padding(Spacing.m)
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

// 국물 메뉴 포함 여부
enum SoupOption: CaseIterable {
    case exclude, include

    var title: LocalizedStringResource {
        switch self {
        case .exclude: .thisweekSoupExcept
        case .include: .thisweekSoupInclude
        }
    }
}
 
struct PriorityItem: Identifiable {
    let id: Int
    let code: String
    let name: String
    let amount: String
    let daysLeft: Int
    var isOn: Bool = true
}
 
#if DEBUG
#Preview {
    ThisWeekRecipeEmptyView(
        vm: ThisWeekViewModel(
            mealPlans: PreviewMealRepository(scenario: .noPlan),
            inventory: PreviewInventoryRepository()      
        )
    )
    .padding()
}
#endif
