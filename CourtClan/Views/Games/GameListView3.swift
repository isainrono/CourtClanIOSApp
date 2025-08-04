//
//  GameListView3.swift
//  CourtClan
//
//  Created by Isain Rodriguez Noreña on 4/8/25.
//

import SwiftUI

struct GameListView3: View {
    @StateObject private var viewModel = GameListViewModel()

    var body: some View {
        NavigationView {
            List {
                ForEach(viewModel.games) { game in
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Tipo: \(formattedGameType(game.gameType))")
                            .font(.headline)
                        Text("Fecha: \(game.formattedDate())")
                            .font(.subheadline)
                        Text("Hora: \(game.formattedStartTime())")
                            .font(.subheadline)
                        Text("Total Games: \(viewModel.games.count)")
                            .font(.subheadline)
                    }
                    .padding(.vertical, 6)
                    .onAppear {
                        if game == viewModel.games.last {
                            viewModel.fetchNextPage()
                            print("esta apareciendo!!!--------------")
                        }
                    }
                }

                if viewModel.isLoading {
                    HStack {
                        Spacer()
                        ProgressView()
                        Spacer()
                    }
                }
            }
            .navigationTitle("Partidos")
            .onAppear {
                if viewModel.games.isEmpty {
                    viewModel.fetchNextPage()
                }
            }
            .refreshable {
                viewModel.refresh()
            }
        }
    }

    private func formattedGameType(_ type: GameType) -> String {
        switch type {
        case .oneVsOne: return "1 vs 1"
        case .teamGame: return "Juego en equipo"
        }
    }
}

