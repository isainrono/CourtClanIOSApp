//
//  TeamsAPIService.swift
//  CourtClan
//
//  Created by Isain Rodriguez Noreña on 21/5/25.
//

import Foundation

protocol TeamServiceProtocol {
    func fetchAllTeams() async throws -> [Team]
    func fetchTeam(id: String) async throws -> Team
    func createTeam(team: TeamCreateRequest) async throws -> Team
    func updateTeam(id: String, team: TeamUpdateRequest) async throws -> Team
    func deleteTeam(id: String) async throws
}

// MARK: - Implementación del Servicio de API para Teams
class TeamAPIService: TeamServiceProtocol {
    private let baseURL: String
    private let session: URLSession

    // Configuración del decodificador JSON
    private let jsonDecoder: JSONDecoder = {
        let decoder = JSONDecoder()
        // Importante: No usar .convertFromSnakeCase aquí porque tenemos CodingKeys explícitas
        // para los campos que no siguen la convención o requieren manejo especial (team_id, owner_player_id, etc.)

        // *** CAMBIO AQUI: USAR UN DATEFORMATTER PERSONALIZADO ***
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSSSSZ" // Formato para microsegundos
        dateFormatter.locale = Locale(identifier: "en_US_POSIX") // Configuración recomendada para formatos de fecha fijos
        dateFormatter.timeZone = TimeZone(secondsFromGMT: 0) // Zona horaria GMT/UTC ('Z' en el string)
        decoder.dateDecodingStrategy = .formatted(dateFormatter) // Usar el formatter personalizado
        // *** FIN CAMBIO ***

        return decoder
    }()

    // Configuración del codificador JSON
    private let jsonEncoder: JSONEncoder = {
        let encoder = JSONEncoder()
        encoder.keyEncodingStrategy = .convertToSnakeCase // Para mapear camelCase a snake_case al enviar
        encoder.dateEncodingStrategy = .iso8601 // ISO8601 estándar es suficiente para enviar fechas
        encoder.outputFormatting = .prettyPrinted // Opcional: para legibilidad en debugging
        return encoder
    }()

    init(baseURL: String, session: URLSession = .shared) {
        self.baseURL = baseURL
        self.session = session
    }

    // Método genérico para realizar peticiones HTTP y decodificar la respuesta
    private func performRequest<T: Decodable>(url: URL, method: String, body: Data? = nil) async throws -> T {
        var request = URLRequest(url: url)
        request.httpMethod = method
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        if let body = body {
            request.httpBody = body
        }

        let (data, response) = try await session.data(for: request)

        // *** LÍNEAS DE DEPURACIÓN DEL RAW JSON RECIBIDO ***
        if let jsonString = String(data: data, encoding: .utf8) {
            //print("--- RAW API RESPONSE DATA ---")
            //print(jsonString)
            //print("-----------------------------")
        } else {
            //print("--- RAW API RESPONSE DATA --- (Could not decode as UTF-8 string)")
            //print(data as NSData) // Imprime los bytes si no es una cadena UTF-8
            //print("-----------------------------")
        }
        // *** FIN DE LAS LÍNEAS DE DEPURACIÓN ***

        guard let httpResponse = response as? HTTPURLResponse else {
            throw APIError.invalidResponse
        }

       

        do {
            return try jsonDecoder.decode(T.self, from: data)
        } catch {
            print("Decoding Error: \(error)") // Imprime el error de decodificación detallado
            throw APIError.decodingError(error)
        }
    }

    // Struct auxiliar para decodificar mensajes de error de la API
    private struct APIErrorMessage: Decodable {
        let message: String
    }

    // MARK: - CRUD Operations

    func fetchAllTeams() async throws -> [Team] {
        guard let url = URL(string: "\(baseURL)/teams") else {
            throw APIError.invalidURL
        }
        // La API devuelve un diccionario con la clave 'teams'
        struct TeamsResponse: Decodable {
            let teams: [Team]
        }
        let response: TeamsResponse = try await performRequest(url: url, method: "GET")
        return response.teams
    }

    func fetchTeam(id: String) async throws -> Team {
        guard let url = URL(string: "\(baseURL)/teams/\(id)") else {
            throw APIError.invalidURL
        }
        // La API devuelve un diccionario con la clave 'team'
        struct TeamResponse: Decodable {
            let team: Team
        }
        let response: TeamResponse = try await performRequest(url: url, method: "GET")
        return response.team
    }

    func createTeam(team: TeamCreateRequest) async throws -> Team {
        guard let url = URL(string: "\(baseURL)/teams") else {
            throw APIError.invalidURL
        }
        let body = try jsonEncoder.encode(team) // Codifica el TeamCreateRequest

        // La API devuelve un diccionario con la clave 'team' y un mensaje
        struct CreateTeamResponse: Decodable {
            let message: String
            let team: Team
        }
        let response: CreateTeamResponse = try await performRequest(url: url, method: "POST", body: body)
        return response.team
    }

    func updateTeam(id: String, team: TeamUpdateRequest) async throws -> Team {
        guard let url = URL(string: "\(baseURL)/teams/\(id)") else {
            throw APIError.invalidURL
        }
        let body = try jsonEncoder.encode(team) // Codifica el TeamUpdateRequest

        // La API devuelve un diccionario con la clave 'team' y un mensaje
        struct UpdateTeamResponse: Decodable {
            let message: String
            let team: Team
        }
        let response: UpdateTeamResponse = try await performRequest(url: url, method: "PUT", body: body)
        return response.team
    }

    func deleteTeam(id: String) async throws {
        guard let url = URL(string: "\(baseURL)/teams/\(id)") else {
            throw APIError.invalidURL
        }
        // Para DELETE, tu controlador Laravel devuelve un mensaje, por ejemplo:
        // {"message": "Team deleted successfully"}
        struct DeleteResponse: Decodable {
            let message: String
        }
        _ = try await performRequest(url: url, method: "DELETE") as DeleteResponse
    }
}


// MARK: - Request Body Structures (Payloads para POST/PUT)

// Struct auxiliar para el cuerpo de la petición POST (crear equipo)
struct TeamCreateRequest: Codable {
    let name: String
    let description: String?
    let logoUrl: String?
    let ownerUserId: String
    let captainUserId: String?
    let teamFunds: Double?

    enum CodingKeys: String, CodingKey {
        case name
        case description
        case logoUrl = "logo_url"
        case ownerUserId = "owner_player_id" // Mapeo correcto para el envío
        case captainUserId = "captain_player_id" // Mapeo correcto para el envío
        case teamFunds = "team_funds"
    }
}

// Struct auxiliar para el cuerpo de la petición PUT (actualizar equipo)
struct TeamUpdateRequest: Codable {
    let name: String?
    let description: String?
    let logoUrl: String?
    let ownerUserId: String?
    let captainUserId: String?
    let teamFunds: Double?

    enum CodingKeys: String, CodingKey {
        case name
        case description
        case logoUrl = "logo_url"
        case ownerUserId = "owner_player_id" // Mapeo correcto para el envío
        case captainUserId = "captain_player_id" // Mapeo correcto para el envío
        case teamFunds = "team_funds"
    }
}
