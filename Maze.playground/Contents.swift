//: Playground - noun: a place where people can play

import Foundation
import GameKit

extension Array {
    
    func shuffled() -> [Element] {
        return (self as NSArray).shuffled() as! [Element]
    }
    
}

struct Direction: OptionSet {
    
    let rawValue: Int
    
    static let none = Direction(rawValue: 1 << 0)
    static let up = Direction(rawValue: 1 << 1)
    static let down = Direction(rawValue: 1 << 2)
    static let left = Direction(rawValue: 1 << 3)
    static let right = Direction(rawValue: 1 << 4)
    
    static let all: Array<Direction> = [.up, .down, .left, .right]
    
    var opposite: Direction {
        switch self {
        case Direction.up: return .down
        case Direction.down: return .up
        case Direction.left: return .right
        case Direction.right: return .left
        default: return .none
        }
    }
    
    var diff: Position {
        switch self {
        case Direction.up: return Position(0, -1)
        case Direction.down: return Position(0, 1)
        case Direction.left: return Position(-1, 0)
        case Direction.right: return Position(1, 0)
        default: return Position(0, 0)
        }
    }
    
    var char: String {
        switch self {
        case Direction.up: return "U"
        case Direction.down: return "D"
        case Direction.left: return "L"
        case Direction.right: return "R"
        default: return ""
        }
    }
    
    mutating func add(direction: Direction) {
        self = union(direction)
    }
    
}

public struct Position {
    
    let x: Int
    let y: Int
    
    public init(_ x: Int, _ y: Int) {
        self.x = x
        self.y = y
    }
    
    static func + (lhs: Position, rhs: Position) -> Position {
        return Position(lhs.x + rhs.x, lhs.y + rhs.y)
    }
    
}

public struct Maze {
    
    let width: Int
    let height: Int
    var cells: [[Direction]]
    
    public init(_ width: Int, _ height: Int) {
        self.width = width
        self.height = height
        let column = [Direction](repeating: Direction.none, count: height)
        cells = [[Direction]](repeating: column, count: width)
        generate(from: Position(0, 0))
    }
    
    private mutating func generate(from current: Position) {
        let directions = Direction.all.shuffled()
        directions.forEach { (direction: Direction) in
            let next = current + direction.diff
            if self ~= next, !isVisited(position: next) {
                link(from: current, to: next, direction: direction)
                generate(from: next)
            }
        }
    }
    
    mutating func link(from origin: Position, to end: Position, direction: Direction) {
        cells[origin.x][origin.y].add(direction: direction)
        cells[end.x][end.y].add(direction: direction.opposite)
    }
    
    func isVisited(position: Position) -> Bool {
        return cells[position.x][position.y] != Direction.none
    }
    
}

func ~= (maze: Maze, position: Position) -> Bool {
    return 0..<maze.width ~= position.x && 0..<maze.height ~= position.y
}

extension Maze: CustomStringConvertible {
    
    static let descriptionCellWidth = 3
    
    public var description: String {
        var description = ""
        for y in 0..<height {
            description += topEdgeString(y: y)
            description += leftEdgeString(y: y)
        }
        return description + bottomEdgeString
    }
    
    private func topEdgeString(y: Int) -> String {
        var topEdge = ""
        for x in 0..<width {
            topEdge += "+"
            topEdge += String(repeating: cells[x][y].contains(.up) ? " " : "-", count: Maze.descriptionCellWidth)
        }
        return topEdge + "+\n"
    }
    
    private func leftEdgeString(y: Int) -> String {
        var leftEdge = ""
        for x in 0..<width {
            leftEdge += cells[x][y].contains(.left) ? " " : "|"
            leftEdge += String(repeating: " ", count: Maze.descriptionCellWidth)
        }
        return leftEdge + "|\n"
    }
    
    private var bottomEdgeString: String {
        var bottomEdge = ""
        for _ in 0..<width {
            bottomEdge += "+"
            bottomEdge += String(repeating: "-", count: Maze.descriptionCellWidth)
        }
        return bottomEdge + "+\n"
    }
    
}

let maze = Maze(20, 20)
print(maze)
