//
//  AppContainer.swift
//  DosiRock
//
//  Created by Admin on 11/17/26.
//

import SwiftUI

struct AppContainer {
    let auth: AuthService
    let user: UserRepository
    let ingredients: IngredientRepository
    let inventory: InventoryRepository
    
    // 서버 주소는 여기서만 교체
    private static let baseURL = URL(
        string: "https://dosirock.duckdns.org/api"
    )!
    //         private static let baseURL = URL(string: "http://0.0.0.0:3001/api")!   // Mockoon

    static func live() -> AppContainer {

        let client = APIClient(baseURL: baseURL)

        #if DEBUG
            let inventory: InventoryRepository = PreviewInventoryRepository(
                scenario: .empty
            )
        #else
            let inventory: InventoryRepository = EmptyInventoryRepository()
        #endif

        return AppContainer(
            auth: AuthServiceImpl(client: client),
            user: UserRepositoryImpl(client: client),
            ingredients: IngredientRepositoryImpl(client: client),
            inventory: inventory
        )
    }
}

// SwiftUI Environment에 container라는 칸을 하나 추가해요
extension EnvironmentValues {
    @Entry var container: AppContainer = .live()
}
