//
//  Court.swift
//  RodMon
//
//  Created by Isain Rodriguez Noreña on 20/5/25.
//

import Foundation

// MARK: - Court Model
struct Court: Identifiable, Codable {
    let id: String // Mapea a 'court_id'
    let name: String
    let address: String
    let latitude: String
    let longitude: String
    let courtTypeId: String // Mapea a 'court_type_id'
    let description: String
    let picturesUrls: [String] // Mapea a 'pictures_urls' (asumiendo que es un JSON string de un array)
    let isPublic: Bool // Mapea a 'is_public'
    let hasHoop: Bool // Mapea a 'has_hoop'
    let hasNet: Bool // Mapea a 'has_net'
    let hasLights: Bool // Mapea a 'has_lights'
    let availabilityNotes: String // Mapea a 'availability_notes'
    let ownerId: String? // Mapea a 'owner_id', ahora es opcional
    let createdAt: Date? // <-- MAKE OPTIONAL
    let updatedAt: Date? // <-- MAKE OPTIONAL
    var cityAndNeighborhood: String?
    

    // Mapeo de claves JSON de snake_case a camelCase de Swift
    enum CodingKeys: String, CodingKey {
        case id = "court_id"
        case name
        case address
        case latitude
        case longitude
        case courtTypeId = "court_type_id"
        case description
        case picturesUrls = "pictures_urls"
        case ownerId = "owner_id"
        case isPublic = "is_public"
        case hasHoop = "has_hoop"
        case hasNet = "has_net"
        case hasLights = "has_lights"
        case availabilityNotes = "availability_notes"
        case createdAt = "created_at"
        case updatedAt = "updated_at"
    }
    
    init(){
        self.id = "mock-court-uuid-1";
        self.name = "Cancha de Baloncesto Central";
        self.address = "Calle Falsa 123, Barcelona";
        self.latitude = "41.3851";
        self.longitude = "2.1734";
        self.courtTypeId = "mock-court-type-uuid-1"; // ID de un tipo de cancha ficticio
        self.description = "Una cancha céntrica ideal para partidos 3v3. Recientemente renovada.";
        self.picturesUrls = [
            "https://example.com/court1_pic1.jpg",
            "https://example.com/court1_pic2.jpg"
        ];
        self.isPublic = true;
        self.hasHoop = true;
        self.hasNet = false;
        self.hasLights = true;
        self.availabilityNotes = "Abierta de 9:00 a 22:00 todos los días.";
        self.ownerId = "mock-owner-uuid-1";
        self.createdAt = Date()
        self.updatedAt = Date()
    }

    // Custom Decodable initializer para manejar tipos específicos como los URLs y los Int/Bool (0/1)
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.id = try container.decode(String.self, forKey: .id)
        self.name = try container.decode(String.self, forKey: .name)
        self.address = try container.decode(String.self, forKey: .address)
        self.latitude = try container.decode(String.self, forKey: .latitude)
        self.longitude = try container.decode(String.self, forKey: .longitude)
        self.courtTypeId = try container.decode(String.self, forKey: .courtTypeId)
        self.description = try container.decode(String.self, forKey: .description)
        self.availabilityNotes = try container.decode(String.self, forKey: .availabilityNotes)
        self.ownerId = try container.decodeIfPresent(String.self, forKey: .ownerId)
        
        self.isPublic = try container.decode(Int.self, forKey: .isPublic) == 1
        self.hasHoop = try container.decode(Int.self, forKey: .hasHoop) == 1
        self.hasNet = try container.decode(Int.self, forKey: .hasNet) == 1
        self.hasLights = try container.decode(Int.self, forKey: .hasLights) == 1

        let picturesUrlsString = try container.decode(String.self, forKey: .picturesUrls)
        guard let picturesData = picturesUrlsString.data(using: .utf8) else {
            throw DecodingError.dataCorruptedError(forKey: .picturesUrls, in: container, debugDescription: "Cannot convert pictures_urls string to Data")
        }
        self.picturesUrls = try JSONDecoder().decode([String].self, from: picturesData)
        self.createdAt = try container.decodeIfPresent(Date.self, forKey: .createdAt) // Decode as optional
        self.updatedAt = try container.decodeIfPresent(Date.self, forKey: .updatedAt) // Decode as optional
        self.cityAndNeighborhood = nil
    }

    // Conveniencia init para crear instancias de prueba (Previews, Mocks)
    init(
        id: String = UUID().uuidString,
        name: String,
        address: String,
        latitude: String,
        longitude: String,
        courtTypeId: String = UUID().uuidString,
        description: String,
        picturesUrls: [String] = [],
        isPublic: Bool,
        hasHoop: Bool,
        hasNet: Bool,
        hasLights: Bool,
        availabilityNotes: String,
        ownerId: String? = nil,
        createdAt: Date? = nil,
        updatedAt: Date? = nil,
        cityAndNeighborhood: String? = nil
    ) {
        self.id = id
        self.name = name
        self.address = address
        self.latitude = latitude
        self.longitude = longitude
        self.courtTypeId = courtTypeId
        self.description = description
        self.picturesUrls = picturesUrls
        self.isPublic = isPublic
        self.hasHoop = hasHoop
        self.hasNet = hasNet
        self.hasLights = hasLights
        self.availabilityNotes = availabilityNotes
        self.ownerId = ownerId
        self.createdAt = createdAt
        self.updatedAt = updatedAt
        self.cityAndNeighborhood = cityAndNeighborhood
    }
}

// MARK: - Extensión para datos de Preview (opcional, pero útil)
extension Court {
    static let previewCourt: Court = Court(
        id: "mock-court-uuid-1",
        name: "Cancha de Baloncesto Central",
        address: "Calle Falsa 123, Barcelona",
        latitude: "41.3851",
        longitude: "2.1734",
        courtTypeId: "mock-court-type-uuid-1", // ID de un tipo de cancha ficticio
        description: "Una cancha céntrica ideal para partidos 3v3. Recientemente renovada.",
        picturesUrls: [
            "https://example.com/court1_pic1.jpg",
            "https://example.com/court1_pic2.jpg"
        ],
        isPublic: true,
        hasHoop: true,
        hasNet: false,
        hasLights: true,
        availabilityNotes: "Abierta de 9:00 a 22:00 todos los días.",
        ownerId: "mock-owner-uuid-1",
        cityAndNeighborhood: "Barcelona"
    )
    
    static let anotherPreviewCourt: Court = Court(
        id: "mock-court-uuid-2",
        name: "Pista de Pádel El Sol",
        address: "Avenida Siempre Viva 456, Madrid",
        latitude: "40.4168",
        longitude: "-3.7038",
        courtTypeId: "mock-court-type-uuid-2", // ID de otro tipo de cancha
        description: "Pista exterior con buen mantenimiento, ideal para dobles.",
        picturesUrls: [
            "https://example.com/court2_pic1.jpg"
        ],
        isPublic: false,
        hasHoop: false,
        hasNet: true,
        hasLights: false,
        availabilityNotes: "Reservas necesarias. Cerrado los domingos por la tarde.",
        cityAndNeighborhood: "Barcelona"
    )
}
