//
//  Team2.swift
//  CourtClan
//
//  Created by Isain Rodriguez Noreña on 21/7/25.
//

import Foundation

struct Team2: Codable, Identifiable {
    let id: String                // ← Lo usamos como Identifiable
    let name: String
    let description: String
    let logoURL: String?
    let captainPlayerId: String
    let ownerPlayerId: String
    let teamFunds: String
    let createdAt: String
    let updatedAt: String
    
    let players: [Player]?
    let teamMembers: [TeamMember]?
    
    enum CodingKeys: String, CodingKey {
        case id = "team_id"
        case name
        case description
        case logoURL = "logo_url"
        case captainPlayerId = "captain_player_id"
        case ownerPlayerId = "owner_player_id"
        case teamFunds = "team_funds"
        case createdAt = "created_at"
        case updatedAt = "updated_at"
        case players, teamMembers
    }
}

struct TeamsResponse: Decodable {
    let teams: [Team2]
}

struct TeamWithPlayersSimple {
    let team: Team2
    let players: [SimplePlayer]
}
