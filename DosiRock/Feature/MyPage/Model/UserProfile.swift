//
//  UserProfile.swift
//  DosiRock
//
//  Created by Admin on 11/13/26.
//

import Foundation

// 내 정보 조회 응답의 data
nonisolated struct UserProfile: Decodable {
    let email: String
    let nickname: String
    let diningOutCost: Int  // 외식 기준 금액(원)
}
