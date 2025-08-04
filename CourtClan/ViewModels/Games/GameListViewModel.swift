//
//  GameListViewModel.swift
//  CourtClan
//
//  Created by Isain Rodriguez Noreña on 4/8/25.
//

import Foundation

class GameListViewModel: ObservableObject {
    @Published var games: [Game2] = []
    @Published var isLoading = false
    @Published var hasMorePages = true

    private var currentPage = 1
    private var lastPage = 1

    func fetchNextPage() {
        guard !isLoading, hasMorePages else { return }
        isLoading = true

        GameService3.shared.fetchGames(page: currentPage) { [weak self] result in
            guard let self = self else { return }
            self.isLoading = false

            switch result {
            case .success(let response):
                self.games.append(contentsOf: response.data)
                self.currentPage += 1
                self.lastPage = response.last_page
                self.hasMorePages = self.currentPage <= self.lastPage

            case .failure(let error):
                print("Error fetching games: \(error)")
            }
        }
    }

    func refresh() {
        games = []
        currentPage = 1
        lastPage = 1
        hasMorePages = true
        fetchNextPage()
    }
}

