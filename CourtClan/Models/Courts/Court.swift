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
    // `created_at` y `updated_at` se pueden añadir si los necesitas, pero no son esenciales para la vista
    // `court_type` es un objeto anidado, lo decodificaremos en el init

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
        case isPublic = "is_public"
        case hasHoop = "has_hoop"
        case hasNet = "has_net"
        case hasLights = "has_lights"
        case availabilityNotes = "availability_notes"
        // No necesitamos mapear court_type aquí si solo lo leemos en el init
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

        // Decodificar los Bool que vienen como Int (0 o 1)
        self.isPublic = try container.decode(Int.self, forKey: .isPublic) == 1
        self.hasHoop = try container.decode(Int.self, forKey: .hasHoop) == 1
        self.hasNet = try container.decode(Int.self, forKey: .hasNet) == 1
        self.hasLights = try container.decode(Int.self, forKey: .hasLights) == 1

        // `pictures_urls` viene como un string JSON, necesitamos decodificarlo por separado
        let picturesUrlsString = try container.decode(String.self, forKey: .picturesUrls)
        guard let picturesData = picturesUrlsString.data(using: .utf8) else {
            throw DecodingError.dataCorruptedError(forKey: .picturesUrls, in: container, debugDescription: "Cannot convert pictures_urls string to Data")
        }
        self.picturesUrls = try JSONDecoder().decode([String].self, from: picturesData)

        // Nota: El objeto `court_type` anidado no se mapea directamente a una propiedad aquí,
        // ya que la vista solo necesita las propiedades de la cancha principal.
        // Si necesitas acceder a `court_type.name` en la vista, deberías añadir una propiedad
        // anidada en el modelo Court, por ejemplo: `let courtType: CourtTypeDetail`.
    }

    // Encodable (si fueras a enviar datos a la API con este modelo)
    // He eliminado la implementación de `encode` para simplificar,
    // ya que el JSON de entrada no coincide con los campos del formulario de edición/creación anteriores.
    // Si necesitas enviar datos con este modelo, deberías reconstruir `encode(to encoder:)`
    // para que coincida con la estructura que tu API espera para CREAR/ACTUALIZAR.
}


