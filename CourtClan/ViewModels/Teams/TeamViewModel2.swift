//
//  TeamViewModel2.swift
//  CourtClan
//
//  Created by Isain Rodriguez Noreña on 21/7/25.
//

import Foundation

@MainActor
final class TeamViewModel2: ObservableObject {
    @Published var teams: [Team2] = []
    @Published var selectedTeam: Team2? = nil
    @Published var teamPlayers: [SimplePlayer] = []
    @Published var isLoading: Bool = false
    @Published var errorMessage: String? = nil
    @Published var searchQuery: String = ""
    @Published var teamsWithPlayers: [TeamWithPlayersSimple] = []
    let service = TeamService2()

    // MARK: - Cargar todos los equipos
    func loadAllTeams() async {
        await performLoading {
            self.teams = try await self.service.fetchAllTeams()
        }
    }
    
    func loadTeamsWithPlayers() async {
            isLoading = true
            errorMessage = nil

            do {
                let result = try await self.service.fetchAllTeamsWithPlayers()
                teamsWithPlayers = result
            } catch {
                errorMessage = "Error cargando equipos: \(error.localizedDescription)"
                print("[TeamViewModel2] Error: \(error)")
            }

            isLoading = false
        }


    // MARK: - Buscar equipos por nombre
    func searchTeams() async {
        guard !searchQuery.trimmingCharacters(in: .whitespaces).isEmpty else {
            await loadAllTeams()
            return
        }

        await performLoading {
            self.teams = try await self.service.searchTeams(by: self.searchQuery)
        }
    }

    // MARK: - Seleccionar equipo
    func selectTeam(_ team: Team2) async {
        selectedTeam = team
        await loadPlayers(for: team.id)
    }

    // MARK: - Cargar jugadores de un equipo
    func loadPlayers(for teamId: String) async {
        await performLoading {
            self.teamPlayers = try await self.service.fetchTeamPlayers(teamId: teamId)
        }
    }

    // MARK: - Crear equipo
    func createTeam(_ team: Team2) async {
        await performLoading {
            let newTeam = try await self.service.createTeam(team)
            self.teams.append(newTeam)
        }
    }

    // MARK: - Actualizar equipo
    func updateTeam(_ team: Team2) async {
        await performLoading {
            let updated = try await self.service.updateTeam(team)
            if let index = self.teams.firstIndex(where: { $0.id == updated.id }) {
                self.teams[index] = updated
            }
        }
    }

    // MARK: - Eliminar equipo
    func deleteTeam(_ team: Team2) async {
        await performLoading {
            try await self.service.deleteTeam(id: team.id)
            self.teams.removeAll { $0.id == team.id }
        }
    }

    // MARK: - Función auxiliar para manejar carga/errores
    private func performLoading(_ operation: @escaping () async throws -> Void) async {
        isLoading = true
        errorMessage = nil
        defer { isLoading = false }

        do {
            try await operation()
        } catch {
            errorMessage = "Error: \(error.localizedDescription)"
            print("[TeamViewModel2] Error:", error)
        }
    }
}
