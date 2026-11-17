//
//  AppInfo.swift
//  DosiRock
//
//  Created by Admin on 11/9/26.
//
import Foundation

// 앱 자체에 대한 정보 (의존성은 AppContainer에서 관리)
enum AppInfo {

    // 번들(MARKETING_VERSION)에 적힌 앱 버전
    static let appVersion =
        Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String
        ?? "-"

}
