//
//  GameViewModel2.swift
//  CourtClan
//
//  Created by Isain Rodriguez Noreña on 21/7/25.
//

import Foundation
import Combine

@MainActor
class GamesViewModel2: ObservableObject {
    @Published var games: [Game2] = []
    @Published var isLoading = false
    @Published var errorMessage: String?

    private let service = GameService2.shared

    func loadAllGames() {
        isLoading = true
        errorMessage = nil
        service.fetchAllGames { result in
            self.isLoading = false
            switch result {
            case .success(let games):
                self.games = games
            case .failure(let error):
                self.errorMessage = error.localizedDescription
            }
        }
    }

    func loadGamesByType(_ type: GameType) {
        isLoading = true
        errorMessage = nil
        service.fetchGamesByType(type) { result in
            self.isLoading = false
            switch result {
            case .success(let games):
                self.games = games
            case .failure(let error):
                self.errorMessage = error.localizedDescription
            }
        }
    }

    func loadGamesByStatus(_ status: GameStatus) {
        isLoading = true
        errorMessage = nil
        service.fetchGamesByStatus(status) { result in
            self.isLoading = false
            switch result {
            case .success(let games):
                self.games = games
            case .failure(let error):
                self.errorMessage = error.localizedDescription
            }
        }
    }

    func loadMyGames(playerId: String) {
        isLoading = true
        errorMessage = nil
        service.fetchMyGames(playerId: playerId) { result in
            self.isLoading = false
            switch result {
            case .success(let games):
                self.games = games
            case .failure(let error):
                self.errorMessage = error.localizedDescription
            }
        }
    }

    func loadGame(id: String, completion: @escaping (Game2?) -> Void) {
        service.fetchGame(id: id) { result in
            switch result {
            case .success(let game):
                completion(game)
            case .failure(let error):
                self.errorMessage = error.localizedDescription
                completion(nil)
            }
        }
    }

    func deleteGame(id: String) async {
        isLoading = true
        do {
            try await withCheckedThrowingContinuation { continuation in
                service.deleteGame(id: id) { result in
                    self.isLoading = false
                    switch result {
                    case .success:
                        self.games.removeAll { $0.id == id }
                        continuation.resume()
                    case .failure(let error):
                        self.errorMessage = error.localizedDescription
                        continuation.resume(throwing: error)
                    }
                }
            }
        } catch {
            print("Delete failed: \(error)")
        }
    }

    func finalizeGame(id: String, homeScore: Int, awayScore: Int) async {
        isLoading = true
        let body: [String: Any] = [
            "home_score": homeScore,
            "away_score": awayScore
        ]

        do {
            try await withCheckedThrowingContinuation { continuation in
                service.finalizeGame(id: id, scores: body) { result in
                    self.isLoading = false
                    switch result {
                    case .success(let updatedGame):
                        if let index = self.games.firstIndex(where: { $0.id == id }) {
                            self.games[index] = updatedGame
                        }
                        continuation.resume()
                    case .failure(let error):
                        self.errorMessage = error.localizedDescription
                        continuation.resume(throwing: error)
                    }
                }
            }
        } catch {
            print("Finalize error: \(error)")
        }
    }
}

