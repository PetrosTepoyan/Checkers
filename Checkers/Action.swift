//
//  Action.swift
//  Checkers
//
//  Created by Petros Tepoyan on 10.02.2024.
//

import Foundation

protocol State {
    var actions: [Action] { get }
    func result(action: Action) -> Self
}

protocol Action {
    var endCoord: Coord? { get }
}

//struct Move: Action {
//    
//    let fromCoord: Coord
//    let toCoord: Coord
//    
//    func result() -> State {
//        <#code#>
//    }
//}
