//
//  BoardState.swift
//  Checkers
//
//  Created by Petros Tepoyan on 10.02.2024.
//

import Foundation

enum Player {
    case white
    case black
}

struct BoardState: Equatable {
    
    static let initial: BoardState = {
        let moveChecker = RegularMoveChecker()
        return BoardState(pieceStorage: .initial(moveChecker: moveChecker),
                   regularMoveChecker: moveChecker,
                   eatingMoveChecker: EatingMoveChecker(),
                   player: .white)
    }()
    
    var pieceStorage: PieceStorage
    let regularMoveChecker: RegularMoveChecker
    let eatingMoveChecker: EatingMoveChecker
    var player: Player
    
    
    func actions(for coord: Coord) -> [Action] {
        guard let piece = pieceStorage.piece(forCoord: coord),
              let actions = pieceStorage.piecesActions[piece] else { return [] }
        return actions
    }
        
    func moveCoords(for coord: Coord) -> Set<Coord> {
        let actions = actions(for: coord)
        return Set(actions.compactMap({ $0.endCoord }))
    }
    
    static func == (lhs: BoardState, rhs: BoardState) -> Bool {
        lhs.pieceStorage == rhs.pieceStorage && lhs.player == rhs.player
    }
    
}



class RegularMoveChecker {
    
    func movingActions(pieceStorage: PieceStorage, piece: Piece, coord: Coord) -> [MoveAction] {
        
        var movableActions: [MoveAction] = []
        
        // Regular moves
        if !pieceGoesUp(piece),
           let leftUp = coord.leftUp(),
           pieceStorage.cellState(at: leftUp) == .empty {
            movableActions.append(MoveAction(fromCoord: coord, toCoord: leftUp))
        }
        
        if !pieceGoesUp(piece),
           let rightUp = coord.rightUp(),
           pieceStorage.cellState(at: rightUp) == .empty {
            movableActions.append(MoveAction(fromCoord: coord, toCoord: rightUp))
        }
        
        if pieceGoesUp(piece),
           let leftBottom = coord.leftBottom(),
           pieceStorage.cellState(at: leftBottom) == .empty {
            movableActions.append(MoveAction(fromCoord: coord, toCoord: leftBottom))
        }
        
        if pieceGoesUp(piece),
           let rightBottom = coord.rightBottom(),
           pieceStorage.cellState(at: rightBottom) == .empty {
            movableActions.append(MoveAction(fromCoord: coord, toCoord: rightBottom))
        }
        
        return movableActions
    }
    
    private func pieceGoesUp(_ piece: Piece) -> Bool {
        !piece.isWhite
    }
    
}

final class EatingMoveChecker {
    
    func eatingActions(pieceStorage: PieceStorage, piece: Piece, coord: Coord) -> [EatAction] {
        
        var resultActions: [EatAction] = []
        
        // Moves if I can eat
        if let leftUp = coord.leftUp(), // does it exist?
           let nextPiece = pieceStorage.piece(forCoord: leftUp), // is there a piece?
           piece.isOpponent(to: nextPiece), // is it an opponent
           let leftUpLeftUp = leftUp.leftUp(),  // does the space for eating exist
           pieceStorage.cellState(at: leftUpLeftUp) == .empty // is it empty
        {
            resultActions.append(EatAction(fromCoord: coord, eatingCoord: leftUp, toCoord: leftUpLeftUp))
        }
        
        if let rightUp = coord.rightUp(),
           let nextPiece = pieceStorage.piece(forCoord: rightUp),
           piece.isOpponent(to: nextPiece),
           let rightUpRightUp = rightUp.rightUp(),
           pieceStorage.cellState(at: rightUpRightUp) == .empty
        {
            resultActions.append(EatAction(fromCoord: coord, eatingCoord: rightUp, toCoord: rightUpRightUp))
        }
        
        if let leftBottom = coord.leftBottom(),
           let nextPiece = pieceStorage.piece(forCoord: leftBottom),
           piece.isOpponent(to: nextPiece),
           let leftBottomLeftBottom = leftBottom.leftBottom(),
           pieceStorage.cellState(at: leftBottomLeftBottom) == .empty
        {
            resultActions.append(EatAction(fromCoord: coord, eatingCoord: leftBottom, toCoord: leftBottomLeftBottom))
        }
        
        if let rightBottom = coord.rightBottom(),
           let nextPiece = pieceStorage.piece(forCoord: rightBottom),
           piece.isOpponent(to: nextPiece),
           let rightBottomRightBottom = rightBottom.rightBottom(),
           pieceStorage.cellState(at: rightBottomRightBottom) == .empty
        {
            resultActions.append(EatAction(fromCoord: coord, eatingCoord: rightBottom, toCoord: rightBottomRightBottom))
        }
        
        return resultActions
    }
}

struct MoveAction: Action, Hashable, CustomStringConvertible {
    let fromCoord: Coord
    let toCoord: Coord
    
    var endCoord: Coord? { toCoord }
    
    var description: String { "Move(from: \(fromCoord), to: \(toCoord)" }
}

struct EatAction: Action {
    let fromCoord: Coord
    let eatingCoord: Coord
    let toCoord: Coord
    
    var endCoord: Coord? { toCoord }
}

extension BoardState : State {
    
    var actions: [Action] {
        pieceStorage.actions
    }
    
    func result(action: Action) -> BoardState {
        
        let nextPlayer: Player = player == .black ? .white : .black
        
        if let action = action as? EatAction,
           let movingPiece = self.pieceStorage.piece(forCoord: action.fromCoord) {
            
            var newBoardState = BoardState(
                pieceStorage: pieceStorage,
                regularMoveChecker: regularMoveChecker,
                eatingMoveChecker: eatingMoveChecker,
                player: player // attention here, its correct
            )
            
            newBoardState.pieceStorage.moveAndEatPiece(
                fromCoord: action.fromCoord,
                eatingCoord: action.eatingCoord,
                toCoord: action.toCoord,
                regularMoveChecker: regularMoveChecker,
                eatingMoveChecker: eatingMoveChecker
            )
            
            let actions = newBoardState.pieceStorage.piecesActions[movingPiece]
            
            
            if actions?.filter({ $0 is EatAction }).isEmpty == true {
                // No more edible pieces, switching the turn
                newBoardState.player = nextPlayer
            } // otherwise, the same player
            
            return newBoardState
        }
        
        if let action = action as? MoveAction {
            
            var newBoardState = BoardState(
                pieceStorage: pieceStorage,
                regularMoveChecker: regularMoveChecker,
                eatingMoveChecker: eatingMoveChecker,
                player: nextPlayer
            )
            
            // Move
            newBoardState.pieceStorage.movePiece(
                fromCoord: action.fromCoord,
                toCoord: action.toCoord,
                regularMoveChecker: regularMoveChecker,
                eatingMoveChecker: eatingMoveChecker
            )
            
            return newBoardState
        }
        
        fatalError("WHAT?")
    }
    
    
}
