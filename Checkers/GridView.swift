//
//  GridView.swift
//  Checkers
//
//  Created by Petros Tepoyan on 10.02.2024.
//

import SwiftUI

struct GridView<Content: View>: View {
    
    @ViewBuilder var content: (Coord, GeometryProxy) -> Content
    
    var body: some View {
        GeometryReader { geo in
            VStack(spacing: 0) {
                ForEach(0..<Config.colCount, id: \.self) { row in
                    HStack(spacing: 0) {
                        ForEach(0..<Config.rowCount, id: \.self) { col in
                            let coord = Coord(row: row, col: col)
                            content(coord, geo)
                        }
                    }
                }
            }
        }
    }
}
