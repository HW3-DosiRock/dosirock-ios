//
//  View+SwipeBackDisabled.swift
//  DosiRock
//
//  UINavigationController+SwipeBack 이 앱 전체에 켜 둔 스와이프 뒤로가기를
//  특정 화면에서만 끈다. (예: 나가기 확인 다이얼로그를 우회하지 못하게)
//

import SwiftUI

extension View {
    func swipeBackDisabled() -> some View {
        background(SwipeBackBlocker())
    }
}

private struct SwipeBackBlocker: UIViewControllerRepresentable {

    func makeUIViewController(context: Context) -> Controller { Controller() }
    func updateUIViewController(_ controller: Controller, context: Context) {}

    final class Controller: UIViewController {
        override func viewWillAppear(_ animated: Bool) {
            super.viewWillAppear(animated)
            navigationController?.interactivePopGestureRecognizer?.isEnabled = false
        }

        // 이 화면을 떠날 때 다시 켜서 다른 화면은 영향이 없게 함
        override func viewWillDisappear(_ animated: Bool) {
            super.viewWillDisappear(animated)
            navigationController?.interactivePopGestureRecognizer?.isEnabled = true
        }
    }
}
