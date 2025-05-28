//
//  PlayersView.swift
//  CourtClan
//
//  Created by Isain Rodriguez Noreña on 22/5/25.
//

import SwiftUI

struct PlayersView: View {
    @StateObject var viewModel = PlayersViewModel()
    @FocusState private var isSearchBarFocused: Bool

    var body: some View {
        NavigationStack {
            Group {
                if viewModel.isLoading {
                    ProgressView("Cargando jugadores...")
                } else if let errorMessage = viewModel.errorMessage {
                    VStack {
                        Text(errorMessage)
                            .foregroundColor(.red)
                            .multilineTextAlignment(.center)
                            .padding()
                        Button("Reintentar") {
                            Task { await viewModel.fetchAllPlayers() }
                        }
                    }
                } else if viewModel.filteredPlayers.isEmpty && !viewModel.searchText.isEmpty {
                    ContentUnavailableView("No se encontraron jugadores", systemImage: "magnifyingglass")
                        .padding()
                } else if viewModel.filteredPlayers.isEmpty {
                    ContentUnavailableView("No hay jugadores disponibles", systemImage: "person.fill")
                        .padding()
                } else {
                    List {
                        ForEach(viewModel.filteredPlayers) { player in
                            
                            
                            PlayerRowView(player: player)
                                //.listRowBackground(Color.black)
                                .swipeActions(edge: .trailing) {
                                    Button(role: .destructive) {
                                        Task { await viewModel.deletePlayer(playerId: player.id) }
                                    } label: {
                                        Label("Eliminar", systemImage: "trash.fill")
                                    }
                                    .tint(.red)

                                    Button {
                                        viewModel.presentEditSheet(player: player)
                                    } label: {
                                        Label("Editar", systemImage: "pencil")
                                    }
                                    .tint(.blue)
                                }
                        }
                    }
                    .refreshable { // Pull-to-refresh
                        await viewModel.fetchAllPlayers()
                        
                    }
                    
                }
            }
            .navigationTitle("Jugadores\(self.viewModel.players.count)")
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button {
                        // Acción para perfil/menú
                    } label: {
                        Image(systemName: "person.circle.fill")
                            .imageScale(.large)
                    }
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        viewModel.presentAddSheet()
                    } label: {
                        Image(systemName: "plus.circle.fill")
                            .imageScale(.large)
                    }
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        withAnimation {
                            isSearchBarFocused.toggle()
                            if !isSearchBarFocused {
                                viewModel.searchText = ""
                            }
                        }
                    } label: {
                        Image(systemName: isSearchBarFocused ? "xmark.circle.fill" : "magnifyingglass")
                            .imageScale(.large)
                            .padding(.vertical, 8)
                    }
                }
            }
            .toolbar {
                ToolbarItem(placement: .principal) {
                    if isSearchBarFocused {
                        TextField("Buscar jugador...", text: $viewModel.searchText)
                            .textFieldStyle(.roundedBorder)
                            .autocorrectionDisabled()
                            .textInputAutocapitalization(.never)
                            .focused($isSearchBarFocused)
                            .transition(.opacity)
                            .frame(maxWidth: .infinity)
                    }
                }
            }
            .task { // Carga inicial
                await viewModel.fetchAllPlayers()
            }
            .alert("Error", isPresented: Binding(get: { viewModel.errorMessage != nil }, set: { _ in viewModel.errorMessage = nil })) {
                Button("OK") { }
            } message: {
                Text(viewModel.errorMessage ?? "Ha ocurrido un error desconocido.")
            }
            .sheet(isPresented: $viewModel.showingAddEditSheet) {
                AddEditPlayerView(viewModel: viewModel)
            }
            
            
        }
    }
}

// MARK: - PlayerRowView (Vista de una fila de jugador en la lista)
struct PlayerRowView: View {
    let player: Player

    var body: some View {
        NavigationLink{
            PlayerDetailView(player: player)
        }label: {
            HStack {
                if let profileUrl = player.profilePictureUrl, let url = URL(string: profileUrl) {
                    AsyncImage(url: url) { image in
                        image
                            .resizable()
                            .scaledToFill()
                            .frame(width: 50, height: 50)
                            .clipShape(Circle())
                    } placeholder: {
                        ProgressView()
                            .frame(width: 50, height: 50)
                            .clipShape(Circle())
                            .background(Color.gray.opacity(0.2))
                    }
                    .padding(.trailing, 5)
                } else {
                    Image(systemName: "person.fill")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 50, height: 50)
                        .foregroundColor(.green)
                        .clipShape(Circle())
                        .background(Color.gray.opacity(0.2))
                        .padding(.trailing, 5)
                }

                VStack(alignment: .leading) {
                    Text(player.username)
                        .font(.headline)
                    if let fullName = player.fullName, !fullName.isEmpty {
                        Text(fullName)
                            .font(.subheadline)
                            .foregroundColor(.gray)
                            .lineLimit(1)
                    }
                    Text("Nivel: \(player.currentLevel) | XP: \(player.totalXp)")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                Spacer()
                VStack(alignment: .trailing) {
                    if let team = player.team {
                        Text(team.name)
                            .font(.caption)
                            .foregroundColor(.accentColor)
                    } else {
                        Text("Agente Libre")
                            .font(.caption)
                            .foregroundColor(.red)
                    }
                    Text(String(format: "%.0f %% ganados", player.winPercentage))
                        .font(.caption2)
                        .foregroundColor(.secondary)
                }
            }
            .padding(.vertical, 4)
        }
    }
}


// MARK: - AddEditPlayerView (Hoja modal para añadir/editar jugadores)
struct AddEditPlayerView: View {
    @ObservedObject var viewModel: PlayersViewModel
    @Environment(\.dismiss) var dismiss

    // Propiedades de estado para los campos del formulario
    @State private var username: String = ""
    @State private var email: String = ""
    @State private var passwordHash: String = ""
    @State private var fullName: String = ""
    @State private var bio: String = ""
    @State private var profilePictureUrl: String = ""
    @State private var location: String = ""
    @State private var dateOfBirth: Date = Date()
    @State private var gender: String = "Male"
    @State private var preferredPosition: String = ""
    @State private var skillLevelId: String = "" // <-- ¡CAMBIO AQUI! Ya no es Int, es String.
    @State private var currentLevel: String = ""
    @State private var totalXp: String = ""
    @State private var gamesPlayed: String = ""
    @State private var gamesWon: String = ""
    @State private var winPercentage: String = ""
    @State private var avgPointsPerGame: String = ""
    @State private var avgAssistsPerGame: String = ""
    @State private var avgReboundsPerGame: String = ""
    @State private var avgBlocksPerGame: String = ""
    @State private var avgStealsPerGame: String = ""
    @State private var isPublic: Bool = true
    @State private var isActive: Bool = true
    @State private var currentTeamId: String = ""
    @State private var marketValue: String = ""
    @State private var isFreeAgent: Bool = true

    @State private var isEditing: Bool = false

    let genders = ["Male", "Female", "Non-binary", "Prefer not to say"]
    let positions = ["Point Guard", "Shooting Guard", "Small Forward", "Power Forward", "Center", "Guard", "Forward"]

    var body: some View {
        NavigationView {
            Form {
                Section("Información Básica") {
                    TextField("Username*", text: $username)
                        .autocorrectionDisabled()
                        .textInputAutocapitalization(.never)
                    TextField("Email*", text: $email)
                        .keyboardType(.emailAddress)
                        .autocorrectionDisabled()
                        .textInputAutocapitalization(.never)
                    if !isEditing {
                        SecureField("Contraseña*", text: $passwordHash)
                    }
                    TextField("Nombre Completo", text: $fullName)
                    TextField("Bio", text: $bio)
                    TextField("URL Foto de Perfil", text: $profilePictureUrl)
                        .keyboardType(.URL)
                        .autocorrectionDisabled()
                        .textInputAutocapitalization(.never)
                    TextField("Ubicación", text: $location)
                    DatePicker("Fecha de Nacimiento", selection: $dateOfBirth, displayedComponents: .date)
                    Picker("Género", selection: $gender) {
                        ForEach(genders, id: \.self) {
                            Text($0)
                        }
                    }
                    Picker("Posición Preferida", selection: $preferredPosition) {
                        Text("Ninguna").tag("")
                        ForEach(positions, id: \.self) {
                            Text($0)
                        }
                    }
                    TextField("ID Nivel de Habilidad (UUID)", text: $skillLevelId) // <-- ¡CAMBIO AQUI!
                        .autocorrectionDisabled()
                        .textInputAutocapitalization(.never)
                }

                // ... (el resto del código de la vista AddEditPlayerView sigue igual)

                Section("Estadísticas del Jugador") {
                    TextField("Nivel Actual", text: $currentLevel)
                        .keyboardType(.numberPad)
                    TextField("XP Total", text: $totalXp)
                        .keyboardType(.numberPad)
                    TextField("Partidos Jugados", text: $gamesPlayed)
                        .keyboardType(.numberPad)
                    TextField("Partidos Ganados", text: $gamesWon)
                        .keyboardType(.numberPad)
                    TextField("Porcentaje de Victorias", text: $winPercentage)
                        .keyboardType(.decimalPad)
                    TextField("Puntos por Partido", text: $avgPointsPerGame)
                        .keyboardType(.decimalPad)
                    TextField("Asistencias por Partido", text: $avgAssistsPerGame)
                        .keyboardType(.decimalPad)
                    TextField("Rebotes por Partido", text: $avgReboundsPerGame)
                        .keyboardType(.decimalPad)
                    TextField("Bloqueos por Partido", text: $avgBlocksPerGame)
                        .keyboardType(.decimalPad)
                    TextField("Robos por Partido", text: $avgStealsPerGame)
                        .keyboardType(.decimalPad)
                }

                Section("Estado y Valor") {
                    Toggle("Perfil Público", isOn: $isPublic)
                    Toggle("Jugador Activo", isOn: $isActive)
                    TextField("ID Equipo Actual (opcional)", text: $currentTeamId)
                        .autocorrectionDisabled()
                        .textInputAutocapitalization(.never)
                    TextField("Valor de Mercado", text: $marketValue)
                        .keyboardType(.decimalPad)
                    Toggle("Agente Libre", isOn: $isFreeAgent)
                }
            }
            .navigationTitle(isEditing ? "Editar Jugador" : "Nuevo Jugador")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancelar") {
                        dismiss()
                    }
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(isEditing ? "Actualizar" : "Guardar") {
                        Task {
                            // skillLevelId ya es String, no necesita conversión Int()
                            let currentLvl = Int(currentLevel)
                            let totalXP = Int(totalXp)
                            let gamesPl = Int(gamesPlayed)
                            let gamesWn = Int(gamesWon)
                            let winPerc = Double(winPercentage)
                            let avgPPG = Double(avgPointsPerGame)
                            let avgAPG = Double(avgAssistsPerGame)
                            let avgRPG = Double(avgReboundsPerGame)
                            let avgBPG = Double(avgBlocksPerGame)
                            let avgSPG = Double(avgStealsPerGame)
                            let marketVal = Double(marketValue)

                            if isEditing, let player = viewModel.selectedPlayer {
                                await viewModel.updatePlayer(
                                    id: player.id,
                                    username: username.isEmpty ? nil : username,
                                    email: email.isEmpty ? nil : email,
                                    passwordHash: passwordHash.isEmpty ? nil : passwordHash,
                                    fullName: fullName.isEmpty ? nil : fullName,
                                    bio: bio.isEmpty ? nil : bio,
                                    profilePictureUrl: profilePictureUrl.isEmpty ? nil : profilePictureUrl,
                                    location: location.isEmpty ? nil : location,
                                    dateOfBirth: dateOfBirth,
                                    gender: gender,
                                    preferredPosition: preferredPosition.isEmpty ? nil : preferredPosition,
                                    skillLevelId: skillLevelId.isEmpty ? nil : skillLevelId, // <-- ¡CAMBIO AQUI!
                                    currentLevel: currentLvl,
                                    totalXp: totalXP,
                                    gamesPlayed: gamesPl,
                                    gamesWon: gamesWn,
                                    winPercentage: winPerc,
                                    avgPointsPerGame: avgPPG,
                                    avgAssistsPerGame: avgAPG,
                                    avgReboundsPerGame: avgRPG,
                                    avgBlocksPerGame: avgBPG,
                                    avgStealsPerGame: avgSPG,
                                    isPublic: isPublic,
                                    isActive: isActive,
                                    currentTeamId: currentTeamId.isEmpty ? nil : currentTeamId,
                                    marketValue: marketVal,
                                    isFreeAgent: isFreeAgent
                                )
                            } else {
                                await viewModel.createPlayer(
                                    username: username,
                                    email: email,
                                    passwordHash: passwordHash,
                                    fullName: fullName.isEmpty ? nil : fullName,
                                    bio: bio.isEmpty ? nil : bio,
                                    profilePictureUrl: profilePictureUrl.isEmpty ? nil : profilePictureUrl,
                                    location: location.isEmpty ? nil : location,
                                    dateOfBirth: dateOfBirth,
                                    gender: gender,
                                    preferredPosition: preferredPosition.isEmpty ? nil : preferredPosition,
                                    skillLevelId: skillLevelId.isEmpty ? nil : skillLevelId, // <-- ¡CAMBIO AQUI!
                                    currentLevel: currentLvl,
                                    totalXp: totalXP,
                                    gamesPlayed: gamesPl,
                                    gamesWon: gamesWn,
                                    winPercentage: winPerc,
                                    avgPointsPerGame: avgPPG,
                                    avgAssistsPerGame: avgAPG,
                                    avgReboundsPerGame: avgRPG,
                                    avgBlocksPerGame: avgBPG,
                                    avgStealsPerGame: avgSPG,
                                    isPublic: isPublic,
                                    isActive: isActive,
                                    currentTeamId: currentTeamId.isEmpty ? nil : currentTeamId,
                                    marketValue: marketVal,
                                    isFreeAgent: isFreeAgent
                                )
                            }
                        }
                    }
                    .disabled(username.isEmpty || email.isEmpty || (!isEditing && passwordHash.isEmpty))
                }
            }
            .onAppear {
                if let player = viewModel.selectedPlayer {
                    isEditing = true
                    username = player.username
                    email = player.email
                    fullName = player.fullName ?? ""
                    bio = player.bio ?? ""
                    profilePictureUrl = player.profilePictureUrl ?? ""
                    location = player.location ?? ""
                    dateOfBirth = player.dateOfBirth ?? Date()
                    gender = player.gender ?? "Male"
                    preferredPosition = player.preferredPosition ?? ""
                    skillLevelId = player.skillLevelId ?? "" // <-- ¡CAMBIO AQUI!
                    currentLevel = String(player.currentLevel)
                    totalXp = String(player.totalXp)
                    gamesPlayed = String(player.gamesPlayed)
                    gamesWon = String(player.gamesWon)
                    winPercentage = String(format: "%.2f", player.winPercentage)
                    avgPointsPerGame = String(format: "%.2f", player.avgPointsPerGame)
                    avgAssistsPerGame = String(format: "%.2f", player.avgAssistsPerGame)
                    avgReboundsPerGame = String(format: "%.2f", player.avgReboundsPerGame)
                    avgBlocksPerGame = String(format: "%.2f", player.avgBlocksPerGame)
                    avgStealsPerGame = String(format: "%.2f", player.avgStealsPerGame)
                    isPublic = player.isPublic
                    isActive = player.isActive
                    currentTeamId = player.currentTeamId ?? ""
                    marketValue = String(format: "%.2f", player.marketValue)
                    isFreeAgent = player.isFreeAgent
                } else {
                    isEditing = false
                    // Puedes pre-establecer valores por defecto para un nuevo jugador aquí
                }
            }
        }
    }
}

// ... (resto del archivo igual)

// MARK: - Previews
struct PlayersView_Previews: PreviewProvider {
    static var previews: some View {
        PlayersView()
    }
}
