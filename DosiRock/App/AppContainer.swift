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

    static func live() -> AppContainer {

        let client = APIClient(
            baseURL: URL(string: "https://dosirock.duckdns.org/api")!
        )

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
