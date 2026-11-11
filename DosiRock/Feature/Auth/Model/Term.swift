//
//  Term.swift
//  DosiRock
//
//  Created by Admin on 11/11/26.
//

import SwiftUI

/// 회원가입 약관 문서 (Resources/Terms/*.json 한 개 = 약관 한 개)
struct TermDocument: Decodable {
    let version: String
    let title: String
    let sections: [Section]

    struct Section: Decodable {
        let heading: String
        let body: [String]?   // 문단 목록
        let items: [Item]?    // 표 항목 (수집 항목 · 이용 목적 · 보유 기간 등)
    }

    struct Item: Decodable {
        let label: String
        let text: String
    }
}

/// 가입 화면에서 체크박스로 동의받는 약관
enum Term: String, CaseIterable, Identifiable {
    case age = "terms_age"   // 문서 없음 → 체크만
    case service = "terms_service"
    case privacy = "terms_privacy_consent"

    var id: Self { self }

    /// 체크박스 문구. 문서가 있으면 JSON의 title, 없는 항목(.age)만 직접 지정
    var title: String { document?.title ?? "만 14세 이상입니다" }

    /// 번들의 JSON 문서. 파일이 없거나 형식이 틀리면 nil → 보기 버튼 비활성
    var document: TermDocument? {
        guard let url = Bundle.main.url(forResource: rawValue, withExtension: "json"),
              let data = try? Data(contentsOf: url) else { return nil }
        return try? JSONDecoder().decode(TermDocument.self, from: data)
    }

    var hasDocument: Bool { document != nil }
}
