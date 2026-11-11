//
//  UINavigationController+SwipeBack.swift
//  DosiRock
//
//  기본 뒤로가기 버튼을 숨겨도(navigationBarBackButtonHidden) 스와이프 뒤로가기가 동작하게 한다.
//  앱 전체의 NavigationStack에 적용된다.
//

import UIKit

extension UINavigationController: @retroactive UIGestureRecognizerDelegate {

    override open func viewDidLoad() {
        super.viewDidLoad()
        interactivePopGestureRecognizer?.delegate = self
    }

    // 루트 화면에서는 막아야 스와이프 후 화면이 멈추지 않는다
    public func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        viewControllers.count > 1
    }
}
