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

    // Private property to hold the raw URL string from JSON (con comillas extra)
    private let _profilePictureUrl: String?

    // Public computed property to provide the cleaned URL string
    var profilePictureUrl: String? {
        // Eliminar comillas dobles iniciales y finales si existen
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
    let winPercentage: Double // win_percentage  <-- La propiedad sigue siendo Double
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
    // (Mantén este inicializador como está, ya que se usa para crear instancias en el código)
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

        // --- CORRECCIÓN AQUÍ: INTENTA DECODIFICAR COMO DOUBLE, SI FALLA, INTENTA COMO STRING Y CONVIERTE ---
        do {
            winPercentage = try container.decode(Double.self, forKey: .winPercentage)
        } catch DecodingError.typeMismatch {
            // Si es un String, decodifica como String y luego convierte
            let winPercentageString = try container.decode(String.self, forKey: .winPercentage)
            guard let doubleValue = Double(winPercentageString) else {
                throw DecodingError.dataCorruptedError(forKey: .winPercentage,
                                                       in: container,
                                                       debugDescription: "Cannot convert String \"\(winPercentageString)\" to Double for winPercentage.")
            }
            winPercentage = doubleValue
        }
        
        do {
            avgPointsPerGame = try container.decode(Double.self, forKey: .avgPointsPerGame)
        } catch DecodingError.typeMismatch {
            let avgPointsPerGameString = try container.decode(String.self, forKey: .avgPointsPerGame)
            guard let doubleValue = Double(avgPointsPerGameString) else {
                throw DecodingError.dataCorruptedError(forKey: .avgPointsPerGame, in: container, debugDescription: "Cannot convert String \"\(avgPointsPerGameString)\" to Double for avgPointsPerGame.")
            }
            avgPointsPerGame = doubleValue
        }

        do {
            avgAssistsPerGame = try container.decode(Double.self, forKey: .avgAssistsPerGame)
        } catch DecodingError.typeMismatch {
            let avgAssistsPerGameString = try container.decode(String.self, forKey: .avgAssistsPerGame)
            guard let doubleValue = Double(avgAssistsPerGameString) else {
                throw DecodingError.dataCorruptedError(forKey: .avgAssistsPerGame, in: container, debugDescription: "Cannot convert String \"\(avgAssistsPerGameString)\" to Double for avgAssistsPerGame.")
            }
            avgAssistsPerGame = doubleValue
        }

        do {
            avgReboundsPerGame = try container.decode(Double.self, forKey: .avgReboundsPerGame)
        } catch DecodingError.typeMismatch {
            let avgReboundsPerGameString = try container.decode(String.self, forKey: .avgReboundsPerGame)
            guard let doubleValue = Double(avgReboundsPerGameString) else {
                throw DecodingError.dataCorruptedError(forKey: .avgReboundsPerGame, in: container, debugDescription: "Cannot convert String \"\(avgReboundsPerGameString)\" to Double for avgReboundsPerGame.")
            }
            avgReboundsPerGame = doubleValue
        }

        do {
            avgBlocksPerGame = try container.decode(Double.self, forKey: .avgBlocksPerGame)
        } catch DecodingError.typeMismatch {
            let avgBlocksPerGameString = try container.decode(String.self, forKey: .avgBlocksPerGame)
            guard let doubleValue = Double(avgBlocksPerGameString) else {
                throw DecodingError.dataCorruptedError(forKey: .avgBlocksPerGame, in: container, debugDescription: "Cannot convert String \"\(avgBlocksPerGameString)\" to Double for avgBlocksPerGame.")
            }
            avgBlocksPerGame = doubleValue
        }

        do {
            avgStealsPerGame = try container.decode(Double.self, forKey: .avgStealsPerGame)
        } catch DecodingError.typeMismatch {
            let avgStealsPerGameString = try container.decode(String.self, forKey: .avgStealsPerGame)
            guard let doubleValue = Double(avgStealsPerGameString) else {
                throw DecodingError.dataCorruptedError(forKey: .avgStealsPerGame, in: container, debugDescription: "Cannot convert String \"\(avgStealsPerGameString)\" to Double for avgStealsPerGame.")
            }
            avgStealsPerGame = doubleValue
        }
        // --- FIN CORRECCIÓN ---

        isPublic = try container.decode(Bool.self, forKey: .isPublic)
        isActive = try container.decode(Bool.self, forKey: .isActive)
        currentTeamId = try container.decodeIfPresent(String.self, forKey: .currentTeamId)

        // --- CORRECCIÓN AQUÍ: DECODIFICAR marketValue también de la misma manera ---
        do {
            marketValue = try container.decode(Double.self, forKey: .marketValue)
        } catch DecodingError.typeMismatch {
            let marketValueString = try container.decode(String.self, forKey: .marketValue)
            guard let doubleValue = Double(marketValueString) else {
                throw DecodingError.dataCorruptedError(forKey: .marketValue,
                                                       in: container,
                                                       debugDescription: "Cannot convert String \"\(marketValueString)\" to Double for marketValue.")
            }
            marketValue = doubleValue
        }
        // --- FIN CORRECCIÓN ---

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

        // Cuando codificas, usa la URL limpia.
        // Si tu API espera las comillas extras al enviar, necesitarías agregarlas aquí.
        // Por ahora, enviar la cadena de URL limpia es generalmente lo esperado.
        try container.encodeIfPresent(profilePictureUrl, forKey: ._profilePictureUrl) // Usa la propiedad computada pública

        try container.encodeIfPresent(location, forKey: .location)
        try container.encodeIfPresent(dateOfBirth, forKey: .dateOfBirth)
        try container.encodeIfPresent(gender, forKey: .gender)
        try container.encodeIfPresent(preferredPosition, forKey: .preferredPosition)
        try container.encodeIfPresent(skillLevelId, forKey: .skillLevelId)
        try container.encode(currentLevel, forKey: .currentLevel)
        try container.encode(totalXp, forKey: .totalXp)
        try container.encode(gamesPlayed, forKey: .gamesPlayed)
        try container.encode(gamesWon, forKey: .gamesWon)

        // Codifica Double como Double, a menos que tu API *realmente* espere un String al enviar.
        // Lo más común es enviar números como números.
        try container.encode(winPercentage, forKey: .winPercentage)
        try container.encode(avgPointsPerGame, forKey: .avgPointsPerGame)
        try container.encode(avgAssistsPerGame, forKey: .avgAssistsPerGame)
        try container.encode(avgReboundsPerGame, forKey: .avgReboundsPerGame)
        try container.encode(avgBlocksPerGame, forKey: .avgBlocksPerGame)
        try container.encode(avgStealsPerGame, forKey: .avgStealsPerGame)

        try container.encode(isPublic, forKey: .isPublic)
        try container.encode(isActive, forKey: .isActive)
        try container.encodeIfPresent(currentTeamId, forKey: .currentTeamId)

        try container.encode(marketValue, forKey: .marketValue)

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
            winPercentage: 64.2, // Asegúrate de que los datos de muestra sean Double
            avgPointsPerGame: 27.2,
            avgAssistsPerGame: 7.3,
            avgReboundsPerGame: 7.5,
            avgBlocksPerGame: 0.8,
            avgStealsPerGame: 1.3,
            isPublic: true,
            isActive: true,
            currentTeamId: UUID().uuidString,
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
