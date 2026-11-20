//
//  Navigation.swift
//  DosiRock
//
//  Created by Admin on 11/6/26.
//

import SwiftUI

enum Navigation : CaseIterable, Hashable {
    case thisweek
    case fridge
    case mypage

    var label: LocalizedStringKey {
        switch self {
        case .thisweek:
            "tab_this_week"
        case .fridge:
            "tab_fridge"
        case .mypage:
            "tab_my_page"
        }
    }
    
    var icDef: ImageResource {
        switch self {
        case .thisweek:
            .tabWeek
        case .fridge:
            .fridge
        case .mypage:
            .tabMy
        }
    }
    
    var icActive: ImageResource {
        switch self {
        case .thisweek:
            .tabWeekActive
        case .fridge:
            .tabFridgeActive
        case .mypage:
            .tabMyActive
        }
    }

}
