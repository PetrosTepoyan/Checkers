//
//  File.swift
//  Checkers
//
//  Created by Petros Tepoyan on 10.02.2024.
//

import Foundation

enum PieceId: Hashable {
    case w1, w2, w3, w4, w5, w6, w7, w8, w9, w10, w11, w12
    case b1, b2, b3, b4, b5, b6, b7, b8, b9, b10, b11, b12
    
    var isWhite: Bool {
        switch self {
        case .w1, .w2, .w3, .w4, .w5, .w6, .w7, .w8, .w9, .w10, .w11, .w12:
            return true
        default:
            return false
        }
    }
    
    func isOpponent(to: PieceId) -> Bool {
        self.isWhite != to.isWhite
    }
}
