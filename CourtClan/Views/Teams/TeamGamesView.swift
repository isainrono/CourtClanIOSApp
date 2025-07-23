//
//  TeamGamesView.swift
//  CourtClan
//
//  Created by Isain Rodriguez Noreña on 21/7/25.
//

import SwiftUI

struct TeamGamesView: View {
    @StateObject private var viewModel = GamesViewModel2()
    @State var selectedGame: Game2?
    
    var body: some View {
        NavigationView {
            Group {
                if viewModel.isLoading {
                    ProgressView("Cargando...")
                } else if viewModel.games.isEmpty {
                    Text("No hay partidos disponibles.")
                        .foregroundColor(.gray)
                        .italic()
                } else {
                    List{
                        ForEach(viewModel.games) { game in
                            Button {
                                selectedGame = game
                            } label: {
                                CCGameView2(game: game) // 👈 Aquí se llama tu vista personalizada
                                    .listRowBackground(Color.clear)
                                    .listRowSeparator(.hidden)
                                    .listRowInsets(EdgeInsets(top: 8, leading: 0, bottom: 8, trailing: 0))
                            }
                            
                        }
                        .listStyle(PlainListStyle())
                    }
                    
                }
            }
            .navigationTitle("Partidos")
            .alert("Error", isPresented: Binding<Bool>(
                get: { viewModel.errorMessage != nil },
                set: { newValue in
                    if !newValue {
                        viewModel.errorMessage = nil
                    }
                }
            )) {
                Button("OK", role: .cancel) {
                    viewModel.errorMessage = nil
                }
            } message: {
                Text(viewModel.errorMessage ?? "")
            }
            .onAppear {
                viewModel.loadAllGames()
            }
            .sheet(item: $selectedGame) { gameToManage in // 'gameToManage' will be non-nil here
                ManageGame2View(game: gameToManage)
                    // You can still keep .id() here, as it ensures SwiftUI
                    // rebuilds ManageGameView even if 'selectedGame' is the same instance
                    // but the sheet was dismissed and reopened.
                    .id(gameToManage.id)
            }
        }
    }
    
    private func friendlyGameType(_ type: GameType) -> String {
        switch type {
        case .oneVsOne: return "Uno contra Uno"
        case .teamGame: return "Juego en Equipo"
        }
    }
    
    private func friendlyGameStatus(_ status: GameStatus) -> String {
        switch status {
        case .scheduled: return "Programado"
        case .inProgress: return "En progreso"
        case .finished: return "Finalizado"
        case .postponed: return "Pospuesto"
        case .cancelled: return "Cancelado"
        }
    }
}

#Preview {
    TeamGamesView()
}

