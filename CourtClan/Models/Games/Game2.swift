//
//  Game2.swift
//  CourtClan
//
//  Created by Isain Rodriguez Noreña on 21/7/25.
//

import Foundation

// MARK: - Enumeraciones
enum GameType: String, Codable {
    case oneVsOne = "one_vs_one"
    case teamGame = "team_game"
}

enum GameStatus: String, Codable {
    case scheduled
    case inProgress = "in_progress"
    case finished
    case postponed
    case cancelled
}


// MARK: - Modelo Game2 principal
struct Game2: Codable, Identifiable, Equatable {
    static func == (lhs: Game2, rhs: Game2) -> Bool {
        return lhs.id == rhs.id
    }
    
    let id: String
    let date: Date
    let startTime: Date
    let endTime: Date?
    let gameType: GameType
    let gameStatus: GameStatus
    let homeScore: Int?
    let awayScore: Int?
    let winnerId: String?
    
    let court: Court?
    let event: Event?
    
    let player1: Player?
    let player2: Player?
    
    let homeTeam: Team?
    let awayTeam: Team?
    
    enum CodingKeys: String, CodingKey {
        case id = "game_id"
        case date
        case startTime = "start_time"
        case endTime = "end_time"
        case gameType = "game_type"
        case gameStatus = "game_status"
        case homeScore = "home_score"
        case awayScore = "away_score"
        case winnerId = "winner_id"
        case court
        case event
        case player1
        case player2
        case homeTeam = "home_team"
        case awayTeam = "away_team"
    }
    func formattedDate() -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "dd/MM/yyyy"
        return formatter.string(from: self.date)
    }
    func formattedStartTime() -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm"
        return formatter.string(from: self.startTime)
    }
}



