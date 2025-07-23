//
//  Event.swift
//  CourtClan
//
//  Created by Isain Rodriguez Noreña on 30/6/25.
//

import Foundation

// MARK: - Event Model
// Representa la tabla 'events' en Swift.
struct Event: Identifiable, Codable {
    // Usamos 'id' para conformar a Identifiable, mapeando 'event_id' de Laravel.
    // Asumimos que event_id es un UUID, que es común para IDs no incrementales.
    let id: UUID // Corresponde a 'event_id' en Laravel
    var name: String
    var description: String
    var eventType: EventType // Corresponde a 'event_type'
    var scheduledTime: Date // Corresponde a 'scheduled_time'
    var durationMinutes: Int // Corresponde a 'duration_minutes'
    var courtId: UUID // Corresponde a 'court_id'
    var creatorUserId: UUID // Corresponde a 'creator_user_id' (player_id del creador)
    var status: EventStatus // Corresponde a 'status'
    var isPublic: Bool // Corresponde a 'is_public'
    var maxParticipants: Int // Corresponde a 'max_participants'

    // MARK: - Relationships (Opcionales, ya que pueden no estar siempre cargadas)
    // Estas propiedades serían cargadas por separado o incluidas en la respuesta JSON
    // si usas eager loading en tu API de Laravel (e.g., `Event::with('court', 'creatorPlayer')->get()`).
    var court: Court?
    var creatorPlayer: Player?
    var participants: [EventParticipant]? // Relación Many-to-Many con datos de pivote
    var participatingTeams: [EventTeamParticipant]? // Relación Many-to-Many con datos de pivote

    // MARK: - Computed Property (Accessor)
    // Corresponde a 'getCurrentParticipantsCountAttribute' de Laravel.
    var currentParticipantsCount: Int {
        let playerCount = participants?.count ?? 0
        let teamCount = participatingTeams?.count ?? 0
        return playerCount + teamCount
    }

    // MARK: - CodingKeys para mapear nombres de propiedades de Swift a nombres de JSON (snake_case de Laravel)
    enum CodingKeys: String, CodingKey {
        case id = "event_id"
        case name
        case description
        case eventType = "event_type"
        case scheduledTime = "scheduled_time"
        case durationMinutes = "duration_minutes"
        case courtId = "court_id"
        case creatorUserId = "creator_user_id"
        case status
        case isPublic = "is_public"
        case maxParticipants = "max_participants"
        case court // Opcional, si se carga en el JSON
        case creatorPlayer = "creator_player" // Opcional, si se carga en el JSON
        case participants // Opcional, si se carga en el JSON
        case participatingTeams = "participating_teams" // Opcional, si se carga en el JSON
    }

    // MARK: - Initializer para decodificación personalizada si es necesario
    // (Por ejemplo, si necesitas un formato de fecha específico que no sea ISO 8601 por defecto)
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.id = try container.decode(UUID.self, forKey: .id)
        self.name = try container.decode(String.self, forKey: .name)
        self.description = try container.decode(String.self, forKey: .description)
        self.eventType = try container.decode(EventType.self, forKey: .eventType)

        // Decodificación de fecha: Laravel usa formatos de fecha y hora estándar.
        // Asegúrate de que tu JSON Decoder esté configurado para manejar el formato.
        // Por defecto, JSONDecoder puede manejar ISO 8601.
        self.scheduledTime = try container.decode(Date.self, forKey: .scheduledTime)

        self.durationMinutes = try container.decode(Int.self, forKey: .durationMinutes)
        self.courtId = try container.decode(UUID.self, forKey: .courtId)
        self.creatorUserId = try container.decode(UUID.self, forKey: .creatorUserId)
        self.status = try container.decode(EventStatus.self, forKey: .status)
        self.isPublic = try container.decode(Bool.self, forKey: .isPublic)
        self.maxParticipants = try container.decode(Int.self, forKey: .maxParticipants)

        // Decodificar relaciones si están presentes en el JSON
        self.court = try container.decodeIfPresent(Court.self, forKey: .court)
        self.creatorPlayer = try container.decodeIfPresent(Player.self, forKey: .creatorPlayer)
        self.participants = try container.decodeIfPresent([EventParticipant].self, forKey: .participants)
        self.participatingTeams = try container.decodeIfPresent([EventTeamParticipant].self, forKey: .participatingTeams)
    }

    // MARK: - Initializer para crear instancias manualmente (útil para mock data)
    init(id: UUID = UUID(), name: String, description: String, eventType: EventType, scheduledTime: Date, durationMinutes: Int, courtId: UUID, creatorUserId: UUID, status: EventStatus, isPublic: Bool, maxParticipants: Int, court: Court? = nil, creatorPlayer: Player? = nil, participants: [EventParticipant]? = nil, participatingTeams: [EventTeamParticipant]? = nil) {
        self.id = id
        self.name = name
        self.description = description
        self.eventType = eventType
        self.scheduledTime = scheduledTime
        self.durationMinutes = durationMinutes
        self.courtId = courtId
        self.creatorUserId = creatorUserId
        self.status = status
        self.isPublic = isPublic
        self.maxParticipants = maxParticipants
        self.court = court
        self.creatorPlayer = creatorPlayer
        self.participants = participants
        self.participatingTeams = participatingTeams
    }
}

// MARK: - Enums para tipos y estados
// Corresponden a los posibles valores de 'event_type' y 'status' en tu base de datos.
// Asegúrate de que los RawValue coincidan con los valores string en tu DB.
enum EventType: String, Codable {
    case oneVsOne = "1_vs_1" // Añadido
    case tournament = "Tournament"
    case friendly = "Friendly"
    case training = "Training"
    case casualGame = "Casual Game" // Añadido
    // Asegúrate de que estos RawValue coincidan exactamente con tu backend
    // Si tienes "match" en tu backend y no en VALID_EVENT_TYPES, añádelo aquí.
    // case match = "match" // Si "match" es un tipo válido en tu DB/backend
}

enum EventStatus: String, Codable {
    case scheduled = "Scheduled"
    case active = "Active"
    case completed = "Completed"
    case cancelled = "Cancelled"
    // Asegúrate de que estos RawValue coincidan exactamente con tu backend
}



// MARK: - Pivot Models for Many-to-Many Relationships
// Estas estructuras representan los datos de la tabla pivote 'event_participants'.

struct EventParticipant: Identifiable, Codable {
    // Combinamos event_id y user_id para crear un ID único para esta entrada de pivote.
    // O puedes usar un ID propio si tu tabla pivote tiene uno.
    let id = UUID() // Un ID único para la instancia de esta relación
    let eventId: UUID // Corresponde a 'event_id' en la tabla pivote
    let userId: UUID // Corresponde a 'user_id' en la tabla pivote (player_id)
    var score: Int?
    var isWinner: Bool?
    var joinedAt: Date // Corresponde a 'joined_at'
    var teamId: UUID? // Corresponde a 'team_id' (opcional si el participante es un jugador individual)

    // La relación con el Player real (si se carga con `with('participants.player')` en Laravel)
    var player: Player?

    enum CodingKeys: String, CodingKey {
        case eventId = "event_id"
        case userId = "user_id"
        case score
        case isWinner = "is_winner"
        case joinedAt = "joined_at"
        case teamId = "team_id"
        case player // Si se carga el objeto Player anidado
    }

    // Custom initializer for decoding
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.eventId = try container.decode(UUID.self, forKey: .eventId)
        self.userId = try container.decode(UUID.self, forKey: .userId)
        self.score = try container.decodeIfPresent(Int.self, forKey: .score)
        self.isWinner = try container.decodeIfPresent(Bool.self, forKey: .isWinner)
        self.joinedAt = try container.decode(Date.self, forKey: .joinedAt)
        self.teamId = try container.decodeIfPresent(UUID.self, forKey: .teamId)
        self.player = try container.decodeIfPresent(Player.self, forKey: .player)
    }
}

struct EventTeamParticipant: Identifiable, Codable {
    let id = UUID() // Un ID único para la instancia de esta relación
    let eventId: UUID // Corresponde a 'event_id' en la tabla pivote
    let teamId: UUID // Corresponde a 'team_id' en la tabla pivote
    var score: Int?
    var isWinner: Bool?
    var joinedAt: Date // Corresponde a 'joined_at'
    var userId: UUID? // Corresponde a 'user_id' (opcional si el participante es un equipo)

    // La relación con el Team real (si se carga con `with('participatingTeams.team')` en Laravel)
    var team: Team?

    enum CodingKeys: String, CodingKey {
        case eventId = "event_id"
        case teamId = "team_id"
        case score
        case isWinner = "is_winner"
        case joinedAt = "joined_at"
        case userId = "user_id"
        case team // Si se carga el objeto Team anidado
    }

    // Custom initializer for decoding
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.eventId = try container.decode(UUID.self, forKey: .eventId)
        self.teamId = try container.decode(UUID.self, forKey: .teamId)
        self.score = try container.decodeIfPresent(Int.self, forKey: .score)
        self.isWinner = try container.decodeIfPresent(Bool.self, forKey: .isWinner)
        self.joinedAt = try container.decode(Date.self, forKey: .joinedAt)
        self.userId = try container.decodeIfPresent(UUID.self, forKey: .userId)
        self.team = try container.decodeIfPresent(Team.self, forKey: .team)
    }
}

extension Event{
    static var sampleEvents:[Event] = [
        Event(
            name: "New Test Event",
            description: "A test event created from SwiftUI.",
            eventType: .friendly,
            scheduledTime: Date().addingTimeInterval(3600 * 24 * 7), // 7 days from now
            durationMinutes: 60,
            courtId: UUID(), // Replace with a real Court ID
            creatorUserId: UUID(), // Replace with a real Player ID
            status: .scheduled,
            isPublic: true,
            maxParticipants: 10
        ),
        Event(
            name: "New Test Event",
            description: "A test event created from SwiftUI.",
            eventType: .friendly,
            scheduledTime: Date().addingTimeInterval(3600 * 24 * 7), // 7 days from now
            durationMinutes: 60,
            courtId: UUID(), // Replace with a real Court ID
            creatorUserId: UUID(), // Replace with a real Player ID
            status: .scheduled,
            isPublic: true,
            maxParticipants: 10
        )
    ]
}
