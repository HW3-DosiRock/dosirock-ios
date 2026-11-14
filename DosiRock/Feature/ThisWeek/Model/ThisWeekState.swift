//
//  ThisWeekState.swift
//  DosiRock
//
//  Created by Admin on 11/12/26.
//

// 이번주 탭에서 보여줄 화면 상태 (ThisWeekView가 이 값으로 States 폴더의 화면을 고른다)
enum ThisWeekState {
    
    case loading  // 서버 응답을 기다리는 중
    case error  // 데이터 못가져 왔을 때.1
    
    case emptyIngredient  // 재료가 없음 → ThisWeekEmptyIngredientView
    case emptyRecipe  // 재료는 있지만 레시피가 없음 → ThisWeekRecipeEmptyView
    case makingRecipe //ai 레시피 받아 오는 중
    case recipeList // 확정 전/후 레시피 목록 
    
}
