//
//  Team.swift
//  CourtClan
//
//  Created by Isain Rodriguez Noreña on 21/5/25.
//

import Foundation

struct Team: Identifiable, Codable {
    let id: String // team_id en JSON
        let name: String
        let description: String?
        let logoUrl: String? // logo_url en JSON
        let ownerUserId: String // owner_player_id en JSON - ¡AQUÍ ESTÁ OTRA POSIBLE FUENTE DE ERROR!
        let captainUserId: String? // captain_player_id en JSON
        let teamFunds: Double // team_funds en JSON (como String, luego Double en Swift)
        let createdAt: Date?
        let updatedAt: Date?

        enum CodingKeys: String, CodingKey {
            case id = "team_id"
            case name, description
            case logoUrl = "logo_url"
            case ownerUserId = "owner_player_id" // Laravel devuelve owner_player_id
            case captainUserId = "captain_player_id" // Laravel devuelve captain_player_id
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
    
    // Inicializador vacío para casos donde necesitas una instancia por defecto (ej. en formularios nuevos)
    init () {
        self.id = UUID().uuidString // Genera un ID único para evitar conflictos en listas de SwiftUI
        self.name = "Nuevo Equipo"
        self.description = nil
        self.logoUrl = nil
        self.ownerUserId = UUID().uuidString
        self.captainUserId = nil
        self.teamFunds = 0.0
        self.createdAt = Date() // Puedes poner una fecha actual
        self.updatedAt = Date() // Puedes poner una fecha actual
    }
    
    // MARK: - Custom Decoder para manejar team_funds como String y el mapeo explícito
    // **Importante: Este es el init que necesitas para depurar el problema de la decodificación anidada.**
    // **Asegúrate de que los prints para depuración (que te di en la respuesta anterior) estén aquí.**
    init(from decoder: Decoder) throws {
            let container = try decoder.container(keyedBy: CodingKeys.self)

            self.id = try container.decode(String.self, forKey: .id)
            self.name = try container.decode(String.self, forKey: .name)
            self.description = try? container.decode(String.self, forKey: .description)
            self.logoUrl = try? container.decode(String.self, forKey: .logoUrl)
            
            // --- POSIBLES PROBLEMAS AQUÍ ---
            // 1. ownerUserId: Si Laravel puede enviar owner_player_id como null,
            //    y lo tienes como `String` (no `String?`), esto causará un error.
            self.ownerUserId = try container.decode(String.self, forKey: .ownerUserId)
            self.captainUserId = try? container.decode(String.self, forKey: .captainUserId)

            // 2. teamFunds: Si Laravel envía "team_funds": null (en lugar de un string numérico)
            //    entonces `try container.decode(String.self, forKey: .teamFunds)` fallará.
            let teamFundsString = try container.decode(String.self, forKey: .teamFunds)
            if let funds = Double(teamFundsString) {
                self.teamFunds = funds
            } else {
                print("❌ ERROR_TEAM_DECODING (TeamFunds): No se pudo convertir 'team_funds' de String \"\(teamFundsString)\" a Double para Team ID: \(self.id).")
                throw DecodingError.dataCorruptedError(forKey: .teamFunds,
                                                        in: container,
                                                        debugDescription: "Cannot decode 'team_funds' as Double from string \"\(teamFundsString)\"")
            }
            
            // 3. createdAt/updatedAt: Ya los manejas con try?, lo cual es bueno.
            self.createdAt = try? container.decode(Date.self, forKey: .createdAt)
            if self.createdAt == nil {
                let rawCreatedAt = (try? container.decode(String.self, forKey: .createdAt)) ?? "N/A"
                print("⚠️ WARNING_TEAM_DECODING (CreatedAt): No se pudo decodificar 'createdAt' para Team ID: \(self.id). Valor RAW: '\(rawCreatedAt)'.")
            }
            self.updatedAt = try? container.decode(Date.self, forKey: .updatedAt)
            if self.updatedAt == nil {
                let rawUpdatedAt = (try? container.decode(String.self, forKey: .updatedAt)) ?? "N/A"
                print("⚠️ WARNING_TEAM_DECODING (UpdatedAt): No se pudo decodificar 'updatedAt' para Team ID: \(self.id). Valor RAW: '\(rawUpdatedAt)'.")
            }
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
        
        // Codificar teamFunds como String con 2 decimales
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
            name: "Los Lobos Rojos",
            description: "Un equipo fiero y competitivo.",
            logoUrl: "[https://example.com/lobos_rojos_logo.png](https://example.com/lobos_rojos_logo.png)",
            ownerUserId: UUID().uuidString,
            captainUserId: UUID().uuidString,
            teamFunds: 50000.75,
            createdAt: Calendar.current.date(from: DateComponents(year: 2024, month: 1, day: 15, hour: 10, minute: 30, second: 0))!,
            updatedAt: Calendar.current.date(from: DateComponents(year: 2025, month: 7, day: 10, hour: 14, minute: 0, second: 0))!
        ),
        Team(
            id: UUID().uuidString,
            name: "Los Cóndores Blancos",
            description: "Estrategia y elegancia en la cancha.",
            logoUrl: nil, // Ejemplo de URL nula
            ownerUserId: UUID().uuidString,
            captainUserId: nil, // Ejemplo de capitán nulo
            teamFunds: 30000.00,
            createdAt: Calendar.current.date(from: DateComponents(year: 2023, month: 10, day: 1, hour: 9, minute: 0, second: 0))!,
            updatedAt: Calendar.current.date(from: DateComponents(year: 2025, month: 7, day: 12, hour: 11, minute: 45, second: 0))!
        ),
        Team(
            id: UUID().uuidString,
            name: "Las Águilas Negras",
            description: "Velocidad y precisión en cada movimiento.",
            logoUrl: "[https://example.com/aguilas_negras_logo.png](https://example.com/aguilas_negras_logo.png)",
            ownerUserId: UUID().uuidString,
            captainUserId: UUID().uuidString,
            teamFunds: 80000.50,
            createdAt: Calendar.current.date(from: DateComponents(year: 2022, month: 3, day: 20, hour: 15, minute: 0, second: 0))!,
            updatedAt: Calendar.current.date(from: DateComponents(year: 2025, month: 7, day: 14, hour: 10, minute: 30, second: 0))!
        )
    ]
}
