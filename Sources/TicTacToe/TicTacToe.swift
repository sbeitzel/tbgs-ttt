//
//  TicTacToe.swift
//  
//
//  Created by Stephen Beitzel on 12/28/21.
//

import Foundation
import TBGSLib

public struct TicTacToe: Game, Identifiable {
    static let gameID = UUID(uuidString: "dbdb058a-683a-11ec-af72-3255e3a210ef")!

    public var id: UUID {
        TicTacToe.gameID
    }

    public var shortName: String {
        "Tic-tac-toe (naughts and crosses)"
    }

    public var description: String {
        "The classic placemat game which a skilled player can never lose"
    }

    public func newMatch(playerOne: UUID) -> Match {
        let match = TTTMatch()
        match.add(player: playerOne)
        return match
    }

    public func restoreMatch(data: Data) throws -> Match {
        let decoder = JSONDecoder()
        return try decoder.decode(TTTMatch.self, from: data)
    }

    public func acceptSubmission(for state: Match, from player: UUID, of turn: Data) throws -> Int {
        guard let match = state as? TTTMatch else { throw TBGSError.invalidEntity }
        guard match.isTurn(for: player) else { throw TBGSError.notTurnForPlayer }
        let submission = try JSONDecoder().decode(TurnSubmission.self, from: turn)
        guard submission.player == player else { throw TBGSError.notTurnForPlayer }
        guard submission.sequenceNumber == match.currentTurnSequence + 1 else { throw TBGSError.turnOutOfSequence }
        return submission.sequenceNumber
    }

    public func processTurn(match: Match, playerTurns: [PlayerTurn]) throws -> TurnResult {
        guard let match = match as? TTTMatch else { throw TBGSError.incorrectDataFormat }
        guard playerTurns.count == 1 else { throw TBGSError.incorrectDataFormat }
        guard let turn = playerTurns.first else { throw TBGSError.incorrectDataFormat }
        return try submit(match: match, player: turn.playerID, turn: turn.turnData)
    }

    public func isReadyToProcess(match: Match, playerTurns: [PlayerTurn]) -> Bool {
        return playerTurns.count == 1 && match.isFull
    }

    private func submit(match: TTTMatch, player: UUID, turn: Data) throws -> TurnResult {
        guard match.isTurn(for: player) else { throw TBGSError.notTurnForPlayer }
        let submission = try JSONDecoder().decode(TurnSubmission.self, from: turn)
        guard submission.player == player else { throw TBGSError.notTurnForPlayer }
        guard submission.sequenceNumber == match.currentTurnSequence + 1 else { throw TBGSError.turnOutOfSequence }
        guard (0...8).contains(submission.square) else { throw TBGSError.invalidMove }
        guard match.board[submission.square] == -1 else { throw TBGSError.invalidMove }
        try match.move(by: player, at: submission.square)
        let winner = findAWin(match.board)
        switch winner {
        case -1: // no winner
            if match.board.filter({$0 == -1}).isEmpty {
                // no open spaces - it's a tie
                return TurnResult(state: .tied, players: match.players)
            } else {
                // in progress, next player's turn
                return TurnResult(state: .inProgress, players: [match.players[match.currentPlayer]])
            }
        default: // there's a winner
            return TurnResult(state: .won, players: [match.players[winner]])
        }
    }

    private func findAWin(_ board: [Int]) -> Int {
        // top row
        if (board[0] == board[1] && board[1] == board[2] && board[0] > -1) {
            return board[0];
        }
        // middle row
        if (board[3] == board[4] && board[4] == board[5] && board[3] > -1) {
            return board[3];
        }
        // bottom row
        if (board[6] == board[7] && board[7] == board[8] && board[6] > -1) {
            return board[6];
        }
        // left column
        if (board[0] == board[3] && board[3] == board[6] && board[0] > -1) {
            return board[0];
        }
        // middle column
        if (board[1] == board[4] && board[4] == board[7] && board[1] > -1) {
            return board[1];
        }
        // right column
        if (board[2] == board[5] && board[5] == board[8] && board[2] > -1) {
            return board[2];
        }
        // diagonal, TL -> BR
        if (board[0] == board[4] && board[4] == board[8] && board[0] > -1) {
            return board[0];
        }
        // diagonal, TR -> BL
        if (board[2] == board[4] && board[4] == board[6] && board[2] > -1) {
            return board[2];
        }
        // no winner
        return -1;
    }
}

// MARK: Plugin creation entry point

/// This is the function that the server is going to be looking for, to load this game
@_cdecl("createGamePlugin")
public func createGamePlugin() -> UnsafeMutableRawPointer {
    return Unmanaged.passRetained(TicTacToeBuilder()).toOpaque()
}

final class TicTacToeBuilder: GameBuilder {
    override func build() -> Game {
        TicTacToe()
    }
}
