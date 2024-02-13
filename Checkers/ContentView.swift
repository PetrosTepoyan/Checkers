//
//  ContentView.swift
//  Checkers
//
//  Created by Petros Tepoyan on 10.02.2024.
//

import SwiftUI

struct PieceView: View {
    
    let piece: Piece
    
    var body: some View {
        GeometryReader { geo in
            let side = geo.size.width
            ZStack {
                Circle()
                    .fill(piece.isWhite ? .white : .brown)
                
                Circle()
                    .fill(
                        .shadow(.inner(color: .black.opacity(0.7), radius: 3, x: -4, y: -4)).tertiary
                    )
                
                Circle()
                    .fill(
                        .shadow(.drop(color: .black.opacity(0.3), radius: 3, x: 4, y: 4)).tertiary
                    )
            }
            .frame(width: side, height: side)
                
        }
    }
}

#Preview {
    HStack {
        ForEach(0...8, id: \.self) { i in
            PieceView(piece: .init(.b1))
        }
    }
    
//        .padding()
}
