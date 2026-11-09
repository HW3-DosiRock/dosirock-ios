//
//  Router.swift
//  DosiRock
//
//  Created by Admin on 11/9/26.
//

final class Router<Route: Hashable> {

    var path: [Route] = []

    func push(_ route: Route) { path.append(route) }
    func pop() { _ = path.popLast() }
    func popToRoot() { path.removeAll() }
}
