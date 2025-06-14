//
//  PlayerDataManager.swift
//  CourtClan
//
//  Created by Isain Rodriguez Noreña on 2/6/25.
//

import Foundation
import Combine
import SwiftUI // Necesario para @MainActor, si lo usas en el ViewModel

class PlayerDataManager: ObservableObject {
    @Published var player: Player? // Almacena el objeto Player en memoria

    init() {
        // En este caso, no hay lógica de carga inicial desde almacenamiento
        // porque el propósito es solo mantenerlo en memoria.
        print("✅ CurrentPlayerManager inicializado. El jugador actual es: \(player?.username ?? "ninguno")")
    }

    /**
     Establece el jugador actual. Esto actualiza la propiedad @Published 'player'
     y notifica a todas las vistas que estén observando.
     */
    func setCurrentPlayer(_ newPlayer: Player?) {
        self.player = newPlayer
        if let username = newPlayer?.username {
            print("✅ Jugador establecido en memoria: \(username)")
        } else {
            print("✅ Jugador establecido en memoria como nil.")
        }
    }

    /**
     Elimina el jugador actual de la memoria. Esto establece 'player' a nil.
     */
    func clearCurrentPlayer() {
        self.player = nil
        print("✅ Jugador eliminado de la memoria.")
    }
}
