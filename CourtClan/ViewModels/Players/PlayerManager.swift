//
//  PlayerManager.swift
//  CourtClan
//
//  Created by Isain Rodriguez Noreña on 5/6/25.
//

import Foundation
import Combine
import SwiftUI // Necesario para @MainActor

class PlayerManager: ObservableObject {
    @Published var currentPlayer: Player?
    @Published var isLoading: Bool = false
    @Published var errorMessage: String?
    
    private let playerService: PlayerServiceProtocol // Usa tu protocolo real
    
    // Inyecta el servicio real PlayerAPIService
    init(playerService: PlayerServiceProtocol) {
        self.playerService = playerService
    }
    
    // Método para cargar el jugador, ahora usando PlayerServiceProtocol
    @MainActor
    func loadCurrentPlayer(playerID: String) async {
        guard !isLoading else {
            print("PlayerManager: Ya en proceso de carga.")
            return
        }
        
        // Si ya tenemos un jugador y es el mismo ID, no recargamos a menos que se fuerce.
        // Esto es clave para el rendimiento y evitar recargas al volver a una vista.
        if let existingPlayer = currentPlayer, existingPlayer.id == playerID {
            print("PlayerManager: Jugador con ID \(playerID) ya cargado y es el mismo.")
            return
        }
        
        isLoading = true
        errorMessage = nil
        print("PlayerManager: Iniciando carga del jugador con ID: \(playerID)")
        
        do {
            // Llama a tu fetchPlayer real aquí
            let player = try await playerService.fetchPlayer(id: playerID) // Tu servicio no devuelve opcional
            self.currentPlayer = player
            print("PlayerManager: Jugador \(player.username) cargado exitosamente.")
            
        } catch {
            // Maneja el error si fetchPlayer falla (ej. 404, error de red, error de decodificación)
            self.currentPlayer = nil // Asegúrate de que el jugador sea nil en caso de error
            self.errorMessage = "Error al cargar el jugador: \(error.localizedDescription)"
            print("PlayerManager: Error de red/API: \(error.localizedDescription)")
            
            // Aquí puedes añadir manejo de errores más específico si tu APIError lo permite
            if let apiError = error as? APIError {
                switch apiError {
                case .invalidURL:
                    self.errorMessage = "Error interno: URL inválida."
                case .requestFailed(let statusCode):
                    self.errorMessage = "Error de servidor: \(statusCode)."
                case .invalidResponse:
                    self.errorMessage = "Respuesta del servidor inválida."
                case .decodingError(let decodingErr):
                    self.errorMessage = "Error de decodificación: \(decodingErr.localizedDescription)."
                case .apiError(_, _):
                    self.errorMessage = "Error api. Error"
                case .unauthorized:
                    self.errorMessage = "Error api. Unautorized"
                case .notFound:
                    self.errorMessage = "Error api. notFound"
                case .unknown(_):
                    self.errorMessage = "Error api. unKnow"
                }
            }
        }
        isLoading = false
    }
    
    // Método para actualizar el jugador (por ejemplo, después de una edición de perfil)
    func updatePlayer(nPlayer: Player) {
        self.currentPlayer = nPlayer
        print("PlayerManager: Jugador actualizado localmente a \(nPlayer.username)")
        // Opcional: Aquí podrías llamar a playerService.updatePlayer si necesitas persistir el cambio
        // Task {
        //     do {
        //         _ = try await playerService.updatePlayer(id: nPlayer.id, player: PlayerUpdateRequest(...) )
        //         print("PlayerManager: Jugador actualizado en el servidor.")
        //     } catch {
        //         print("PlayerManager: Error al actualizar jugador en servidor: \(error.localizedDescription)")
        //     }
        // }
    }
    
    // Método para limpiar el jugador (por ejemplo, al cerrar sesión)
    func clearPlayer() {
        self.currentPlayer = nil
        print("PlayerManager: Jugador actual limpiado.")
    }
}
