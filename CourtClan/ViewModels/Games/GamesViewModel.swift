//
//  GamesViewModel.swift
//  CourtClan
//
//  Created by Isain Rodriguez Noreña on 20/6/25.
//

import Foundation
import Combine
import SwiftUI // Necesario para @MainActor y @Published

// MARK: - GamesViewModel
@MainActor // Crucial for publishing changes to the UI
class GamesViewModel: ObservableObject {
    @EnvironmentObject var appData: AppData
    @Published var games: [Game] = []
    @Published var myGames: [Game] = []
    @Published var isLoading: Bool = false
    @Published var errorMessage: String? = nil
    @Published var paginationMetaData: PagedResponse<Game>?
    @Published var currentPage: Int = 1

    private let gameService: GameServiceProtocol
    
    // Un ID de jugador de ejemplo para "Mis Juegos". En una app real, vendría de autenticación.
    private let currentUserId: String = "aac386f1-26bc-4cc5-9d90-8513581bb546"

    // MARK: - Inicialización
    init(gameService: GameServiceProtocol = GameAPIService(baseURL: "https://courtclan.com/api")) { // Usa tu URL base real aquí
        self.gameService = gameService
    }

    // MARK: - Propiedades Calculadas
    var hasMorePages: Bool {
        guard let meta = paginationMetaData else { return false }
        return meta.currentPage < meta.lastPage
    }
    

    // MARK: - Métodos de Carga de Datos

    /// Carga todos los juegos, reseteando la paginación y la lista de juegos.
    func fetchAllGames() async {
        resetStateForNewFetch() // Reinicia el estado para una nueva carga
        isLoading = true
        do {
            let response = try await gameService.fetchAllGames(page: currentPage, limit: nil)
            self.games = response.data
            self.paginationMetaData = response
            print("✅ Todos los juegos cargados: \(response.data.count) de \(response.total)")
        } catch {
            self.errorMessage = (error as? APIError)?.localizedDescription ?? error.localizedDescription
            print("❌ Error al cargar todos los juegos: \(error)")
        }
        isLoading = false
    }
    
    /// Carga la siguiente página de juegos, añadiéndolos a la lista existente.
    func fetchNextPageOfAllGames() async {
        guard hasMorePages, !isLoading else { return }
        
        currentPage += 1
        isLoading = true
        errorMessage = nil

        do {
            let response = try await gameService.fetchAllGames(page: currentPage, limit: nil)
            self.games.append(contentsOf: response.data)
            self.paginationMetaData = response
            print("✅ Siguiente página de todos los juegos cargada: \(response.data.count) nuevos juegos. Total: \(self.games.count)")
        } catch {
            self.errorMessage = (error as? APIError)?.localizedDescription ?? error.localizedDescription
            print("❌ Error al cargar la siguiente página de todos los juegos: \(error)")
        }
        isLoading = false
    }

    /// Carga los juegos donde el usuario actual participa, reseteando la paginación y la lista.
    func fetchMyGames() async {
        resetStateForNewFetch() // Reinicia el estado para una nueva carga
        isLoading = true
        do {
            let response = try await gameService.fetchMyGames(playerId: currentUserId, page: currentPage, limit: nil)
            self.myGames = response.data
            self.paginationMetaData = response
            print("✅ Mis juegos cargados: \(response.data.count) de \(response.total)")
        } catch {
            self.errorMessage = (error as? APIError)?.localizedDescription ?? error.localizedDescription
            print("❌ Error al cargar mis juegos: \(error)")
        }
        isLoading = false
    }

    /// Carga la siguiente página de "mis juegos", añadiéndolos a la lista existente.
    func fetchNextPageOfMyGames() async {
        guard hasMorePages, !isLoading else { return }
        
        currentPage += 1
        isLoading = true
        errorMessage = nil

        do {
            let response = try await gameService.fetchMyGames(playerId: currentUserId, page: currentPage, limit: nil)
            self.games.append(contentsOf: response.data)
            self.paginationMetaData = response
            print("✅ Siguiente página de mis juegos cargada: \(response.data.count) nuevos juegos. Total: \(self.games.count)")
        } catch {
            self.errorMessage = (error as? APIError)?.localizedDescription ?? error.localizedDescription
            print("❌ Error al cargar la siguiente página de mis juegos: \(error)")
        }
        isLoading = false
    }
    
    // MARK: - Métodos Auxiliares
    
    /// Resetea el estado de paginación y la lista de juegos para una nueva búsqueda o filtro.
    private func resetStateForNewFetch() {
        currentPage = 1
        games = []
        paginationMetaData = nil
        errorMessage = nil
    }
}
