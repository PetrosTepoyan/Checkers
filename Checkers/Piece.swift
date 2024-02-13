//
//  Piece.swift
//  Checkers
//
//  Created by Petros Tepoyan on 10.02.2024.
//

import Foundation

struct Piece: Hashable {
    let id: PieceId
    let isQueen: Bool = false
    
    var isWhite: Bool {
        id.isWhite
    }
    
    func isOpponent(to other: Piece) -> Bool {
        self.id.isOpponent(to: other.id)
    }
    
    init(_ id: PieceId) {
        self.id = id
    }
}
