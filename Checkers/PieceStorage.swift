//
//  PieceStorage.swift
//  Checkers
//
//  Created by Petros Tepoyan on 10.02.2024.
//

import Foundation

// Tasks
// Knows the coordinate of each piece
// Know the piece at each coordinate
// Always has a map of piece : available actions
// At a position change of a piece, update the available actions of neighbouring pieces

struct PieceStorage: Equatable {
    
    private(set) var piecesLayout: [[Piece?]]
    private(set) var piecesActions: [Piece : [Action]]
    private(set) var piecesCoords: [Piece : Coord]
    private(set) var coordsPieces: [Coord : Piece]
    
    init(piecesLayout: [[Piece?]], piecesActions: [Piece : [Action]], piecesCoords: [Piece : Coord], coordsPieces: [Coord : Piece]) {
        self.piecesLayout = piecesLayout
        self.piecesActions = piecesActions
        self.piecesCoords = piecesCoords
        self.coordsPieces = coordsPieces
    }
    
    var actions: [Action] {
        piecesActions.values.flatMap { $0 }
    }
    
    func movePiece(fromCoord: Coord, toCoord: Coord,
                   regularMoveChecker: RegularMoveChecker,
                   eatingMoveChecker: EatingMoveChecker) -> PieceStorage {
        guard let piece = piece(forCoord: fromCoord) else { return self }
        
        var dirtyCoords: Set<Coord> = []
        dirtyCoords = dirtyCoords.union(fromCoord.neighbours)
        dirtyCoords = dirtyCoords.union(toCoord.neighbours)
        
        var piecesLayout = piecesLayout
        var piecesCoords = piecesCoords
        var coordsPieces = coordsPieces
        
        piecesLayout[fromCoord.row][fromCoord.col] = nil
        piecesLayout[toCoord.row][toCoord.col] = piece
        
        piecesCoords[piece] = toCoord
        
        coordsPieces.removeValue(forKey: fromCoord)
        coordsPieces[toCoord] = piece
        
        var newPieceStorage = PieceStorage(
            piecesLayout: piecesLayout,
            piecesActions: piecesActions,
            piecesCoords: piecesCoords,
            coordsPieces: coordsPieces
        )
        var piecesActions = piecesActions
        for dirtyCoord in dirtyCoords {
            
            var resultActions: [Action] = []
            
            if let dirtyPiece = coordsPieces[dirtyCoord] {
                
                resultActions.append(
                    contentsOf: regularMoveChecker.movingActions(
                        pieceStorage: newPieceStorage,
                        piece: dirtyPiece,
                        coord: dirtyCoord
                    )
                )
                
                resultActions.append(
                    contentsOf: eatingMoveChecker.eatingActions(
                        pieceStorage: newPieceStorage,
                        piece: dirtyPiece,
                        coord: dirtyCoord
                    )
                )
                
                piecesActions[piece] = resultActions
            }
        }
        
        newPieceStorage.piecesActions = piecesActions
        return newPieceStorage
    }
    
    mutating func moveAndEatPiece(fromCoord: Coord, eatingCoord: Coord, toCoord: Coord,
                                  regularMoveChecker: RegularMoveChecker,
                                  eatingMoveChecker: EatingMoveChecker) {
        guard let movingPiece = self.piece(forCoord: fromCoord),
              let eatingPiece = self.piece(forCoord: eatingCoord)
        else { return }
        
        var dirtyCoords: Set<Coord> = []
        dirtyCoords = dirtyCoords.union(fromCoord.neighbours)
        dirtyCoords = dirtyCoords.union(toCoord.neighbours)
        dirtyCoords = dirtyCoords.union(eatingCoord.neighbours)
        
        piecesLayout[fromCoord.row][fromCoord.col] = nil
        piecesLayout[toCoord.row][toCoord.col] = movingPiece
        
        piecesLayout[eatingCoord.row][eatingCoord.col] = nil
        
        piecesCoords[movingPiece] = toCoord
        coordsPieces[fromCoord] = movingPiece
        
        piecesCoords.removeValue(forKey: eatingPiece)
        coordsPieces.removeValue(forKey: eatingCoord)
        
        for dirtyCoord in dirtyCoords {
            
            var resultActions: [Action] = []
            
            if let piece = coordsPieces[dirtyCoord] {
                
                resultActions.append(
                    contentsOf: regularMoveChecker.movingActions(pieceStorage: self, piece: piece, coord: dirtyCoord)
                )
                
                resultActions.append(
                    contentsOf: eatingMoveChecker.eatingActions(pieceStorage: self, piece: piece, coord: dirtyCoord)
                )
            }
        }
    }
    
    func piece(forCoord: Coord) -> Piece? {
        coordsPieces[forCoord]
    }
    
    func cellState(at coord: Coord) -> CellState {
        switch piece(forCoord: coord)?.isWhite {
        case true:
            return .white
        case false:
            return .black
        default:
            return .empty
        }
    }
    
    func pring() {
        let mapped = piecesLayout
            .map {
                $0
                    .map {
                        let isWhite = $0?.isWhite
                        if let isWhite {
                            return isWhite ? 1 : -1
                        } else {
                            return 0
                        }
                    }
            }
        for map in mapped {
            print(map)
        }
        print()
    }
    
    static func == (lhs: PieceStorage, rhs: PieceStorage) -> Bool {
        lhs.piecesLayout == rhs.piecesLayout
    }
}


extension PieceStorage {
    static func initial(moveChecker: RegularMoveChecker) -> PieceStorage {
        
        let initialPiecesLayout = [
            [Piece(.w1), nil, Piece(.w4), nil, Piece(.w7), nil, Piece(.w10), nil],
            [nil, Piece(.w3), nil, Piece(.w6), nil, Piece(.w9), nil, Piece(.w12)],
            [Piece(.w2), nil, Piece(.w5), nil, Piece(.w8), nil, Piece(.w11), nil],
            [nil, nil, nil, nil, nil, nil, nil, nil],
            [nil, nil, nil, nil, nil, nil, nil, nil],
            [nil, Piece(.b2), nil, Piece(.b5), nil, Piece(.b8), nil, Piece(.b11)],
            [Piece(.b1), nil, Piece(.b4), nil, Piece(.b7), nil, Piece(.b10), nil],
            [nil, Piece(.b3), nil, Piece(.b6), nil, Piece(.b9), nil, Piece(.b12)]
        ]
        
        var piecesCoords: [Piece : Coord] = [:]
        var coordsPieces: [Coord : Piece] = [:]
        
        for tuple1 in initialPiecesLayout.enumerated() {
            for tuple2 in tuple1.element.enumerated() {
                let coord = Coord(row: tuple1.offset, col: tuple2.offset)
                if let piece = tuple2.element {
                    piecesCoords[piece] = coord
                    coordsPieces[coord] = piece
                }
            }
        }
        
        var pieceStorage = PieceStorage(
            piecesLayout: initialPiecesLayout,
            piecesActions: [:],
            piecesCoords: piecesCoords,
            coordsPieces: coordsPieces
        )
        
        var piecesActions: [Piece : [Action]] = [:]
        
        let leafUpperRow: [Piece] = initialPiecesLayout[2].compactMap { $0 }
        for piece in leafUpperRow {
            if let coord = piecesCoords[piece] {
                let actions = moveChecker.movingActions(pieceStorage: pieceStorage, piece: piece, coord: coord)
                piecesActions[piece] = actions
            }
        }
        
        let leafLowerRow: [Piece] = initialPiecesLayout[5].compactMap { $0 }
        for piece in leafLowerRow {
            if let coord = piecesCoords[piece] {
                let actions = moveChecker.movingActions(pieceStorage: pieceStorage, piece: piece, coord: coord)
                piecesActions[piece] = actions
            }
        }
        
        pieceStorage.piecesActions = piecesActions
        return pieceStorage
    }
}
