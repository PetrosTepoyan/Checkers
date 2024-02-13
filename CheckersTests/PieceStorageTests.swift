//
//  PieceStorageTests.swift
//  CheckersTests
//
//  Created by Petros Tepoyan on 12.02.2024.
//

@testable import Checkers
import XCTest

final class PieceStorageTests: XCTestCase {
    
    func testMovePiece() throws {
        let regularMoveChecker = RegularMoveChecker()
        let eatingMoveChecker = EatingMoveChecker()
        var pieceStorage = PieceStorage.initial(moveChecker: regularMoveChecker)
        
        let fromCoord = Coord(row: 2, col: 0)
        let toCoord = Coord(row: 3, col: 1)
        
        let movingPiece = try XCTUnwrap(pieceStorage.piecesLayout[fromCoord.row][fromCoord.col])
        
        pieceStorage = pieceStorage.movePiece(
            fromCoord: fromCoord,
            toCoord: toCoord,
            regularMoveChecker: regularMoveChecker,
            eatingMoveChecker: eatingMoveChecker
        )
        
        let newActions = try XCTUnwrap(pieceStorage.piecesActions[movingPiece])
        
        XCTAssert(newActions.count == 2, newActions.description)
        
        let movableActions = Set(newActions.compactMap({ $0 as? MoveAction }))
        XCTAssert(movableActions.count == 2, movableActions.description)
        XCTAssert(movableActions.contains(
            MoveAction(
                fromCoord: Coord(row: 3, col: 1),
                toCoord: Coord(row: 4, col: 2)
            )
        ))
        XCTAssert(movableActions.contains(
            MoveAction(
                fromCoord: Coord(row: 3, col: 1),
                toCoord: Coord(row: 4, col: 0)
            )
        ))
        
        
        XCTAssert(pieceStorage.coordsPieces[toCoord] == movingPiece)
        XCTAssert(pieceStorage.coordsPieces[fromCoord] == nil)
    }
    
}
