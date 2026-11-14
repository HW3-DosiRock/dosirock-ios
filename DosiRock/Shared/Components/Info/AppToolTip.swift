//
//  AppToolTip.swift
//  DosiRock
//
//  Created by Admin on 11/3/26.
//

import SwiftUI

struct AppToolTip: View {

    let message: String
    var arrowOffset: CGFloat = Spacing.xl  // 화살표가 말풍선 왼쪽 끝에서 떨어진 거리

    var body: some View {

        VStack(alignment: .leading, spacing: 0) {

            //삼각형
            Triangle()
                .fill(Color.appTextPrimary)
                .frame(width: 16, height: 8)
                .padding(.leading, arrowOffset)

            //사각형
            Text(message)
                .appFont(.body)
                .foregroundStyle(Color.appSurface)
                .fixedSize(horizontal: false, vertical: true)
                .padding(.horizontal, Spacing.l)
                .padding(.vertical, Spacing.m)
                .background(Color.appTextPrimary)
                .clipShape(RoundedRectangle(cornerRadius: Radius.large))

        }
    }

    private struct Triangle: Shape {
        func path(in rect: CGRect) -> Path {
            Path { p in
                p.move(to: CGPoint(x: rect.midX, y: rect.minY))  // 위 꼭짓점
                p.addLine(to: CGPoint(x: rect.maxX, y: rect.maxY))  // 오른쪽 아래
                p.addLine(to: CGPoint(x: rect.minX, y: rect.maxY))  // 왼쪽 아래
                p.closeSubpath()
            }
        }
    }
}

// ViewModifier는 뷰에 붙일 수 있는 나만의 modifier를 만드는 틀
// 뷰를 누르면 그 바로 아래에 툴팁이 보였다가 duration초 뒤에 저절로 사라진다.
// - 화살표는 항상 누른 뷰의 가운데를 가리킨다.
// - 말풍선이 화면 좌우 밖으로 나가면 안쪽으로 밀어 넣고, 화살표 위치는 알아서 맞춘다.
// - 보일지 여부(상태)는 이 안에서 관리하므로 쓰는 쪽에 @State가 필요 없다.
private struct AppToolTipModifier: ViewModifier {

    let message: String
    let width: CGFloat?
    let duration: Double

    @State private var isShown = false
    @State private var hideTask: Task<Void, Never>?
    @State private var tipSize: CGSize = .zero  // 말풍선 크기 (화면 밖으로 안 나가게 계산할 때 사용)

    func body(content: Content) -> some View {
        content
            .contentShape(Rectangle())  //아이콘의 사각형 전체를 누를 수 있게
            .onTapGesture { show() }    //누르면 show 실행
            .overlay {
                // GeometryReader로 "붙인 뷰"의 위치와 크기를 알아낸다
                GeometryReader { host in
                    if isShown { tip(host: host) }
                }
                .allowsHitTesting(false)  // 툴팁이 뷰의 탭을 가로채지 않게
            }
            .zIndex(1)  // 아래쪽 뷰에 가려지지 않게
    }

    private var screenWidth: CGFloat {
        (UIApplication.shared.connectedScenes.first as? UIWindowScene)?
            .screen.bounds.width ?? 393
    }

    private func tip(host: GeometryProxy) -> some View {
        let arrowHalf: CGFloat = 8  // 삼각형 폭(16)의 절반
        let hostMinX = host.frame(in: .global).minX  // 화면 왼쪽 끝에서 뷰까지 거리
        let hostCenter = host.size.width / 2

        // 말풍선 왼쪽 끝 위치(뷰 왼쪽 끝 기준): 화살표 끝이 뷰 가운데에 오도록
        let ideal = hostCenter - Spacing.xl - arrowHalf
        // 화면 좌우 여백 안에 들어오도록 보정
        let minX = Spacing.screenHorizontal - hostMinX
        let maxX = screenWidth - Spacing.screenHorizontal - tipSize.width - hostMinX
        let x = min(max(ideal, minX), max(minX, maxX))

        return AppToolTip(
            message: message,
            // 말풍선을 밀었어도 화살표는 계속 뷰 가운데를 가리키게
            arrowOffset: max(Spacing.s, hostCenter - x - arrowHalf)
        )
        .frame(width: width)  // nil이면 글자 길이만큼 (줄바꿈은 문구의 \n으로)
        .fixedSize()
        .onGeometryChange(for: CGSize.self, of: { $0.size }, action: { tipSize = $0 })
        .offset(x: x, y: host.size.height + Spacing.xs)  // 뷰 바로 아래
        .transition(.opacity)
    }

    private func show() {
        hideTask?.cancel()  // 다시 누르면 타이머를 처음부터
        withAnimation(.easeInOut(duration: 0.15)) { isShown = true }
        hideTask = Task {
            try? await Task.sleep(for: .seconds(duration))
            guard !Task.isCancelled else { return }
            withAnimation(.easeInOut(duration: 0.15)) { isShown = false }
        }
    }
}

extension View {
    // 이 뷰를 누르면 바로 아래에 툴팁을 보여준다.
    // width: 말풍선 폭을 고정하고 싶을 때만 지정 (보통은 생략하고 문구에 \n으로 줄바꿈)
    func appToolTip(
        _ message: String,
        width: CGFloat? = nil,
        duration: Double = 3
    ) -> some View {
        modifier(AppToolTipModifier(message: message, width: width, duration: duration))
    }
}

#Preview {
    AppToolTip(message: "외식 한 끼 기준 \n 새로 완료하는 도시락부터 적용")
        .padding(Spacing.xl)
        .background(Color.appBackground)
}
