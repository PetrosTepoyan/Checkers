
import SwiftUI

struct GameView: View {
    
    @ObservedObject var boardViewModel: BoardViewModel = .init()
    
    var body: some View {
        ZStack {
            
            if boardViewModel.currentPlayer == .black {
                CurrentTurnView()
            }
            
            BoardView(viewModel: boardViewModel)
                .aspectRatio(contentMode: .fit)
            
            if boardViewModel.currentPlayer == .black {
                CurrentTurnView()
            }
        }
    }
}
