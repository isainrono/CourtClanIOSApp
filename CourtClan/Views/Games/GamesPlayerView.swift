//
//  GamesPlayerView.swift
//  CourtClan
//
//  Created by Isain Rodriguez Noreña on 25/6/25.
//

import SwiftUI

struct GamesPlayerView: View {

    @StateObject var viewModel: GamesViewModel

    @EnvironmentObject var appData: AppData
    // Removed @State var showManageGame: Bool = false
    @State var selectedGame: Game? // This will now control the sheet directly

    var body: some View {
        NavigationView {
            List {
                if viewModel.isLoading && viewModel.myGames.isEmpty {
                    ProgressView("Cargando tus juegos...")
                        .frame(maxWidth: .infinity, alignment: .center)
                        .padding()
                } else if let errorMessage = viewModel.errorMessage {
                    Text(errorMessage)
                        .foregroundColor(.red)
                        .padding()
                        .frame(maxWidth: .infinity, alignment: .center)
                } else if viewModel.myGames.isEmpty {
                    Text("No tienes partidos registrados o no se encontraron para tu ID.")
                        .foregroundColor(.gray)
                        .padding()
                        .frame(maxWidth: .infinity, alignment: .center)
                } else {
                    ForEach(viewModel.myGames) { game in
                        Button {
                            // Directly assign the game. The sheet will react to this.
                            selectedGame = game
                            print("GamesPlayerView: Game tapped - Set selectedGame to ID: \(game.id)")
                        } label: {
                            CCGameView(game: game)
                                .listRowBackground(Color.clear)
                                .listRowSeparator(.hidden)
                                .listRowInsets(EdgeInsets(top: 5, leading: 0, bottom: 0, trailing: 0))
                        }
                    }

                    if viewModel.hasMorePages && viewModel.isLoading {
                        ProgressView()
                            .frame(maxWidth: .infinity, alignment: .center)
                            .padding(.vertical)
                    }
                }
            }
            .navigationTitle("Mis Partidos")
            .navigationBarTitleDisplayMode(.large)
            .onAppear {
                if viewModel.myGames.isEmpty {
                    Task {
                        print("GamesPlayerView: onAppear - Fetching games.")
                        await viewModel.fetchMyGames()
                    }
                }
            }
            .refreshable {
                print("GamesPlayerView: refreshable - Fetching games.")
                await viewModel.fetchMyGames()
            }
            // ************************************************************
            // CAMBIO CLAVE: Usar sheet(item:...) en lugar de sheet(isPresented:...)
            // ************************************************************
            .sheet(item: $selectedGame) { gameToManage in // 'gameToManage' will be non-nil here
                ManageGameView(game: gameToManage)
                    // You can still keep .id() here, as it ensures SwiftUI
                    // rebuilds ManageGameView even if 'selectedGame' is the same instance
                    // but the sheet was dismissed and reopened.
                    .id(gameToManage.id)
            }
            // The .environmentObject(appData) at the NavigationView level is fine.
        }
        .environmentObject(appData)
    }
}


#Preview {
    let gamesViewModel: GamesViewModel = GamesViewModel()
    GamesPlayerView(viewModel: gamesViewModel)
        .environmentObject(AppData())
}
