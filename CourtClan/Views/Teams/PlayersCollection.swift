//
//  PlayersCollection.swift
//  CourtClan
//
//  Created by Isain Rodriguez Noreña on 16/7/25.
//

import SwiftUI

struct PlayersCollection: View {
    
    @State var imageHeight: CGFloat = 150
    @State var imageWidth: CGFloat = 120
    
    var simplePlayers: [SimplePlayer]
    
    @State private var players: [Player] = []
    @State private var isLoading = false
    @State private var error: String?
    
    @Namespace private var animation
    @State private var selectedPlayer: Player? = nil
    @State private var showDetail = false
    
    let viewModel = PlayersViewModel()
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Jugadores")
                .font(.title2)
                .fontWeight(.bold)
                .padding(.horizontal)
            
            if isLoading {
                ProgressView("Cargando jugadores...")
                    .padding()
            } else if let error = error {
                Text("Error: \(error)")
                    .foregroundColor(.red)
                    .padding()
            } else {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 16) {
                        ForEach(players) { player in
                            PlayerCardView(player: player, isSelected: selectedPlayer?.id == player.id, animation: animation)
                                .onTapGesture {
                                    withAnimation(.spring(response: 0.5, dampingFraction: 0.7)) {
                                        selectedPlayer = player
                                        showDetail = true
                                    }
                                }
                        }
                    }
                    .padding(.horizontal)
                }
                .frame(height: 220)
            }
        }
        .task {
            await loadFullPlayers()
        }
        .sheet(isPresented: $showDetail) {
            if let selected = selectedPlayer {
                PlayerDetailView(player: selected)
            }
        }
    }
    
    private func loadFullPlayers() async {
        isLoading = true
        error = nil
        var loadedPlayers: [Player] = []
        
        for simple in simplePlayers {
            if let full = await viewModel.fetchPlayerByID(id: simple.player_id) {
                loadedPlayers.append(full)
            }
        }
        
        await MainActor.run {
            self.players = loadedPlayers
            self.isLoading = false
        }
    }
}
