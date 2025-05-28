//
//  TeamsViewModel.swift
//  CourtClan
//
//  Created by Isain Rodriguez Noreña on 21/5/25.
//


import Foundation
import Combine

// MARK: - Teams ViewModel
class TeamsViewModel: ObservableObject {
    @Published var teams: [Team] = []
    @Published var isLoading: Bool = false
    @Published var errorMessage: String? = nil
    @Published var searchText: String = ""

    // Para la hoja de añadir/editar
    @Published var showingAddEditSheet: Bool = false
    @Published var selectedTeam: Team? = nil // Para editar un equipo existente

    private let teamService: TeamServiceProtocol // Dependencia inyectada

    // Inyección de dependencia para el servicio.
    // ¡IMPORTANTE!: Reemplaza "https://your-laravel-api-url.com/api" con la URL base real de tu API de Laravel.
    init(teamService: TeamServiceProtocol = TeamAPIService(baseURL: "https://courtclan.com/api")) {
        self.teamService = teamService
    }

    // Propiedad computada para filtrar los equipos
    var filteredTeams: [Team] {
        guard !searchText.isEmpty else { return teams }
        return teams.filter { team in
            team.name.localizedCaseInsensitiveContains(searchText) ||
            (team.description?.localizedCaseInsensitiveContains(searchText) ?? false)
        }
    }

    @MainActor // Asegura que las actualizaciones de UI se hagan en el hilo principal
    func fetchAllTeams() async {
        isLoading = true
        errorMessage = nil
        do {
            self.teams = try await teamService.fetchAllTeams()
        } catch {
            self.errorMessage = (error as? APIError)?.localizedDescription ?? error.localizedDescription
            print("Error fetching all teams: \(error)")
        }
        isLoading = false
    }

    @MainActor
    func createTeam(name: String, description: String?, logoUrl: String?, ownerUserId: String, captainUserId: String?, teamFunds: Double?) async {
        isLoading = true
        errorMessage = nil
        let newTeamRequest = TeamCreateRequest(
            name: name,
            description: description,
            logoUrl: logoUrl,
            ownerUserId: ownerUserId,
            captainUserId: captainUserId,
            teamFunds: teamFunds
        )
        do {
            _ = try await teamService.createTeam(team: newTeamRequest)
            await fetchAllTeams() // Refresca la lista después de crear
            showingAddEditSheet = false // Cierra la hoja
        } catch {
            self.errorMessage = (error as? APIError)?.localizedDescription ?? error.localizedDescription
            print("Error creating team: \(error)")
        }
        isLoading = false
    }

    @MainActor
    func updateTeam(id: String, name: String?, description: String?, logoUrl: String?, ownerUserId: String?, captainUserId: String?, teamFunds: Double?) async {
        isLoading = true
        errorMessage = nil
        let updateTeamRequest = TeamUpdateRequest(
            name: name,
            description: description,
            logoUrl: logoUrl,
            ownerUserId: ownerUserId,
            captainUserId: captainUserId,
            teamFunds: teamFunds
        )
        do {
            _ = try await teamService.updateTeam(id: id, team: updateTeamRequest)
            await fetchAllTeams() // Refresca la lista después de actualizar
            showingAddEditSheet = false // Cierra la hoja
        } catch {
            self.errorMessage = (error as? APIError)?.localizedDescription ?? error.localizedDescription
            print("Error updating team: \(error)")
        }
        isLoading = false
    }

    @MainActor
    func deleteTeam(teamId: String) async {
        isLoading = true
        errorMessage = nil
        do {
            try await teamService.deleteTeam(id: teamId)
            // Una vez eliminado de la API, también lo eliminamos de la lista local
            teams.removeAll { $0.id == teamId }
        } catch {
            self.errorMessage = (error as? APIError)?.localizedDescription ?? error.localizedDescription
            print("Error deleting team: \(error)")
        }
        isLoading = false
    }

    // MARK: - Helper Methods for UI interaction

    // Prepara la hoja para añadir un nuevo equipo
    func presentAddSheet() {
        selectedTeam = nil // Asegura que no estamos editando un equipo existente
        showingAddEditSheet = true
    }

    // Prepara la hoja para editar un equipo existente
    func presentEditSheet(team: Team) {
        selectedTeam = team // Pasa el equipo que se va a editar
        showingAddEditSheet = true
    }
}
