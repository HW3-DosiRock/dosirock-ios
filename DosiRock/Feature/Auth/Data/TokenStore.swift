//
//  TokenStore.swift
//  DosiRock
//
//  Created by Admin on 11/12/26.
//

import Foundation
import Security

// 로그인 토큰(access, refresh)을 Keychain에 저장·조회·삭제하는 도구.
// Keychain은 iOS가 암호화해서 보관해 주는 금고라서, 토큰처럼 민감한 값은 UserDefaults 대신 여기에 둔다.
// 앱을 껐다 켜도 값이 남아 있어서 "자동 로그인"에 쓸 수 있다.
//
// 사용 예)
//   TokenStore.save("abc", for: .access)   // 저장
//   TokenStore.read(.access)                // 읽기 → "abc" (없으면 nil)
//   TokenStore.clear()                      // 로그아웃 시 전부 삭제
nonisolated enum TokenStore {

    // 어떤 토큰인지 구분하는 이름표
    enum Key: String { case access, refresh }

    // 이 앱이 저장한 항목끼리 묶어 두는 이름 (다른 앱·다른 용도의 항목과 섞이지 않게)
    private static let service = "dosirock.auth"

    // Keychain에서 "항목 하나"를 가리키는 주소.
    // 저장·조회·삭제 모두 이 주소(service + key)로 같은 항목을 찾는다.
    private static func query(_ key: Key) -> [String: Any] {
        [
            kSecClass as String: kSecClassGenericPassword,  // 항목 종류: 일반 비밀번호/토큰
            kSecAttrService as String: service,  // 묶음 이름
            kSecAttrAccount as String: key.rawValue,  // 항목 이름 ("access" 또는 "refresh")
        ]
    }

    // 저장. Keychain은 같은 주소에 두 번 저장하면 에러가 나서,
    // 먼저 지우고 새로 넣는 방식으로 덮어쓰기를 한다.
    static func save(_ value: String, for key: Key) {
        SecItemDelete(query(key) as CFDictionary)  // 이미 있다면 지우고 다시 저장
        var item = query(key)
        item[kSecValueData as String] = Data(value.utf8)  // 실제 저장할 값 (문자열 → 바이트)
        // 기기를 켠 뒤 한 번 잠금을 풀면 접근 가능 (앱이 백그라운드에 있어도 읽을 수 있게)
        item[kSecAttrAccessible as String] = kSecAttrAccessibleAfterFirstUnlock
        SecItemAdd(item as CFDictionary, nil)  // 금고에 넣기
    }

    // 읽기. 저장된 값이 없으면 nil
    static func read(_ key: Key) -> String? {
        var q = query(key)
        q[kSecReturnData as String] = true  // "값(데이터)을 돌려줘"
        q[kSecMatchLimit as String] = kSecMatchLimitOne  // 하나만 찾아줘
        var result: AnyObject?  // 찾은 값이 여기에 담긴다
        // 금고에서 찾기. 성공(errSecSuccess)하고 데이터가 있어야 통과
        guard SecItemCopyMatching(q as CFDictionary, &result) == errSecSuccess,
            let data = result as? Data
        else { return nil }
        return String(data: data, encoding: .utf8)  // 바이트 → 문자열
    }

    // 로그아웃 때 호출. 두 토큰을 모두 삭제
    static func clear() {
        SecItemDelete(query(.access) as CFDictionary)
        SecItemDelete(query(.refresh) as CFDictionary)
    }
}
