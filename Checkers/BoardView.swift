//
//  Board.swift
//  Checkers
//
//  Created by Petros Tepoyan on 10.02.2024.
//

import SwiftUI

struct BoardView: View {
    
    @ObservedObject var viewModel: BoardViewModel = .init()
    
    @Namespace var namespace
    
    @SwiftUI.State var draggablePiecePosition: CGSize = .zero
    @SwiftUI.State var draggablePieceId: PieceId?
    
    var body: some View {
        ZStack {
            GridView { coord, geo in
                ZStack {
                    Rectangle()
                        .fill(coord.row % 2 == coord.col % 2 ? .white : .black)
                    
                    Group {
                        if viewModel.availableActions[coord] != nil {
                            Rectangle()
                                .fill(.red)
                        }
                    }
                    
                }
                .frame(width: geo.size.width / CGFloat(Config.colCount),
                       height: geo.size.height / CGFloat(Config.rowCount))
            }
            
            GridView { coord, geo in
                Group {
                    if let piece = viewModel.piece(forCoord: coord) {
                        PieceView(piece: piece)
                            .padding(6)
                            .matchedGeometryEffect(id: piece.id, in: namespace,
                                                   properties: .frame,
                                                   anchor: .center, isSource: true)
                            .onTapGesture {
                                viewModel.didTapOnCell(at: coord)
                            }
                        
                    } else {
                        Rectangle()
                            .fill(.clear)
                            .contentShape(Rectangle())
                            .onTapGesture {
                                viewModel.didTapOnCell(at: coord)
                            }
                    }
                }
                .frame(width: geo.size.width / CGFloat(Config.colCount),
                       height: geo.size.width / CGFloat(Config.rowCount))
            }
        }
    }
}

class BoardViewModel: ObservableObject {
    
    @Published var boardState: BoardState = .initial
    
    @Published var availableActions: [Coord : Action] = [:]
    
    var selectedPiece: Piece?
    
    var currentPlayer: Player {
        boardState.player
    }
    
    func piece(forCoord: Coord) -> Piece? {
        boardState.pieceStorage.piece(forCoord: forCoord)
    }
    
    func didTapOnCell(at coord: Coord) {
        // If a piece is selected and we press on the same piece or a non-actionable cell
        // we clean the available actions and the selected piece
        print(1)
        if let selectedPiece {
            
            if let anotherSelectedPiece = piece(forCoord: coord) {
                if selectedPiece == anotherSelectedPiece {
                    removeAvailableActions()
                    print(2)
                    return
                } else {
                    self.selectedPiece = nil
                    didTapOnCell(at: coord)
                    return
                }
                
            }
            
            if let actionToPerform = availableActions[coord] {
                applyAction(actionToPerform)
                removeAvailableActions()
                return
            } else {
                removeAvailableActions()
                print(3)
                return
            }
        }
        
        guard let piece = piece(forCoord: coord) else { return }
        print(4)
        selectedPiece = piece
        
        if (piece.isWhite && boardState.player == .white) || (!piece.isWhite && boardState.player == .black) {
            let actions = boardState.actions(for: coord)
            let mappedActions = actions.reduce(into: [Coord : Action]()) { partialResult, action in
                if let endCoord = action.endCoord {
                    partialResult[endCoord] = action
                }
            }
            
            updateAvailableActions(mappedActions)
        }
    }
    
    func applyAction(_ actionToPerform: Action) {
        print(10)
        withAnimation(.snappy) {
            boardState = boardState.result(action: actionToPerform)
        }
    }
    
    func updateAvailableActions(_ actions: [Coord : Action]) {
        print(7)
        withAnimation(.snappy) {
            availableActions = actions
        }
    }
    
    func removeAvailableActions() {
        print(8)
        withAnimation(.snappy) {
            selectedPiece = nil
            availableActions.removeAll()
        }
    }
}

#Preview {
    BoardView()
        .aspectRatio(1, contentMode: .fit)
}





