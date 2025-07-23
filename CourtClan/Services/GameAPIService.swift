//
//  GameAPIService.swift
//  CourtClan
//
//  Created by Isain Rodriguez Noreña on 20/6/25.
//

import Foundation



// MARK: - Contratos para el Servicio de Partidos
protocol GameServiceProtocol {
    func fetchAllGames(page: Int?, limit: Int?) async throws -> PagedResponse<Game>
    func fetchGame(id: String) async throws -> Game
    func createGame(game: GameCreateRequest) async throws -> Game
    func updateGame(id: String, game: GameUpdateRequest) async throws -> Game
    func deleteGame(id: String) async throws
    func finalizeGame(id: String, homeScore: Int, awayScore: Int) async throws -> Game
    func fetchGamesByStatus(status: Game.GameStatus, page: Int?, limit: Int?) async throws -> PagedResponse<Game>
    func fetchMyGames(playerId: String, page: Int?, limit: Int?) async throws -> PagedResponse<Game>
}

// MARK: - Implementación del Servicio de API para Games
class GameAPIService: GameServiceProtocol {
    private let baseURL: String
    private let session: URLSession

    // Reutiliza el decodificador personalizado que maneja las fechas de Laravel.
    private let jsonDecoder: JSONDecoder = .customLaravelDecoder

    // Reutiliza el codificador que convierte a snake_case y usa ISO8601 para fechas.
    private let jsonEncoder: JSONEncoder = {
        let encoder = JSONEncoder()
        encoder.keyEncodingStrategy = .convertToSnakeCase
        encoder.dateEncodingStrategy = .iso8601 // Usar ISO8601 para enviar fechas
        encoder.outputFormatting = .prettyPrinted // Para depuración, puedes quitarlo en producción
        return encoder
    }()

    // MARK: - Inicialización
    init(baseURL: String, session: URLSession = .shared) {
        self.baseURL = baseURL
        self.session = session
    }

    // MARK: - Función Genérica para Realizar Solicitudes
    // Centraliza la lógica de red, manejo de errores y decodificación.
    private func performRequest<T: Decodable>(url: URL, method: String, body: Data? = nil) async throws -> T {
        var request = URLRequest(url: url)
        request.httpMethod = method
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        // Aquí podrías añadir un token de autorización si lo manejas
        // if let authToken = AuthManager.shared.authToken {
        //     request.setValue("Bearer \(authToken)", forHTTPHeaderField: "Authorization")
        // }

        if let body = body {
            request.httpBody = body
        }

        let (data, response) = try await session.data(for: request)

        // Impresión de respuesta RAW para depuración
        if let jsonString = String(data: data, encoding: .utf8) {
            print("--- RAW API RESPONSE DATA (Games) ---")
            print(jsonString)
            print("---------------------------------------")
        } else {
            print("--- RAW API RESPONSE DATA (Games) --- (Could not decode as UTF-8 string)")
            print(data as NSData)
            print("---------------------------------------")
        }

        guard let httpResponse = response as? HTTPURLResponse else {
            throw APIError.invalidResponse
        }

        // Manejo de códigos de estado HTTP
        /*if !(200...299).contains(httpResponse.statusCode) {
            if let errorData = try? jsonDecoder.decode(APIErrorMessage.self, from: data) {
                throw APIError.apiError(errorData.jsonDecoder)
            } else {
                throw APIError.requestFailed(httpResponse.statusCode)
            }
        }*/

        // Decodificación de la respuesta
        do {
            return try jsonDecoder.decode(T.self, from: data)
        } catch {
            print("Decoding Error (Games): \(error)")
            throw APIError.decodingError(error)
        }
    }

    // Estructura auxiliar para mensajes de error del servidor
    private struct APIErrorMessage: Decodable {
        let message: String
        // Puedes añadir 'errors: [String: [String]]?' si Laravel devuelve errores de validación
    }

    // MARK: - Operaciones CRUD y Específicas de Juego

    /// **Fetches all games, with optional pagination.**
    /// - Parameters:
    ///   - page: The page number to fetch.
    ///   - limit: The number of items per page.
    /// - Returns: A PagedResponse containing an array of `Game` objects.
    func fetchAllGames(page: Int? = nil, limit: Int? = nil) async throws -> PagedResponse<Game> {
        var components = URLComponents(string: "\(baseURL)/games")
        var queryItems: [URLQueryItem] = []
        if let page = page { queryItems.append(URLQueryItem(name: "page", value: String(page))) }
        if let limit = limit { queryItems.append(URLQueryItem(name: "limit", value: String(limit))) }
        components?.queryItems = queryItems.isEmpty ? nil : queryItems

        guard let url = components?.url else {
            throw APIError.invalidURL
        }
        return try await performRequest(url: url, method: "GET")
    }

    /// **Fetches a single game by its ID.**
    /// - Parameter id: The ID of the game to fetch.
    /// - Returns: A `Game` object.
    func fetchGame(id: String) async throws -> Game {
        guard let url = URL(string: "\(baseURL)/games/\(id)") else {
            throw APIError.invalidURL
        }
        return try await performRequest(url: url, method: "GET")
    }

    /// **Creates a new game.**
    /// - Parameter game: The `GameCreateRequest` object containing game details.
    /// - Returns: The newly created `Game` object.
    func createGame(game: GameCreateRequest) async throws -> Game {
        guard let url = URL(string: "\(baseURL)/games") else {
            throw APIError.invalidURL
        }
        let body = try jsonEncoder.encode(game)
        
        // Laravel's store method often returns the created resource directly or wrapped.
        // Based on your controller, it returns the Game object.
        return try await performRequest(url: url, method: "POST", body: body)
    }

    /// **Updates an existing game.**
    /// - Parameters:
    ///   - id: The ID of the game to update.
    ///   - game: The `GameUpdateRequest` object containing updated game details.
    /// - Returns: The updated `Game` object.
    func updateGame(id: String, game: GameUpdateRequest) async throws -> Game {
        guard let url = URL(string: "\(baseURL)/games/\(id)") else {
            throw APIError.invalidURL
        }
        let body = try jsonEncoder.encode(game)
        return try await performRequest(url: url, method: "PUT", body: body)
    }

    /// **Deletes a game by its ID.**
    /// - Parameter id: The ID of the game to delete.
    func deleteGame(id: String) async throws {
        guard let url = URL(string: "\(baseURL)/games/\(id)") else {
            throw APIError.invalidURL
        }
        // Laravel delete often returns 204 No Content, so we don't expect a decodable body.
        // We still need to call performRequest for error handling.
        _ = try await performRequest(url: url, method: "DELETE") as String // Decodificamos a String o lo que sea trivial.
                                                                           // Si tu backend devuelve un mensaje, crea una struct para eso.
    }
    
    /// **Finalizes a game by setting scores and status.**
    /// - Parameters:
    ///   - id: The ID of the game to finalize.
    ///   - homeScore: The final score for the home team/player.
    ///   - awayScore: The final score for the away team/player.
    /// - Returns: The updated `Game` object with final status and winner.
    func finalizeGame(id: String, homeScore: Int, awayScore: Int) async throws -> Game {
        guard let url = URL(string: "\(baseURL)/games/\(id)/finalize") else {
            throw APIError.invalidURL
        }
        let requestBody = ["home_score": homeScore, "away_score": awayScore]
        let body = try JSONSerialization.data(withJSONObject: requestBody, options: [])
        
        return try await performRequest(url: url, method: "POST", body: body)
    }
    
    /// **Fetches games filtered by their status.**
    /// - Parameters:
    ///   - status: The desired `Game.GameStatus` to filter by.
    ///   - page: The page number for pagination.
    ///   - limit: The number of items per page.
    /// - Returns: A PagedResponse containing an array of `Game` objects.
    func fetchGamesByStatus(status: Game.GameStatus, page: Int? = nil, limit: Int? = nil) async throws -> PagedResponse<Game> {
        var components = URLComponents(string: "\(baseURL)/games/status/\(status.rawValue)")
        var queryItems: [URLQueryItem] = []
        if let page = page { queryItems.append(URLQueryItem(name: "page", value: String(page))) }
        if let limit = limit { queryItems.append(URLQueryItem(name: "limit", value: String(limit))) }
        components?.queryItems = queryItems.isEmpty ? nil : queryItems
        
        guard let url = components?.url else {
            throw APIError.invalidURL
        }
        return try await performRequest(url: url, method: "GET")
    }

    /// **Fetches games in which a specific player participates (as player1 or player2).**
    /// - Parameters:
    ///   - playerId: The ID of the player.
    ///   - page: The page number for pagination.
    ///   - limit: The number of items per page.
    /// - Returns: A PagedResponse containing an array of `Game` objects.
    func fetchMyGames(playerId: String, page: Int? = nil, limit: Int? = nil) async throws -> PagedResponse<Game> {
        var components = URLComponents(string: "\(baseURL)/games/myGames/\(playerId)")
        var queryItems: [URLQueryItem] = []
        if let page = page { queryItems.append(URLQueryItem(name: "page", value: String(page))) }
        if let limit = limit { queryItems.append(URLQueryItem(name: "limit", value: String(limit))) }
        components?.queryItems = queryItems.isEmpty ? nil : queryItems
        
        guard let url = components?.url else {
            throw APIError.invalidURL
        }
        // Tu controlador devuelve directamente la paginación.
        return try await performRequest(url: url, method: "GET")
    }
}

// MARK: - Estructuras de Petición (Request Payloads)

// `GameCreateRequest` y `GameUpdateRequest` son necesarias para enviar datos al backend.
// Replicarán la estructura de tu validación de Laravel, pero en `camelCase` para Swift,
// y con los tipos de datos Swift apropiados.

struct GameCreateRequest: Codable {
    let date: String // Formato "YYYY-MM-DD"
    let startTime: String // Formato "HH:MM"
    let endTime: String?
    let courtId: String
    let eventId: String?
    let gameType: Game.GameType // Usamos el enum definido en Game
    let player1Id: String?
    let player2Id: String?
    let homeTeamId: String?
    let awayTeamId: String?
    let homeScore: Int?
    let awayScore: Int?
    let winnerId: String?
    let gameStatus: Game.GameStatus // Usamos el enum definido en Game

    enum CodingKeys: String, CodingKey {
        case date
        case startTime = "start_time"
        case endTime = "end_time"
        case courtId = "court_id"
        case eventId = "event_id"
        case gameType = "game_type"
        case player1Id = "player1_id"
        case player2Id = "player2_id"
        case homeTeamId = "home_team_id"
        case awayTeamId = "away_team_id"
        case homeScore = "home_score"
        case awayScore = "away_score"
        case winnerId = "winner_id"
        case gameStatus = "game_status"
    }
}

struct GameUpdateRequest: Codable {
    let date: String?
    let startTime: String?
    let endTime: String?
    let courtId: String?
    let eventId: String?
    let gameType: Game.GameType? // Aunque tu controlador no permite cambiarlo, puede ser parte del payload
    let player1Id: String?
    let player2Id: String?
    let homeTeamId: String?
    let awayTeamId: String?
    let homeScore: Int?
    let awayScore: Int?
    let winnerId: String?
    let gameStatus: Game.GameStatus?

    enum CodingKeys: String, CodingKey {
        case date
        case startTime = "start_time"
        case endTime = "end_time"
        case courtId = "court_id"
        case eventId = "event_id"
        case gameType = "game_type"
        case player1Id = "player1_id"
        case player2Id = "player2_id"
        case homeTeamId = "home_team_id"
        case awayTeamId = "away_team_id"
        case homeScore = "home_score"
        case awayScore = "away_score"
        case winnerId = "winner_id"
        case gameStatus = "game_status"
    }
}
