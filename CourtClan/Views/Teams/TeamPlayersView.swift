//
//  TeamPlayersView.swift
//  CourtClan
//
//  Created by Isain Rodriguez Noreña on 21/7/25.
//

import SwiftUI

struct TeamPlayersView: View {
    @StateObject private var viewModel = TeamViewModel2()
    @State private var teamSelected: Team2?
    @EnvironmentObject var appData: AppData
    

    var body: some View {
        NavigationView {
            VStack {
                if viewModel.isLoading {
                    ProgressView("Cargando equipos...")
                } else if let error = viewModel.errorMessage {
                    Text(error)
                        .foregroundColor(.red)
                        .multilineTextAlignment(.center)
                        .padding()
                } else {
                    List(viewModel.teams) { team in
                        Button {
                            teamSelected = team
                        } label: {
                            Text(team.name)
                                .font(.headline)
                        }
                    }
                    .listStyle(.plain)
                }
            }
            .navigationTitle("Equipos")
            .task {
                await viewModel.loadAllTeams()
            }
            .sheet(item: $teamSelected) { team in
                TeamDetailView(team: team, viewModel: viewModel)
                /*TeamProfileView(teamSelected:team)
                    .environmentObject(appData)*/
            }
        }
    }
}


struct TeamDetailView: View {
    let team: Team2
    @State var imageHeigth = 100
    @State var imageWidth = 100
    @ObservedObject var viewModel: TeamViewModel2
    @State private var captain: Player?
    @EnvironmentObject var playerViewModel: PlayersViewModel

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                
                // Encabezado con imagen y nombre
                VStack(alignment: .center, spacing: 16) {
                    if let logoUrl = team.logoURL, let url = URL(string: logoUrl) {
                        AsyncImage(url: url) { image in
                            image
                                .resizable()
                                .scaledToFill()
                                .frame(width: 100, height: 100)
                                .clipShape(Circle())
                                .overlay(Circle().stroke(Color.white, lineWidth: 3))
                                .shadow(radius: 6)
                        } placeholder: {
                            ProgressView()
                                .frame(width: 100, height: 100)
                                .clipShape(Circle())
                                .background(Color.gray.opacity(0.2))
                        }
                    } else {
                        Image(systemName: "person.3.fill")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 100, height: 100)
                            .foregroundColor(.white)
                            .background(Circle().fill(Color.blue))
                            .shadow(radius: 6)
                    }

                    VStack(alignment: .leading) {
                        Text(team.name)
                            .font(.largeTitle)
                            .fontWeight(.bold)
                            .foregroundStyle(LinearGradient(
                                colors: [.blue, .purple],
                                startPoint: .leading,
                                endPoint: .trailing
                            ))
                        Text("ID equipo: \(team.id)")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                }
                .padding(.horizontal)

                Divider()

                // Capitán
                VStack(alignment: .leading, spacing: 8) {

                    CaptainCardView(captainId: team.captainPlayerId)
                        .environmentObject(playerViewModel)
                        .padding(.vertical, 8)
                }

                Divider()

                // Jugadores
                VStack(alignment: .leading, spacing: 8) {

                    if viewModel.teamPlayers.isEmpty {
                        Text("No hay jugadores registrados.")
                            .foregroundColor(.gray)
                    } else {
                        PlayersCollection(simplePlayers: viewModel.teamPlayers)
                    }
                }

            }
            .padding()
        }
        .navigationTitle("Detalle del Equipo")
        .background(
            LinearGradient(colors: [.white, Color(.systemGray6)], startPoint: .top, endPoint: .bottom)
                .ignoresSafeArea()
        )
        .task {
            await viewModel.loadPlayers(for: team.id)
        }
    }

}



/*

struct TeamPlayersView: View {
    @StateObject private var viewModel = TeamViewModel2()

    var body: some View {
        NavigationView {
            List {
                ForEach(viewModel.teams, id: \.id) { team in
                    TeamSectionView(
                        team: team,
                        isSelected: viewModel.selectedTeam?.id == team.id,
                        players: viewModel.selectedTeam?.id == team.id ? viewModel.teamPlayers : [],
                        onSelect: {
                            Task { await viewModel.selectTeam(team) }
                        }
                    )
                }
            }
            .navigationTitle("Equipos")
            .searchable(text: $viewModel.searchQuery)
            .onSubmit(of: .search) {
                Task { await viewModel.searchTeams() }
            }
            .onAppear {
                Task { await viewModel.loadAllTeams() }
            }

            if viewModel.isLoading {
                ProgressView("Cargando...")
            }

            if let error = viewModel.errorMessage {
                Text("Error: \(error)").foregroundColor(.red)
            }
        }
    }
}*/

/*struct TeamSectionView: View {
    let team: Team2
    let isSelected: Bool
    let players: [Player]
    let onSelect: () -> Void

    var body: some View {
        Section(header: Text("\(team.name) (\(team.teamMembers?.count ?? players.count) jugadores)")) {
            if isSelected {
                ForEach(players, id: \.id) { player in
                    Text(player.username)
                }
            } else {
                Button("Mostrar jugadores") {
                    onSelect()
                }
            }
        }
    }
}*/
