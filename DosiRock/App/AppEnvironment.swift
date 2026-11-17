//
//  AppEnvironment.swift
//  DosiRock
//
//  Created by Admin on 11/9/26.
//
import Foundation

enum AppEnvironment {

    // 서버 주소는 여기서만 교체
    private static let baseURL = URL(
        string: "https://dosirock.duckdns.org/api"
    )!
    //         private static let baseURL = URL(string: "http://0.0.0.0:3001/api")!   // Mockoon

    // 번들(MARKETING_VERSION)에 적힌 앱 버전
    static let appVersion =
        Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String
        ?? "-"

    private static let client = APIClient(baseURL: baseURL)

    static func makeAuthService() -> AuthService {
        AuthServiceImpl(client: client)
    }

    static func makeUserRepository() -> UserRepository {
        UserRepositoryImpl(client: client)
    }

    static func makeInventoryRepository() -> InventoryRepository {
        #if DEBUG
            PreviewInventoryRepository(scenario: .empty)
        #else
            EmptyInventoryRepository()
        #endif
    }

    static func makeIngredientRepository() -> IngredientRepository {
        IngredientRepositoryImpl(client: client)
    }
}
