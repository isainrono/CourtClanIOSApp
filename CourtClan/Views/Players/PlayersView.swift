//
//  PlayersView.swift
//  CourtClan
//
//  Created by Isain Rodriguez Noreña on 22/5/25.
//

import SwiftUI

struct PlayersView: View {
    @StateObject var viewModel: PlayersViewModel // Usa @StateObject para que la vista posea el ViewModel
    @EnvironmentObject var appData: AppData // Asumo que AppData es un EnvironmentObject
    @State var isPlayerDetailActive = false
    @State private var selectedPlayer: Player?
    
    init(viewModel: PlayersViewModel = PlayersViewModel()) {
        _viewModel = StateObject(wrappedValue: viewModel)
    }
    
    var body: some View {
        NavigationView {
            List {
                if viewModel.isLoading {
                    ProgressView("Cargando jugadores...")
                        .padding()
                } else if let errorMessage = viewModel.errorMessage {
                    Text("Error: \(errorMessage)")
                        .foregroundColor(.red)
                        .padding()
                } else if viewModel.filteredPlayers.isEmpty {
                    ContentUnavailableView.search(text: viewModel.searchText)
                } else {
                    ForEach(viewModel.filteredPlayers) { player in
                        Button {
                            selectedPlayer = player
                            isPlayerDetailActive = true
                        } label: {
                            PlayerRowView(player: player)
                        }
                        
                    }
                }
            }
            .navigationTitle("Jugadores")
            .searchable(text: $viewModel.searchText, prompt: "Buscar jugador")
            .toolbar {
                /*ToolbarItem(placement: .navigationBarTrailing) {
                 Button {
                 viewModel.presentAddSheet()
                 } label: {
                 Image(systemName: "plus.circle.fill")
                 .font(.title2)
                 }
                 }*/
            }
            .task { // Usa .task para cargar datos cuando la vista aparece
                await viewModel.fetchAllPlayers()
            }
            .sheet(item: $selectedPlayer) { player in
                if #available(iOS 16.0, *) {
                    PlayerDetailView(player: player)
                        .presentationDetents([.fraction(0.99)])
                        //.presentationDragIndicator(.visible)
                        .presentationBackground(.clear)
                } else {
                    PlayerDetailView(player: player)
                }
                
            }
            .alert("Error", isPresented: .constant(viewModel.errorMessage != nil)) {
                Button("OK") { viewModel.errorMessage = nil }
            } message: {
                Text(viewModel.errorMessage ?? "Ha ocurrido un error desconocido.")
            }
        }
    }
}


import SwiftUI

struct PlayerRowView: View {
    let player: Player
    
    var body: some View {
        HStack {
            if let urlString = player.profilePictureUrl, let url = URL(string: urlString) {
                AsyncImage(url: url) { image in
                    image
                        .resizable()
                        .scaledToFill()
                        .frame(width: 50, height: 50)
                        .clipShape(Circle())
                } placeholder: {
                    ProgressView()
                        .frame(width: 50, height: 50)
                        .background(Color.gray.opacity(0.3))
                        .clipShape(Circle())
                }
            } else {
                Image(systemName: "person.circle.fill")
                    .resizable()
                    .scaledToFill()
                    .frame(width: 50, height: 50)
                    .foregroundColor(.gray)
            }
            
            VStack(alignment: .leading) {
                Text(player.fullName ?? player.username)
                    .font(.headline)
                Text(player.username)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                if let location = player.location {
                    Text(location)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
            Spacer()
            VStack(alignment: .trailing) {
                Text("Nivel \(player.currentLevel)")
                    .font(.subheadline)
                Text("XP: \(player.totalXp)")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
        .padding(.vertical, 4)
    }
}

// --- Preview Provider ---
#Preview {
    
    PlayersView()
        .environmentObject(AppData()) // Pasa AppData si tu vista lo requiere
}
