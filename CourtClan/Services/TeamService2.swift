//
//  TeamService.swift
//  CourtClan
//
//  Created by Isain Rodriguez Noreña on 21/7/25.
//

import Foundation

final class TeamService2 {
    private let baseURL = "https://courtclan.com/api/teams"

    func fetchAllTeams() async throws -> [Team2] {
        let url = "\(baseURL)"
        let response: TeamsResponse = try await NetworkManager.shared.get(url)
        return response.teams
    }
    
    func fetchAllTeamsWithPlayers() async throws -> [TeamWithPlayersSimple] {
        let teams = try await fetchAllTeams()

        var teamsWithPlayers: [TeamWithPlayersSimple] = []

        for team in teams {
            do {
                let players = try await fetchTeamPlayers(teamId: team.id)
                let teamWithPlayers = TeamWithPlayersSimple(team: team, players: players)
                teamsWithPlayers.append(teamWithPlayers)
            } catch {
                print("❌ Error fetching players for team \(team.name): \(error)")
                teamsWithPlayers.append(TeamWithPlayersSimple(team: team, players: []))
            }
        }

        return teamsWithPlayers
    }


    func fetchTeam(by id: String) async throws -> Team2 {
        try await NetworkManager.shared.get("\(baseURL)/\(id)")
    }

    func createTeam(_ team: Team2) async throws -> Team2 {
        try await NetworkManager.shared.post(baseURL, body: team)
    }

    func updateTeam(_ team: Team2) async throws -> Team2 {
        try await NetworkManager.shared.put("\(baseURL)/\(team.id)", body: team)
    }

    func deleteTeam(id: String) async throws {
        try await NetworkManager.shared.delete("\(baseURL)/\(id)")
    }

    func fetchTeamPlayers(teamId: String) async throws -> [SimplePlayer] {
        let endpoint = "https://courtclan.com/api/teams/\(teamId)/players"
        guard let url = URL(string: endpoint) else {
            print("URL inválida")
            return []
        }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        do {
            let (data, response) = try await URLSession.shared.data(for: request)

            if let httpResponse = response as? HTTPURLResponse {
                print("Status code: \(httpResponse.statusCode)")
            }

            if let jsonString = String(data: data, encoding: .utf8) {
                print("Raw response JSON: \(jsonString)")
            }

            let decodedResponse = try JSONDecoder().decode(TeamPlayersWrapperSimple.self, from: data)
            print("Decoded response: \(decodedResponse)")

            return decodedResponse.players
        } catch {
            print("Error fetching players: \(error)")
            throw error
        }
    }




    // Búsqueda si implementas el endpoint
    func searchTeams(by query: String) async throws -> [Team2] {
        let url = "https://courtclan.com/api/teams/search?q=\(query)"
        let response: TeamsResponse = try await NetworkManager.shared.get(url)
        return response.teams
    }

    struct EmptyBody: Codable {}
}
