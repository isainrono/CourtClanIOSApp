//
//  PlayersViewModel.swift
//  CourtClan
//
//  Created by Isain Rodriguez Noreña on 22/5/25.
//


import Foundation
import Combine
import SwiftUI // Necesario para @MainActor y @Published

class PlayersViewModel: ObservableObject {
    //@EnvironmentObject var appData: AppData
    @Published var players: [Player] = []
    @Published var isLoading: Bool = false
    @Published var errorMessage: String? = nil
    @Published var searchText: String = ""
    @Published var currentPlayer: Player? = nil
    @Published var showingAddEditSheet: Bool = false
    @Published var selectedPlayer: Player? = nil // Para editar un jugador existente
    
    private let playerService: PlayerServiceProtocol
    
    // Inyección de dependencia para el servicio.
    // ¡IMPORTANTE!: Reemplaza "https://your-laravel-api-url.com/api" con la URL base real de tu API de Laravel.
    init(playerService: PlayerServiceProtocol = PlayerAPIService(baseURL: "https://courtclan.com/api")) {
        self.playerService = playerService
    }
    
    
    var filteredPlayers: [Player] {
        guard !searchText.isEmpty else { return players }
        return players.filter { player in
            player.username.localizedCaseInsensitiveContains(searchText) ||
            (player.fullName?.localizedCaseInsensitiveContains(searchText) ?? false) ||
            (player.location?.localizedCaseInsensitiveContains(searchText) ?? false)
        }
    }
    
    @MainActor
    func fetchAllPlayers() async {
        isLoading = true
        errorMessage = nil
        do {
            self.players = try await playerService.fetchAllPlayers()
        } catch {
            self.errorMessage = (error as? APIError)?.localizedDescription ?? error.localizedDescription
            print("Error fetching all players: \(error)")
        }
        isLoading = false
    }
    
    @MainActor
    func fetchPlayerByID(id: String) async -> Player? {
        isLoading = true
        errorMessage = nil
        do {
            let player = try await playerService.fetchPlayer(id: id)
            // No actualizamos la lista 'players' aquí, ya que esto es para un jugador específico
            // Puedes actualizar 'selectedPlayer' si este método es para cargar un jugador para edición/detalle.
            // self.selectedPlayer = player
            print("✅ Jugador con ID \(id) encontrado: \(player.username)")
            isLoading = false
            return player
        } catch {
            self.errorMessage = (error as? APIError)?.localizedDescription ?? error.localizedDescription
            print("❌ Error al buscar jugador con ID \(id): \(error)")
            isLoading = false
            return nil // Retorna nil en caso de error
        }
    }
    
    // --- FUNCIÓN createPlayer MODIFICADA ---
    @MainActor
    func createPlayer(
        username: String,
        email: String,
        passwordHash: String,
        fullName: String?,
        bio: String?,
        profilePictureUrl: String?,
        location: String?,
        dateOfBirth: Date?,
        gender: String?,
        preferredPosition: String?,
        skillLevelId: String?,
        currentLevel: Int?,
        totalXp: Int?,
        gamesPlayed: Int?,
        gamesWon: Int?,
        winPercentage: Double?,
        avgPointsPerGame: Double?,
        avgAssistsPerGame: Double?,
        avgReboundsPerGame: Double?,
        avgBlocksPerGame: Double?,
        avgStealsPerGame: Double?,
        isPublic: Bool?,
        isActive: Bool?,
        currentTeamId: String?,
        marketValue: Double?,
        isFreeAgent: Bool?
    ) async throws -> Player { // <-- ¡CAMBIO AQUÍ: Ahora devuelve 'Player' y es 'throws'!
        isLoading = true
        errorMessage = nil
        
        let newPlayerRequest = PlayerCreateRequest(
            username: username,
            email: email,
            passwordHash: passwordHash,
            fullName: fullName,
            bio: bio,
            profilePictureUrl: profilePictureUrl,
            location: location,
            dateOfBirth: dateOfBirth,
            gender: gender,
            preferredPosition: preferredPosition,
            skillLevelId: skillLevelId,
            currentLevel: currentLevel,
            totalXp: totalXp,
            gamesPlayed: gamesPlayed,
            gamesWon: gamesWon,
            winPercentage: winPercentage,
            avgPointsPerGame: avgPointsPerGame,
            avgAssistsPerGame: avgAssistsPerGame,
            avgReboundsPerGame: avgReboundsPerGame,
            avgBlocksPerGame: avgBlocksPerGame,
            avgStealsPerGame: avgStealsPerGame,
            isPublic: isPublic,
            isActive: isActive,
            currentTeamId: currentTeamId,
            marketValue: marketValue,
            isFreeAgent: isFreeAgent,
            lastLogin: Date()
        )
        
        do {
            let createdPlayer = try await playerService.createPlayer(player: newPlayerRequest) // <-- ¡Captura el jugador creado!
            await fetchAllPlayers() // Refresca la lista de jugadores en el ViewModel
            showingAddEditSheet = false
            isLoading = false // Mover isLoading a false antes de devolver
            return createdPlayer // <-- ¡DEVUELVE el jugador creado!
        } catch {
            self.errorMessage = (error as? APIError)?.localizedDescription ?? error.localizedDescription
            print("Error creating player: \(error.localizedDescription)") // Usar .localizedDescription para logs
            isLoading = false // Asegurarse de que isLoading se restablece incluso en caso de error
            throw error // <-- ¡RELANZA el error para que el llamador lo maneje!
        }
    }
    // --- FIN DE LA FUNCIÓN createPlayer MODIFICADA ---
    
    
    @MainActor
    func updatePlayer(
        id: String,
        username: String?,
        email: String?,
        passwordHash: String?,
        fullName: String?,
        bio: String?,
        profilePictureUrl: String?,
        location: String?,
        dateOfBirth: Date?,
        gender: String?,
        preferredPosition: String?,
        skillLevelId: String?,
        currentLevel: Int?,
        totalXp: Int?,
        gamesPlayed: Int?,
        gamesWon: Int?,
        winPercentage: Double?,
        avgPointsPerGame: Double?,
        avgAssistsPerGame: Double?,
        avgReboundsPerGame: Double?,
        avgBlocksPerGame: Double?,
        avgStealsPerGame: Double?,
        isPublic: Bool?,
        isActive: Bool?,
        currentTeamId: String?,
        marketValue: Double?,
        isFreeAgent: Bool?
    ) async {
        isLoading = true
        errorMessage = nil
        let updatePlayerRequest = PlayerUpdateRequest(
            username: username,
            email: email,
            passwordHash: passwordHash,
            fullName: fullName,
            bio: bio,
            profilePictureUrl: profilePictureUrl,
            location: location,
            dateOfBirth: dateOfBirth,
            gender: gender,
            preferredPosition: preferredPosition,
            skillLevelId: skillLevelId,
            currentLevel: currentLevel,
            totalXp: totalXp,
            gamesPlayed: gamesPlayed,
            gamesWon: gamesWon,
            winPercentage: winPercentage,
            avgPointsPerGame: avgPointsPerGame,
            avgAssistsPerGame: avgAssistsPerGame,
            avgReboundsPerGame: avgReboundsPerGame,
            avgBlocksPerGame: avgBlocksPerGame,
            avgStealsPerGame: avgStealsPerGame,
            isPublic: isPublic,
            isActive: isActive,
            currentTeamId: currentTeamId,
            marketValue: marketValue,
            isFreeAgent: isFreeAgent,
            lastLogin: Date()
        )
        do {
            _ = try await playerService.updatePlayer(id: id, player: updatePlayerRequest)
            await fetchAllPlayers() // Refresca la lista
            showingAddEditSheet = false
        } catch {
            self.errorMessage = (error as? APIError)?.localizedDescription ?? error.localizedDescription
            print("Error updating player: \(error)")
        }
        isLoading = false
    }
    
    @MainActor
    func deletePlayer(playerId: String) async {
        isLoading = true
        errorMessage = nil
        do {
            try await playerService.deletePlayer(id: playerId)
            players.removeAll { $0.id == playerId }
        } catch {
            self.errorMessage = (error as? APIError)?.localizedDescription ?? error.localizedDescription
            print("Error deleting player: \(error)")
        }
        isLoading = false
    }
    
    // MARK: - Helper Methods for UI interaction
    
    func presentAddSheet() {
        selectedPlayer = nil
        showingAddEditSheet = true
    }
    
    func presentEditSheet(player: Player) {
        selectedPlayer = player
        showingAddEditSheet = true
    }
    
    // Método para limpiar el jugador actual (ej. al cerrar sesión)
    func clearCurrentUser() {
        self.currentPlayer = nil
        // Opcional: También podrías limpiar UserDefaults aquí si es un cierre de sesión
        UserDefaults.standard.removeObject(forKey: "playerid")
        print("PlayersViewModel: Jugador actual limpiado y playerid de UserDefaults eliminado.")
    }
}
