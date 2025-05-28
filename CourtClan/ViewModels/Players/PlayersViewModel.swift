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
    @EnvironmentObject var appData: AppData
    @Published var players: [Player] = []
    @Published var isLoading: Bool = false
    @Published var errorMessage: String? = nil
    @Published var searchText: String = ""

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
        skillLevelId: String?, // <--- Tipo Correcto: String?
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
            skillLevelId: skillLevelId, // <--- Pasar directamente String?
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
            lastLogin: Date() // Laravel lo actualiza a `now()`, pero podemos enviarlo para consistencia
        )
        do {
            _ = try await playerService.createPlayer(player: newPlayerRequest)
            await fetchAllPlayers() // Refresca la lista
            showingAddEditSheet = false
        } catch {
            self.errorMessage = (error as? APIError)?.localizedDescription ?? error.localizedDescription
            print("Error creating player: \(error)")
        }
        isLoading = false
    }

    @MainActor
    func updatePlayer(
        id: String,
        username: String?,
        email: String?,
        passwordHash: String?,
        fullName: String?,
        bio: String?,
        profilePictureUrl: String?, // <--- Tipo Correcto: String?
        location: String?,
        dateOfBirth: Date?,
        gender: String?,
        preferredPosition: String?,
        skillLevelId: String?, // <--- Tipo Correcto: String?
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
            profilePictureUrl: profilePictureUrl, // <--- CORRECCIÓN AQUÍ: Usar profilePictureUrl
            location: location,
            dateOfBirth: dateOfBirth,
            gender: gender,
            preferredPosition: preferredPosition,
            skillLevelId: skillLevelId, // <--- Pasar directamente String?
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
            lastLogin: Date() // Laravel lo actualiza a `now()`, pero podemos enviarlo si queremos.
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
}
