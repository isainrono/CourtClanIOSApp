//
//  GamesView.swift
//  CourtClan
//
//  Created by Isain Rodriguez Noreña on 20/6/25.
//

import SwiftUI


struct GamesListView: View {
    @StateObject var viewModel: GamesViewModel // Usa @StateObject para la vida del ViewModel

    // Constructor para inyectar un ViewModel, útil para Previews
    /*init(viewModel: GamesViewModel = GamesViewModel()) {
        _viewModel = StateObject(wrappedValue: viewModel)
    }*/

    var body: some View {
        NavigationView {
            List {
                // Sección para mostrar el estado de carga o error
                if viewModel.isLoading && viewModel.games.isEmpty {
                    ProgressView("Cargando juegos...")
                        .frame(maxWidth: .infinity, alignment: .center)
                        .padding()
                } else if let errorMessage = viewModel.errorMessage {
                    Text(errorMessage)
                        .foregroundColor(.red)
                        .padding()
                        .frame(maxWidth: .infinity, alignment: .center)
                } else if viewModel.games.isEmpty {
                    Text("No hay juegos disponibles.")
                        .foregroundColor(.gray)
                        .padding()
                        .frame(maxWidth: .infinity, alignment: .center)
                } else {
                    // Muestra cada juego en una fila
                    ForEach(viewModel.games) { game in
                        GameRowView(game: game) // Reutiliza la vista GameRowView
                            .onAppear {
                                // Carga la siguiente página cuando el último elemento visible está cerca
                                if game.id == viewModel.games.last?.id {
                                    Task {
                                        await viewModel.fetchNextPageOfAllGames()
                                    }
                                }
                            }
                    }

                    // Indicador de carga para la siguiente página
                    if viewModel.hasMorePages && viewModel.isLoading {
                        ProgressView()
                            .frame(maxWidth: .infinity, alignment: .center)
                            .padding(.vertical)
                    }
                }
            }
            .navigationTitle("Todos los Partidos")
            .navigationBarTitleDisplayMode(.large)
            .onAppear {
                // Carga los juegos cuando la vista aparece por primera vez
                // Solo carga si la lista está vacía para evitar recargas innecesarias
                if viewModel.games.isEmpty {
                    Task {
                        await viewModel.fetchAllGames()
                    }
                }
            }
            .refreshable { // Permite "pull-to-refresh"
                // Reinicia la paginación y recarga todos los juegos
                await viewModel.fetchAllGames()
            }
        }
    }
}

// ---
// MARK: - GameRowView (Para la fila individual del juego)
// Puedes colocar esto en un archivo separado si prefieres
struct GameRowView: View {
    let game: Game

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text("Partido en **\(game.court?.name ?? "Cancha Desconocida")**")
                .font(.headline)
                .lineLimit(1)

            Text("Fecha: \(game.displayDate) | Hora: \(game.displayStartTime)")
                .font(.subheadline)
                .foregroundColor(.secondary)

            if game.gameType == .oneVsOne {
                Text("Jugadores: **\(game.player1?.username ?? "N/A")** vs **\(game.player2?.username ?? "N/A")**")
                    .font(.caption)
                Text("player1id--: \(game.player1Id)")
                    .font(.caption2)
                    .foregroundColor(.blue)

            } else {
                // Debugging for team games
                Text("Game Type: \(game.gameType.rawValue)")
                    .font(.caption2)
                    .foregroundColor(.blue)
                
                Text("Game Type--: \(game.homeTeamId)")
                    .font(.caption2)
                    .foregroundColor(.blue)

                if let homeTeam = game.homeTeam {
                    Text("Home Team Exists: \(homeTeam.name ?? "Name N/A") (ID: \(homeTeam.id))")
                        .font(.caption)
                        .foregroundColor(.green)
                } else {
                    Text("Home Team: NIL")
                        .font(.caption)
                        .foregroundColor(.red)
                }

                if let awayTeam = game.awayTeam {
                    Text("Away Team Exists: \(awayTeam.name ?? "Name N/A") (ID: \(awayTeam.id))")
                        .font(.caption)
                        .foregroundColor(.green)
                } else {
                    Text("Away Team: NIL")
                        .font(.caption)
                        .foregroundColor(.red)
                }

                // Your original display line (keep it for comparison)
                Text("Equipos: **\(game.homeTeam?.name ?? "N/A")** vs **\(game.awayTeam?.name ?? "N/A")**")
                    .font(.caption)
                // Your ID display line
                Text("Away Team ID Check: \(game.awayTeam?.id ?? "ID Nulo en Game Object")")
            }
            Text("Estado: \(game.gameStatus.rawValue.capitalized.replacingOccurrences(of: "_", with: " "))")
                .font(.caption2)
                .foregroundColor(.gray)
        }
        .padding(.vertical, 4)
    }
}
