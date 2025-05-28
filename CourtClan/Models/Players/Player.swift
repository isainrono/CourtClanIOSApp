//
//  Player.swift
//  CourtClan
//
//  Created by Isain Rodriguez Noreña on 22/5/25.
//

import Foundation

struct Player: Identifiable, Codable {
    let id: String // player_id en JSON
    let username: String
    let email: String
    let fullName: String? // full_name
    let bio: String?
    
    // Private property to hold the raw URL string from JSON (with extra quotes)
    private let _profilePictureUrl: String?
    
    // Public computed property to provide the cleaned URL string
    var profilePictureUrl: String? {
        // Remove leading and trailing double quotes if they exist
        _profilePictureUrl?.trimmingCharacters(in: CharacterSet(charactersIn: "\""))
    }
    
    let location: String?
    let dateOfBirth: Date? // date_of_birth
    let gender: String?
    let preferredPosition: String? // preferred_position
    let skillLevelId: String? // <-- Already String?
    let currentLevel: Int // current_level
    let totalXp: Int // total_xp
    let gamesPlayed: Int // games_played
    let gamesWon: Int // games_won
    let winPercentage: Double // win_percentage
    let avgPointsPerGame: Double // avg_points_per_game
    let avgAssistsPerGame: Double // avg_assists_per_game
    let avgReboundsPerGame: Double // avg_rebounds_per_game
    let avgBlocksPerGame: Double // avg_blocks_per_game
    let avgStealsPerGame: Double // avg_steals_per_game
    let isPublic: Bool // is_public
    let isActive: Bool // is_active
    let currentTeamId: String? // current_team_id (nullable UUID)
    let marketValue: Double // market_value
    let isFreeAgent: Bool // is_free_agent
    let lastLogin: Date? // last_login
    let createdAt: Date? // created_at
    let updatedAt: Date?

    // Relación cargada desde Laravel: El `team` asociado al jugador.
    let team: Team?

    enum CodingKeys: String, CodingKey {
        case id = "player_id"
        case username
        case email
        case fullName = "full_name"
        case bio
        case _profilePictureUrl = "profile_picture_url" // Map to the private property
        case location
        case dateOfBirth = "date_of_birth"
        case gender
        case preferredPosition = "preferred_position"
        case skillLevelId = "skill_level_id"
        case currentLevel = "current_level"
        case totalXp = "total_xp"
        case gamesPlayed = "games_played"
        case gamesWon = "games_won"
        case winPercentage = "win_percentage"
        case avgPointsPerGame = "avg_points_per_game"
        case avgAssistsPerGame = "avg_assists_per_game"
        case avgReboundsPerGame = "avg_rebounds_per_game"
        case avgBlocksPerGame = "avg_blocks_per_game"
        case avgStealsPerGame = "avg_steals_per_game"
        case isPublic = "is_public"
        case isActive = "is_active"
        case currentTeamId = "current_team_id"
        case marketValue = "market_value"
        case isFreeAgent = "is_free_agent"
        case lastLogin = "last_login"
        case createdAt = "created_at"
        case updatedAt = "updated_at"
        case team
    }

    // MARK: - Custom Memberwise Initializer for programmatic creation (like Previews)
    // When creating a player manually, pass the clean URL here.
    // It will be stored in _profilePictureUrl and then cleaned again by the computed property.
    // This redundancy is fine for convenience in previews.
    init(id: String, username: String, email: String, fullName: String?, bio: String?, profilePictureUrl: String?, location: String?, dateOfBirth: Date?, gender: String?, preferredPosition: String?, skillLevelId: String?, currentLevel: Int, totalXp: Int, gamesPlayed: Int, gamesWon: Int, winPercentage: Double, avgPointsPerGame: Double, avgAssistsPerGame: Double, avgReboundsPerGame: Double, avgBlocksPerGame: Double, avgStealsPerGame: Double, isPublic: Bool, isActive: Bool, currentTeamId: String?, marketValue: Double, isFreeAgent: Bool, lastLogin: Date?, createdAt: Date?, updatedAt: Date?, team: Team?) {
        self.id = id
        self.username = username
        self.email = email
        self.fullName = fullName
        self.bio = bio
        self._profilePictureUrl = profilePictureUrl // Assign to the private raw property
        self.location = location
        self.dateOfBirth = dateOfBirth
        self.gender = gender
        self.preferredPosition = preferredPosition
        self.skillLevelId = skillLevelId
        self.currentLevel = currentLevel
        self.totalXp = totalXp
        self.gamesPlayed = gamesPlayed
        self.gamesWon = gamesWon
        self.winPercentage = winPercentage
        self.avgPointsPerGame = avgPointsPerGame
        self.avgAssistsPerGame = avgAssistsPerGame
        self.avgReboundsPerGame = avgReboundsPerGame
        self.avgBlocksPerGame = avgBlocksPerGame
        self.avgStealsPerGame = avgStealsPerGame
        self.isPublic = isPublic
        self.isActive = isActive
        self.currentTeamId = currentTeamId
        self.marketValue = marketValue
        self.isFreeAgent = isFreeAgent
        self.lastLogin = lastLogin
        self.createdAt = createdAt
        self.updatedAt = updatedAt
        self.team = team
    }

    // MARK: - Custom Decoder for JSON parsing
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)

        id = try container.decode(String.self, forKey: .id)
        username = try container.decode(String.self, forKey: .username)
        email = try container.decode(String.self, forKey: .email)
        fullName = try container.decodeIfPresent(String.self, forKey: .fullName)
        bio = try container.decodeIfPresent(String.self, forKey: .bio)
        
        // Decode the raw string into _profilePictureUrl
        _profilePictureUrl = try container.decodeIfPresent(String.self, forKey: ._profilePictureUrl)
        
        location = try container.decodeIfPresent(String.self, forKey: .location)
        dateOfBirth = try container.decodeIfPresent(Date.self, forKey: .dateOfBirth)
        gender = try container.decodeIfPresent(String.self, forKey: .gender)
        preferredPosition = try container.decodeIfPresent(String.self, forKey: .preferredPosition)
        skillLevelId = try container.decodeIfPresent(String.self, forKey: .skillLevelId)
        currentLevel = try container.decode(Int.self, forKey: .currentLevel)
        totalXp = try container.decode(Int.self, forKey: .totalXp)
        gamesPlayed = try container.decode(Int.self, forKey: .gamesPlayed)
        gamesWon = try container.decode(Int.self, forKey: .gamesWon)

        // --- INICIO: Decodificación manual para Double que viene como String ---
        let winPercentageString = try container.decode(String.self, forKey: .winPercentage)
        guard let winPercentageDouble = Double(winPercentageString) else {
            throw DecodingError.dataCorruptedError(forKey: .winPercentage,
                                                  in: container,
                                                  debugDescription: "Cannot convert win_percentage string \"\(winPercentageString)\" to Double")
        }
        winPercentage = winPercentageDouble

        let avgPointsPerGameString = try container.decode(String.self, forKey: .avgPointsPerGame)
        guard let avgPointsPerGameDouble = Double(avgPointsPerGameString) else {
            throw DecodingError.dataCorruptedError(forKey: .avgPointsPerGame,
                                                  in: container,
                                                  debugDescription: "Cannot convert avg_points_per_game string \"\(avgPointsPerGameString)\" to Double")
        }
        avgPointsPerGame = avgPointsPerGameDouble

        let avgAssistsPerGameString = try container.decode(String.self, forKey: .avgAssistsPerGame)
        guard let avgAssistsPerGameDouble = Double(avgAssistsPerGameString) else {
            throw DecodingError.dataCorruptedError(forKey: .avgAssistsPerGame,
                                                  in: container,
                                                  debugDescription: "Cannot convert avg_assists_per_game string \"\(avgAssistsPerGameString)\" to Double")
        }
        avgAssistsPerGame = avgAssistsPerGameDouble

        let avgReboundsPerGameString = try container.decode(String.self, forKey: .avgReboundsPerGame)
        guard let avgReboundsPerGameDouble = Double(avgReboundsPerGameString) else {
            throw DecodingError.dataCorruptedError(forKey: .avgReboundsPerGame,
                                                  in: container,
                                                  debugDescription: "Cannot convert avg_rebounds_per_game string \"\(avgReboundsPerGameString)\" to Double")
        }
        avgReboundsPerGame = avgReboundsPerGameDouble

        let avgBlocksPerGameString = try container.decode(String.self, forKey: .avgBlocksPerGame)
        guard let avgBlocksPerGameDouble = Double(avgBlocksPerGameString) else {
            throw DecodingError.dataCorruptedError(forKey: .avgBlocksPerGame,
                                                  in: container,
                                                  debugDescription: "Cannot convert avg_blocks_per_game string \"\(avgBlocksPerGameString)\" to Double")
        }
        avgBlocksPerGame = avgBlocksPerGameDouble

        let avgStealsPerGameString = try container.decode(String.self, forKey: .avgStealsPerGame)
        guard let avgStealsPerGameDouble = Double(avgStealsPerGameString) else {
            throw DecodingError.dataCorruptedError(forKey: .avgStealsPerGame,
                                                  in: container,
                                                  debugDescription: "Cannot convert avg_steals_per_game string \"\(avgStealsPerGameString)\" to Double")
        }
        avgStealsPerGame = avgStealsPerGameDouble

        isPublic = try container.decode(Bool.self, forKey: .isPublic)
        isActive = try container.decode(Bool.self, forKey: .isActive)
        currentTeamId = try container.decodeIfPresent(String.self, forKey: .currentTeamId)

        let marketValueString = try container.decode(String.self, forKey: .marketValue)
        guard let marketValueDouble = Double(marketValueString) else {
            throw DecodingError.dataCorruptedError(forKey: .marketValue,
                                                  in: container,
                                                  debugDescription: "Cannot convert market_value string \"\(marketValueString)\" to Double")
        }
        marketValue = marketValueDouble
        // --- FIN: Decodificación manual ---

        isFreeAgent = try container.decode(Bool.self, forKey: .isFreeAgent)
        lastLogin = try container.decodeIfPresent(Date.self, forKey: .lastLogin)
        createdAt = try container.decodeIfPresent(Date.self, forKey: .createdAt)
        updatedAt = try container.decodeIfPresent(Date.self, forKey: .updatedAt)

        team = try container.decodeIfPresent(Team.self, forKey: .team)
    }

    // MARK: - Custom Encoder for JSON encoding (optional, but good practice)
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)

        try container.encode(id, forKey: .id)
        try container.encode(username, forKey: .username)
        try container.encode(email, forKey: .email)
        try container.encodeIfPresent(fullName, forKey: .fullName)
        try container.encodeIfPresent(bio, forKey: .bio)
        
        // When encoding, use the cleaned URL string.
        // If your API expects the extra quotes on sending, you'd need to add them back here.
        // For now, sending the clean URL string is generally what's expected.
        try container.encodeIfPresent(profilePictureUrl, forKey: ._profilePictureUrl) // Use the public computed property

        try container.encodeIfPresent(location, forKey: .location)
        try container.encodeIfPresent(dateOfBirth, forKey: .dateOfBirth)
        try container.encodeIfPresent(gender, forKey: .gender)
        try container.encodeIfPresent(preferredPosition, forKey: .preferredPosition)
        try container.encodeIfPresent(skillLevelId, forKey: .skillLevelId)
        try container.encode(currentLevel, forKey: .currentLevel)
        try container.encode(totalXp, forKey: .totalXp)
        try container.encode(gamesPlayed, forKey: .gamesPlayed)
        try container.encode(gamesWon, forKey: .gamesWon)
        
        // Encode Double as String (matches decode logic)
        try container.encode(String(format: "%.2f", winPercentage), forKey: .winPercentage)
        try container.encode(String(format: "%.2f", avgPointsPerGame), forKey: .avgPointsPerGame)
        try container.encode(String(format: "%.2f", avgAssistsPerGame), forKey: .avgAssistsPerGame)
        try container.encode(String(format: "%.2f", avgReboundsPerGame), forKey: .avgReboundsPerGame)
        try container.encode(String(format: "%.2f", avgBlocksPerGame), forKey: .avgBlocksPerGame)
        try container.encode(String(format: "%.2f", avgStealsPerGame), forKey: .avgStealsPerGame)
        
        try container.encode(isPublic, forKey: .isPublic)
        try container.encode(isActive, forKey: .isActive)
        try container.encodeIfPresent(currentTeamId, forKey: .currentTeamId)
        
        // Encode Double as String (matches decode logic)
        try container.encode(String(format: "%.2f", marketValue), forKey: .marketValue)
        
        try container.encode(isFreeAgent, forKey: .isFreeAgent)
        try container.encodeIfPresent(lastLogin, forKey: .lastLogin)
        try container.encodeIfPresent(createdAt, forKey: .createdAt)
        try container.encodeIfPresent(updatedAt, forKey: .updatedAt)
        
        try container.encodeIfPresent(team, forKey: .team)
    }
}

// MARK: - Extension para datos de ejemplo (Previews)
extension Player {
    static var samplePlayers: [Player] = [
        Player(
            id: UUID().uuidString,
            username: "lebron_j",
            email: "lebron@lakers.com",
            fullName: "LeBron James",
            bio: "King James. Living legend of basketball.",
            // IMPORTANT: For previews, ensure this URL is directly usable by URL(string:)
            // It should NOT have the extra quotes from the raw API response.
            profilePictureUrl: "https://isainrodriguez.com/me/images/courtclan/cc.jpeg",
            location: "Los Angeles, CA",
            dateOfBirth: Date().addingTimeInterval(-39 * 365 * 24 * 60 * 60), // Aproximadamente 39 años
            gender: "Male",
            preferredPosition: "Small Forward",
            skillLevelId: UUID().uuidString,
            currentLevel: 99,
            totalXp: 99999,
            gamesPlayed: 1400,
            gamesWon: 900,
            winPercentage: 64.2,
            avgPointsPerGame: 27.2,
            avgAssistsPerGame: 7.3,
            avgReboundsPerGame: 7.5,
            avgBlocksPerGame: 0.8,
            avgStealsPerGame: 1.3,
            isPublic: true,
            isActive: true,
            currentTeamId: UUID().uuidString, // Assign a UUID string
            marketValue: 50000000.0,
            isFreeAgent: false,
            lastLogin: Date(),
            createdAt: Date(),
            updatedAt: Date(),
            team: Team(
                id: UUID().uuidString,
                name: "Los Angeles Lakers",
                description: "An iconic basketball team.",
                logoUrl: "https://example.com/lakers_logo.png", // Example URL for team logo
                ownerUserId: UUID().uuidString,
                captainUserId: UUID().uuidString,
                teamFunds: 10000000.0,
                createdAt: Date(),
                updatedAt: Date()
            )
        ),
        Player(
            id: UUID().uuidString,
            username: "steph_c",
            email: "steph@warriors.com",
            fullName: "Stephen Curry",
            bio: "Greatest shooter of all time.",
            profilePictureUrl: "https://isainrodriguez.com/me/images/courtclan/cc.jpeg", // Using the same placeholder
            location: "San Francisco, CA",
            dateOfBirth: Date().addingTimeInterval(-36 * 365 * 24 * 60 * 60),
            gender: "Male",
            preferredPosition: "Point Guard",
            skillLevelId: UUID().uuidString,
            currentLevel: 98,
            totalXp: 95000,
            gamesPlayed: 1000,
            gamesWon: 650,
            winPercentage: 65.0,
            avgPointsPerGame: 24.5,
            avgAssistsPerGame: 6.5,
            avgReboundsPerGame: 4.5,
            avgBlocksPerGame: 0.2,
            avgStealsPerGame: 1.4,
            isPublic: true,
            isActive: true,
            currentTeamId: UUID().uuidString,
            marketValue: 48000000.0,
            isFreeAgent: false,
            lastLogin: Date(),
            createdAt: Date(),
            updatedAt: Date(),
            team: Team(
                id: UUID().uuidString,
                name: "Golden State Warriors",
                description: "A dominant NBA team.",
                logoUrl: nil,
                ownerUserId: UUID().uuidString,
                captainUserId: UUID().uuidString,
                teamFunds: 9000000.0,
                createdAt: Date(),
                updatedAt: Date()
            )
        ),
        Player(
            id: UUID().uuidString,
            username: "jayson_t",
            email: "jayson@celtics.com",
            fullName: "Jayson Tatum",
            bio: "Future MVP.",
            profilePictureUrl: nil, // Example of a player without a profile picture
            location: "Boston, MA",
            dateOfBirth: Date().addingTimeInterval(-26 * 365 * 24 * 60 * 60),
            gender: "Male",
            preferredPosition: "Small Forward",
            skillLevelId: UUID().uuidString,
            currentLevel: 90,
            totalXp: 80000,
            gamesPlayed: 500,
            gamesWon: 300,
            winPercentage: 60.0,
            avgPointsPerGame: 26.0,
            avgAssistsPerGame: 4.0,
            avgReboundsPerGame: 8.0,
            avgBlocksPerGame: 0.7,
            avgStealsPerGame: 1.0,
            isPublic: true,
            isActive: true,
            currentTeamId: UUID().uuidString,
            marketValue: 35000000.0,
            isFreeAgent: false,
            lastLogin: Date(),
            createdAt: Date(),
            updatedAt: Date(),
            team: Team(
                id: UUID().uuidString,
                name: "Boston Celtics",
                description: "Historic NBA franchise.",
                logoUrl: nil,
                ownerUserId: UUID().uuidString,
                captainUserId: UUID().uuidString,
                teamFunds: 8000000.0,
                createdAt: Date(),
                updatedAt: Date()
            )
        )
    ]
}
