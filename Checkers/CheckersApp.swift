//
//  CheckersApp.swift
//  Checkers
//

import SwiftUI

@main
struct CheckersApp: App {
    var body: some Scene {
        WindowGroup {
            GameView()
        }
    }
}

#Preview {
    GameView()
}

enum CellState {
    case white
    case black
    case empty
}

