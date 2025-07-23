//
//  Game.swift
//  CourtClan
//
//  Created by Isain Rodriguez Noreña on 20/6/25.
//

import Foundation
import SwiftUI // Necesario para PreviewProvider si quieres la función aquí

// MARK: - Game Model
// Representa un partido en tu sistema. Conformidad con Codable e Identifiable.
struct Game: Codable, Identifiable {
    let id: String // Mapea 'game_id' del backend a 'id' para Identifiable
    let date: Date // Decodificado directamente a Date
    let startTime: Date // Decodificado directamente a Date (hora del día)
    let endTime: Date? // Decodificado directamente a Date (hora del día), opcional
    let courtId: String
    let eventId: String? // Opcional

    let gameType: GameType // one_vs_one o team_game

    // Jugadores para partidos 1 vs 1 (mutuamente excluyentes con equipos)
    let player1Id: String?
    let player2Id: String?

    // Equipos para partidos por equipos (mutuamente excluyentes con jugadores)
    let homeTeamId: String?
    let awayTeamId: String?

    let homeScore: Int?
    let awayScore: Int?
    let winnerId: String? // ID del jugador o equipo ganador (dependiendo del tipo de juego)
    let gameStatus: GameStatus // scheduled, in_progress, finished, postponed, cancelled

    let createdAt: Date // Decodificado directamente a Date
    let updatedAt: Date // Decodificado directamente a Date

    // MARK: - Relaciones Anidadas
    // Estas propiedades se llenarán si usas `.with(['relation'])` en Laravel.
    // Son opcionales porque no siempre se cargan o pueden ser nulas.
    let court: Court?
    let player1: Player?
    let player2: Player?
    let homeTeam: Team?
    let awayTeam: Team?
    let event: Event?

    // MARK: - CodingKeys para mapeo JSON
    // Mapea las claves snake_case de tu API a camelCase de Swift.
    enum CodingKeys: String, CodingKey {
        case id = "game_id"
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
        case createdAt = "created_at"
        case updatedAt = "updated_at"

        // Claves para las relaciones
        case court, player1, player2, homeTeam, awayTeam, event
    }
    
          

    // MARK: - Enumeraciones para campos con valores fijos
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
    
    // MARK: - Propiedades Computadas Útiles
    var displayDate: String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .none
        return formatter.string(from: date)
    }
    
    var displayStartTime: String {
        let formatter = DateFormatter()
        formatter.dateStyle = .none
        formatter.timeStyle = .short
        return formatter.string(from: startTime)
    }
    
    var displayEndTime: String {
        guard let endTime = endTime else { return "N/A" }
        let formatter = DateFormatter()
        formatter.dateStyle = .none
        formatter.timeStyle = .short
        return formatter.string(from: endTime)
    }
}


// MARK: - Paged Response Model (para métodos como `index()`)
// Estructura para manejar las respuestas JSON paginadas de Laravel.
struct PagedResponse<T: Codable>: Codable {
    let currentPage: Int
    let data: [T]
    let firstPageUrl: String?
    let from: Int?
    let lastPage: Int
    let lastPageUrl: String?
    let nextPageUrl: String?
    let path: String
    let perPage: Int
    let prevPageUrl: String?
    let to: Int?
    let total: Int

    enum CodingKeys: String, CodingKey {
        case currentPage = "current_page"
        case data
        case firstPageUrl = "first_page_url"
        case from
        case lastPage = "last_page"
        case lastPageUrl = "last_page_url"
        case nextPageUrl = "next_page_url"
        case path
        case perPage = "per_page"
        case prevPageUrl = "prev_page_url"
        case to
        case total
    }
}

// MARK: - Configuración del JSONDecoder
extension JSONDecoder {
    static let customLaravelDecoder: JSONDecoder = {
        let decoder = JSONDecoder()
        // Configura la estrategia de decodificación de fechas.
        // Laravel por defecto usa el formato ISO 8601 (con o sin microsegundos, y 'Z' para UTC).
        // Si tienes problemas, verifica el formato exacto que Laravel está enviando
        // y ajusta la estrategia de decodificación aquí.
        decoder.dateDecodingStrategy = .custom { decoder in
            let container = try decoder.singleValueContainer()
            let dateString = try container.decode(String.self)

            // Intentar con formatos comunes de Laravel para timestamps y fechas
            let formatters: [DateFormatter] = [
                // Formato ISO 8601 completo con microsegundos y Z para UTC
                {
                    let formatter = DateFormatter()
                    formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSSSSZ"
                    formatter.locale = Locale(identifier: "en_US_POSIX")
                    formatter.timeZone = TimeZone(secondsFromGMT: 0) // UTC
                    return formatter
                }(),
                // Formato ISO 8601 sin microsegundos y Z para UTC
                {
                    let formatter = DateFormatter()
                    formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZ"
                    formatter.locale = Locale(identifier: "en_US_POSIX")
                    formatter.timeZone = TimeZone(secondsFromGMT: 0) // UTC
                    return formatter
                }(),
                // Formato solo fecha (para 'date' column)
                {
                    let formatter = DateFormatter()
                    formatter.dateFormat = "yyyy-MM-dd"
                    formatter.locale = Locale(identifier: "en_US_POSIX")
                    return formatter
                }(),
                // Formato solo hora (para 'start_time', 'end_time' column - estos se decodificarán como Date a partir de una fecha base)
                // Para esto, solo tomaremos la hora y la mapearemos a un Date en el día actual
                {
                    let formatter = DateFormatter()
                    formatter.dateFormat = "HH:mm:ss" // Si Laravel envía segundos
                    formatter.locale = Locale(identifier: "en_US_POSIX")
                    return formatter
                }(),
                {
                    let formatter = DateFormatter()
                    formatter.dateFormat = "HH:mm" // Si Laravel solo envía hora y minuto
                    formatter.locale = Locale(identifier: "en_US_POSIX")
                    return formatter
                }()
            ]

            for formatter in formatters {
                if let date = formatter.date(from: dateString) {
                    return date
                }
            }
            // Si no se puede decodificar, lanza un error
            throw DecodingError.dataCorruptedError(in: container, debugDescription: "Cannot decode date string \(dateString)")
        }
        return decoder
    }()
}


