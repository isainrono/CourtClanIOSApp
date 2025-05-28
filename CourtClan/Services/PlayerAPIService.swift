//
//  Player.swift
//  CourtClan
//
//  Created by Isain Rodriguez Noreña on 22/5/25.
//


import Foundation

// MARK: - Contratos para el Servicio
protocol PlayerServiceProtocol {
    func fetchAllPlayers() async throws -> [Player]
    func fetchPlayer(id: String) async throws -> Player
    func createPlayer(player: PlayerCreateRequest) async throws -> Player
    func updatePlayer(id: String, player: PlayerUpdateRequest) async throws -> Player
    func deletePlayer(id: String) async throws
    // Agrega aquí cualquier otra operación específica de jugadores (ej. login)
}

// MARK: - Implementación del Servicio de API para Players
class PlayerAPIService: PlayerServiceProtocol {
    private let baseURL: String
    private let session: URLSession

    private let jsonDecoder: JSONDecoder = {
        let decoder = JSONDecoder()
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSSSSZ" // Ajusta para microsegundos
        dateFormatter.locale = Locale(identifier: "en_US_POSIX")
        dateFormatter.timeZone = TimeZone(secondsFromGMT: 0)
        decoder.dateDecodingStrategy = .formatted(dateFormatter)
        return decoder
    }()

    private let jsonEncoder: JSONEncoder = {
        let encoder = JSONEncoder()
        encoder.keyEncodingStrategy = .convertToSnakeCase
        encoder.dateEncodingStrategy = .iso8601
        encoder.outputFormatting = .prettyPrinted
        return encoder
    }()

    init(baseURL: String, session: URLSession = .shared) {
        self.baseURL = baseURL
        self.session = session
    }

    private func performRequest<T: Decodable>(url: URL, method: String, body: Data? = nil) async throws -> T {
        var request = URLRequest(url: url)
        request.httpMethod = method
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        if let body = body {
            request.httpBody = body
        }

        let (data, response) = try await session.data(for: request)

        if let jsonString = String(data: data, encoding: .utf8) {
            print("--- RAW API RESPONSE DATA (Players) ---")
            print(jsonString)
            print("---------------------------------------")
        } else {
            print("--- RAW API RESPONSE DATA (Players) --- (Could not decode as UTF-8 string)")
            print(data as NSData)
            print("---------------------------------------")
        }

        guard let httpResponse = response as? HTTPURLResponse else {
            throw APIError.invalidResponse
        }

        /*if !(200...299).contains(httpResponse.statusCode) {
            if let errorData = try? jsonDecoder.decode(APIErrorMessage.self, from: data) {
                throw APIError.serverError(errorData.message)
            } else {
                throw APIError.requestFailed(httpResponse.statusCode)
            }
        }*/

        do {
            return try jsonDecoder.decode(T.self, from: data)
        } catch {
            print("Decoding Error (Players): \(error)")
            throw APIError.decodingError(error)
        }
    }

    private struct APIErrorMessage: Decodable {
        let message: String
    }

    // MARK: - CRUD Operations

    func fetchAllPlayers() async throws -> [Player] {
        guard let url = URL(string: "\(baseURL)/players") else {
            throw APIError.invalidURL
        }
        struct PlayersResponse: Decodable {
            let players: [Player]
        }
        let response: PlayersResponse = try await performRequest(url: url, method: "GET")
        return response.players
    }

    func fetchPlayer(id: String) async throws -> Player {
        guard let url = URL(string: "\(baseURL)/players/\(id)") else {
            throw APIError.invalidURL
        }
        struct PlayerResponse: Decodable {
            let player: Player
        }
        let response: PlayerResponse = try await performRequest(url: url, method: "GET")
        return response.player
    }

    func createPlayer(player: PlayerCreateRequest) async throws -> Player {
        guard let url = URL(string: "\(baseURL)/players") else {
            throw APIError.invalidURL
        }
        let body = try jsonEncoder.encode(player)
        struct CreatePlayerResponse: Decodable {
            let message: String
            let player: Player
            let token: String?
        }
        let response: CreatePlayerResponse = try await performRequest(url: url, method: "POST", body: body)
        print("Player created. Token: \(response.token ?? "N/A")")
        return response.player
    }

    func updatePlayer(id: String, player: PlayerUpdateRequest) async throws -> Player {
        guard let url = URL(string: "\(baseURL)/players/\(id)") else {
            throw APIError.invalidURL
        }
        let body = try jsonEncoder.encode(player)
        struct UpdatePlayerResponse: Decodable {
            let message: String
            let player: Player
        }
        let response: UpdatePlayerResponse = try await performRequest(url: url, method: "PUT", body: body)
        return response.player
    }

    func deletePlayer(id: String) async throws {
        guard let url = URL(string: "\(baseURL)/players/\(id)") else {
            throw APIError.invalidURL
        }
        struct DeleteResponse: Decodable {
            let message: String
        }
        _ = try await performRequest(url: url, method: "DELETE") as DeleteResponse
    }
}

// MARK: - Request Body Structures (Payloads para POST/PUT)

struct PlayerCreateRequest: Codable {
    let username: String
    let email: String
    let passwordHash: String // password_hash (required)
    let fullName: String?
    let bio: String?
    let profilePictureUrl: String?
    let location: String?
    let dateOfBirth: Date?
    let gender: String?
    let preferredPosition: String?
    let skillLevelId: String? // <-- ¡CAMBIO AQUI! De Int? a String?
    let currentLevel: Int?
    let totalXp: Int?
    let gamesPlayed: Int?
    let gamesWon: Int?
    let winPercentage: Double?
    let avgPointsPerGame: Double?
    let avgAssistsPerGame: Double?
    let avgReboundsPerGame: Double?
    let avgBlocksPerGame: Double?
    let avgStealsPerGame: Double?
    let isPublic: Bool?
    let isActive: Bool?
    let currentTeamId: String?
    let marketValue: Double?
    let isFreeAgent: Bool?
    let lastLogin: Date?

    enum CodingKeys: String, CodingKey {
        case username, email
        case passwordHash = "password_hash"
        case fullName = "full_name"
        case bio
        case profilePictureUrl = "profile_picture_url"
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
    }
}

struct PlayerUpdateRequest: Codable {
    let username: String?
    let email: String?
    let passwordHash: String?
    let fullName: String?
    let bio: String?
    let profilePictureUrl: String?
    let location: String?
    let dateOfBirth: Date?
    let gender: String?
    let preferredPosition: String?
    let skillLevelId: String? // <-- ¡CAMBIO AQUI! De Int? a String?
    let currentLevel: Int?
    let totalXp: Int?
    let gamesPlayed: Int?
    let gamesWon: Int?
    let winPercentage: Double?
    let avgPointsPerGame: Double?
    let avgAssistsPerGame: Double?
    let avgReboundsPerGame: Double?
    let avgBlocksPerGame: Double?
    let avgStealsPerGame: Double?
    let isPublic: Bool?
    let isActive: Bool?
    let currentTeamId: String?
    let marketValue: Double?
    let isFreeAgent: Bool?
    let lastLogin: Date?

    enum CodingKeys: String, CodingKey {
        case username, email
        case passwordHash = "password_hash"
        case fullName = "full_name"
        case bio
        case profilePictureUrl = "profile_picture_url"
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
    }
}
