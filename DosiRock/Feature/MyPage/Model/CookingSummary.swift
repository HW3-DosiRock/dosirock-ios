//
//  CookingSummary.swift
//  DosiRock
//

import Foundation

// 이번 달 요약 조회 응답의 data (조리 완료 횟수와 예상 절약액)
nonisolated struct CookingSummary: Decodable {
    let month: String  // 한국 기준 대상 월
    let completedCount: Int  // 미산정을 포함한 전체 조리 완료 횟수
    let estimatedSavings: Double  // 절약액 합계 (음수 가능, 미산정 제외)
    let partialEstimationCount: Int  // 일부 가격이 없어 부분 산정한 기록 수
    let unavailableEstimationCount: Int  // 산정하지 못한 기록 수
}
