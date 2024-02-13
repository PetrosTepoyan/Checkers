//
//  File.swift
//  Checkers
//
//  Created by Petros Tepoyan on 10.02.2024.
//

import Foundation

struct Coord: Hashable, CustomStringConvertible {
    
    let row: Int
    let col: Int
    
    var description: String {
        "(\(row + 1), \(col + 1))"
    }
    
    var neighbours: Set<Coord> {
        var set = Set<Coord>()
        if let leftUp = leftUp() { set.update(with: leftUp) }
        if let rightUp = rightUp() { set.update(with: rightUp) }
        if let leftBottom = leftBottom() { set.update(with: leftBottom) }
        if let rightBottom = rightBottom() { set.update(with: rightBottom) }
        return set
    }
    
    func leftUp() -> Coord? {
        guard row + 1 >= 0,
              col - 1 >= 0,
              row + 1 <= Config.rowCount,
              col - 1 <= Config.colCount
        else { return nil }
        return Coord(row: row + 1, col: col - 1)
    }
    
    func rightUp() -> Coord? {
        guard row + 1 >= 0,
              col + 1 >= 0,
              row + 1 <= Config.rowCount,
              col + 1 <= Config.colCount
        else { return nil }
        return Coord(row: row + 1, col: col + 1)
    }
    
    func leftBottom() -> Coord? {
        guard row - 1 >= 0,
              col - 1 >= 0,
              row - 1 <= Config.rowCount,
              col - 1 <= Config.colCount
        else { return nil }
        return Coord(row: row - 1, col: col - 1)
    }
    
    func rightBottom() -> Coord? {
        guard row - 1 >= 0,
              col + 1 >= 0,
              row - 1 <= Config.rowCount,
              col + 1 <= Config.colCount
        else { return nil }
        return Coord(row: row - 1, col: col + 1)
    }
}
