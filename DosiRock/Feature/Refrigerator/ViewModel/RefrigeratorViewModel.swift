//
//  RefrigeratorViewModel.swift
//  DosiRock
//
//  Created by Admin on 11/16/26.
//

import Foundation

@Observable @MainActor
final class RefrigeratorViewModel {
    
    enum State {
        case loading
        case failed
        case empty  // 재료가 하나도 없음 (초기 화면)
        case loaded([InventoryItem])
    }

    private let inventory : InventoryRepository
    
    var state : State = .loading
    
    var showAddSheet = false
    
    init(inventory: InventoryRepository) {
        self.inventory = inventory
    }
    
    func load() async {
        state = .loading
        do{
            let items = try await inventory.fetch()
            state = items.isEmpty ? .empty : .loaded(items)
        } catch {
            state = .failed
        }
    }
}
