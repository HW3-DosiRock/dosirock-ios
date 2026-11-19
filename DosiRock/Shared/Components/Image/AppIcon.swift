//
//  AppIcon.swift
//  DosiRock
//

import SwiftUI

/// ic 폴더의 아이콘을 같은 방식으로 그린다 (템플릿 · 정사각 크기 · 색은 바깥 foregroundStyle).
/// 사용: `AppIcon(.chevronRight).foregroundStyle(Color.appDisabled)`
/// - 크기는 `Size.Icon` 토큰만 쓴다 (small 16 · medium 20 · large 24 · xLarge 48)
/// - 장식용이면 VoiceOver가 읽지 않게 숨긴다. 툴팁처럼 눌리는 아이콘은 `decorative: false`
struct AppIcon: View {

    let resource: ImageResource
    var size: CGFloat = Size.Icon.medium
    var decorative: Bool = true

    init(_ resource: ImageResource, size: CGFloat = Size.Icon.medium, decorative: Bool = true) {
        self.resource = resource
        self.size = size
        self.decorative = decorative
    }

    var body: some View {
        Image(resource)
            .renderingMode(.template)
            .resizable()
            .scaledToFit()
            .frame(width: size, height: size)
            .accessibilityHidden(decorative)
    }
}

#Preview {
    HStack(spacing: Spacing.l) {
        AppIcon(.info, size: Size.Icon.small)
        AppIcon(.chevronRight)
        AppIcon(.cart, size: Size.Icon.large)
        AppIcon(.alert, size: Size.Icon.xLarge)
    }
    .foregroundStyle(Color.appTextPrimary)
    .padding()
}
