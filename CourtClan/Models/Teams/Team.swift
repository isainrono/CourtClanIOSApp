//
//  Team.swift
//  CourtClan
//
//  Created by Isain Rodriguez Noreña on 21/5/25.
//


import Foundation

struct Team: Identifiable, Codable {
    let id: String // Esta es tu propiedad Swift, mapea a 'team_id'
    let name: String
    let description: String?
    let logoUrl: String? // logo_url en JSON
    let ownerUserId: String // owner_player_id en JSON
    let captainUserId: String? // captain_player_id en JSON
    let teamFunds: Double // team_funds en JSON (como String)
    let createdAt: Date?
    let updatedAt: Date?
    
    // Definimos explícitamente las CodingKeys para los campos que no siguen
    // la convención camelCase de Swift a snake_case de JSON, O
    // para campos que requieren un manejo especial (como team_funds de String a Double).
    enum CodingKeys: String, CodingKey {
        case id = "team_id" // <--- Mantén esta línea para mapear 'id' a 'team_id'
        case name, description // Estos se mapearán automáticamente si no hay conflicto y .convertFromSnakeCase está activo
        case logoUrl = "logo_url"
        case ownerUserId = "owner_player_id" // Tu API devuelve 'owner_player_id'
        case captainUserId = "captain_player_id" // Tu API devuelve 'captain_player_id'
        case teamFunds = "team_funds"
        case createdAt = "created_at"
        case updatedAt = "updated_at"
    }
    
    // MARK: - Custom Memberwise Initializer for programmatic creation (like Previews)
    // Añadimos este inicializador para poder crear instancias de Team directamente
    init(id: String, name: String, description: String?, logoUrl: String?, ownerUserId: String, captainUserId: String?, teamFunds: Double, createdAt: Date?, updatedAt: Date?) {
        self.id = id
        self.name = name
        self.description = description
        self.logoUrl = logoUrl
        self.ownerUserId = ownerUserId
        self.captainUserId = captainUserId
        self.teamFunds = teamFunds
        self.createdAt = createdAt
        self.updatedAt = updatedAt
    }
    
    // MARK: - Custom Decoder para manejar team_funds como String y el mapeo explícito
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        // Decodificación explícita de id (team_id)
        id = try container.decode(String.self, forKey: .id)
        
        // Decodificación de otros campos. Aquí .convertFromSnakeCase ayudará
        // SI no hay una CodingKey definida explícitamente para ellos,
        // o si la CodingKey explícita es necesaria (como logoUrl).
        name = try container.decode(String.self, forKey: .name)
        description = try container.decodeIfPresent(String.self, forKey: .description)
        logoUrl = try container.decodeIfPresent(String.self, forKey: .logoUrl)
        ownerUserId = try container.decode(String.self, forKey: .ownerUserId)
        captainUserId = try container.decodeIfPresent(String.self, forKey: .captainUserId)
        
        // Decodificar teamFunds como String y convertirlo a Double
        let teamFundsString = try container.decode(String.self, forKey: .teamFunds)
        if let funds = Double(teamFundsString) {
            teamFunds = funds
        } else {
            throw DecodingError.dataCorruptedError(forKey: .teamFunds,
                                                  in: container,
                                                  debugDescription: "Cannot decode 'team_funds' as Double from string \"\(teamFundsString)\"")
        }
        
        createdAt = try container.decodeIfPresent(Date.self, forKey: .createdAt)
        updatedAt = try container.decodeIfPresent(Date.self, forKey: .updatedAt)
    }
    
    // MARK: - Custom Encoder para manejar la codificación de teamFunds a String
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        
        // Codificación explícita de id
        try container.encode(id, forKey: .id)
        
        // Codificación de otros campos
        try container.encode(name, forKey: .name)
        try container.encodeIfPresent(description, forKey: .description)
        try container.encodeIfPresent(logoUrl, forKey: .logoUrl)
        try container.encode(ownerUserId, forKey: .ownerUserId)
        try container.encodeIfPresent(captainUserId, forKey: .captainUserId)
        
        // Codificar teamFunds como String
        try container.encode(String(format: "%.2f", teamFunds), forKey: .teamFunds)
        
        try container.encodeIfPresent(createdAt, forKey: .createdAt)
        try container.encodeIfPresent(updatedAt, forKey: .updatedAt)
    }
}

// MARK: - Extension para datos de ejemplo (Previews)
extension Team {
    static var sampleTeams: [Team] = [
        Team(
            id: UUID().uuidString,
            name: "Los Angeles Lakers",
            description: "An iconic basketball team.",
            logoUrl: "https://example.com/lakers_logo.png",
            ownerUserId: UUID().uuidString,
            captainUserId: UUID().uuidString,
            teamFunds: 10000000.0,
            createdAt: Date(),
            updatedAt: Date()
        ),
        Team(
            id: UUID().uuidString,
            name: "Golden State Warriors",
            description: nil,
            logoUrl: nil,
            ownerUserId: UUID().uuidString,
            captainUserId: nil,
            teamFunds: 7500000.0,
            createdAt: Date(),
            updatedAt: Date()
        )
    ]
}
