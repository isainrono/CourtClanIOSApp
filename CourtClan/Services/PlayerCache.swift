//
//  PlayerCache.swift
//  CourtClan
//
//  Created by Isain Rodriguez Noreña on 22/5/25.
//

import Foundation

// Asegúrate de que tu struct Player esté definida y sea Identifiable
// Ejemplo (si no la tienes aún):
/*
struct Player: Identifiable, Codable {
    let id: String // Un identificador único, como UUID().uuidString
    let username: String
    let fullName: String?
    let email: String
    // ... otras propiedades de tu jugador
}
*/

class PlayerCache {
    // MARK: - 1. La instancia compartida (Singleton)

    /// La única instancia compartida de PlayerCache.
    /// Accede a ella usando `PlayerCache.shared`.
    static let shared = PlayerCache()

    // MARK: - 2. Almacén de jugadores en memoria

    /// La lista de jugadores guardados en memoria.
    /// Es `private(set)` para que solo PlayerCache pueda modificarla directamente.
    /// Otras clases solo pueden leerla.
    private(set) var players: [Player] = []

    // MARK: - 3. Constructor privado

    /// El constructor es privado para asegurar que no se puedan crear otras instancias de PlayerCache.
    private init() {
        // Puedes realizar alguna configuración inicial aquí si es necesario
        print("PlayerCache: Instancia creada (esto solo debería ocurrir una vez).")
    }

    // MARK: - 4. Métodos para gestionar la caché

    /// Guarda una lista de jugadores en la caché, reemplazando cualquier dato existente.
    /// - Parameter newPlayers: La nueva lista de jugadores a guardar.
    func setPlayers(_ newPlayers: [Player]) {
        self.players = newPlayers
        print("PlayerCache: Se guardaron \(newPlayers.count) jugadores en la caché.")
    }

    /// Añade un solo jugador a la caché. Si un jugador con el mismo ID ya existe, lo actualiza.
    /// - Parameter player: El jugador a añadir o actualizar.
    func addOrUpdatePlayer(_ player: Player) {
        if let index = players.firstIndex(where: { $0.id == player.id }) {
            players[index] = player // Actualiza el jugador existente
            print("PlayerCache: Jugador con ID \(player.id) actualizado.")
        } else {
            players.append(player) // Añade un nuevo jugador
            print("PlayerCache: Jugador con ID \(player.id) añadido.")
        }
    }

    /// Elimina un jugador de la caché por su ID.
    /// - Parameter id: El ID del jugador a eliminar.
    func removePlayer(id: String) {
        let initialCount = players.count
        players.removeAll { $0.id == id }
        if players.count < initialCount {
            print("PlayerCache: Jugador con ID \(id) eliminado de la caché.")
        } else {
            print("PlayerCache: Jugador con ID \(id) no encontrado en la caché.")
        }
    }

    /// Recupera todos los jugadores de la caché.
    /// - Returns: Una copia de la lista de jugadores actual.
    func getAllPlayers() -> [Player] {
        return players
    }

    /// Recupera un jugador específico de la caché por su ID.
    /// - Parameter id: El ID del jugador a buscar.
    /// - Returns: El jugador si se encuentra, `nil` en caso contrario.
    func getPlayer(by id: String) -> Player? {
        return players.first(where: { $0.id == id })
    }

    /// Limpia completamente la caché de jugadores.
    func clearCache() {
        players.removeAll()
        print("PlayerCache: Caché de jugadores vaciada.")
    }
}
