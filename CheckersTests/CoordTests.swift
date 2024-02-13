//
//  CoordTests.swift
//  CheckersTests
//
//  Created by Petros Tepoyan on 12.02.2024.
//

@testable import Checkers
import XCTest

final class CoordTests: XCTestCase {

    func testNeighboursHasTwo() throws {
        let coord = Coord(row: 2, col: 0)
        let n1 = Coord(row: 1, col: 1)
        let n2 = Coord(row: 3, col: 1)
        XCTAssert(coord.neighbours.contains(n1))
        XCTAssert(coord.neighbours.contains(n2))
    }
    
    func testNeighboursHasFour() throws {
        let coord = Coord(row: 1, col: 1)
        let n1 = Coord(row: 0, col: 0)
        let n2 = Coord(row: 0, col: 2)
        let n3 = Coord(row: 2, col: 0)
        let n4 = Coord(row: 2, col: 2)
        XCTAssert(coord.neighbours.contains(n1))
        XCTAssert(coord.neighbours.contains(n2))
        XCTAssert(coord.neighbours.contains(n3))
        XCTAssert(coord.neighbours.contains(n4))
    }
    
}
