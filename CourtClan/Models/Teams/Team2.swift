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

extension Team2 {
    static let mockTeams: [Team2] = [
        Team2(
            id: "team001",
            name: "Thunderbolts",
            description: "Equipo competitivo de la liga urbana",
            logoURL: nil,
            captainPlayerId: "player001",
            ownerPlayerId: "player002",
            teamFunds: "1500",
            createdAt: "2025-06-01T12:00:00Z",
            updatedAt: "2025-07-01T12:00:00Z",
            players: nil,
            teamMembers: nil
        ),
        Team2(
            id: "team002",
            name: "SkyHawks",
            description: "Orgullo de la zona norte",
            logoURL: "https://example.com/logo2.png",
            captainPlayerId: "player003",
            ownerPlayerId: "player004",
            teamFunds: "980",
            createdAt: "2025-05-15T10:30:00Z",
            updatedAt: "2025-06-20T09:45:00Z",
            players: nil,
            teamMembers: nil
        ),
        Team2(
            id: "team003",
            name: "Rim Warriors",
            description: "Jugamos con pasión",
            logoURL: "https://example.com/logo3.png",
            captainPlayerId: "player005",
            ownerPlayerId: "player006",
            teamFunds: "2030",
            createdAt: "2025-04-10T08:00:00Z",
            updatedAt: "2025-07-10T11:15:00Z",
            players: nil,
            teamMembers: nil
        )
    ]
}
