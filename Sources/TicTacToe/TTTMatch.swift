//
//  TTTMatch.swift
//  
//
//  Created by Stephen Beitzel on 12/28/21.
//

import Foundation
import TBGSLib


public class TTTMatch: Match, Identifiable, Codable {
    enum CodingKeys: CodingKey {
        case matchID, players, isFull, state, currentTurnSequence, board, currentPlayer
    }

    public var gameID: UUID { TicTacToe.gameID }
    public var id: UUID { matchID }
    public var players = [UUID]()
    public var isFull: Bool = false
    let matchID: UUID
    public var state: MatchState = .inProgress
    public var currentTurnSequence: Int = 0
    public var currentPlayer: Int = 0
    public var board: Array<Int> = Array.init(repeating: -1, count: 9)

    init() {
        matchID = UUID()
    }

    public required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.matchID = try container.decode(UUID.self, forKey: .matchID)
        self.players = try container.decode([UUID].self, forKey: .players)
        self.isFull = try container.decode(Bool.self, forKey: .isFull)
        self.state = try container.decode(MatchState.self, forKey: .state)
        self.currentTurnSequence = try container.decode(Int.self, forKey: .currentTurnSequence)
        self.currentPlayer = try container.decode(Int.self, forKey: .currentPlayer)
        self.board = try container.decode([Int].self, forKey: .board)
    }

    public func move(by player: UUID, at: Int) throws {
        guard let mark: Int = players.firstIndex(of: player) else { throw TBGSError.invalidEntity }
        guard (0...8).contains(at) else { throw TBGSError.invalidMove }
        board[at] = mark
        currentPlayer = 2 - (currentPlayer + 1)
        incrementTurnSequence()
    }

    public func incrementTurnSequence() {
        currentTurnSequence += 1
    }

    @discardableResult public func add(player: UUID) -> Bool {
        guard isFull == false && players.count < 2 && !players.contains(player) else { return false }
        players.append(player)
        if players.count > 1 {
            isFull = true
        }
        return true
    }

    public func encodeForDatabase() throws -> Data {
        let encoder = JSONEncoder()
        return try encoder.encode(self)
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(matchID, forKey: .matchID)
        try container.encode(players, forKey: .players)
        try container.encode(isFull, forKey: .isFull)
        try container.encode(state, forKey: .state)
        try container.encode(currentTurnSequence, forKey: .currentTurnSequence)
        try container.encode(board, forKey: .board)
        try container.encode(currentPlayer, forKey: .currentPlayer)
    }

    public func encode(for player: UUID) throws -> Data {
        guard players.contains(player) else { throw TBGSError.invalidEntity }
        return try encodeForDatabase()
    }

    public func isTurn(for player: UUID) -> Bool {
        guard currentPlayer < players.count else { return false }
        return players[currentPlayer] == player
    }
}
