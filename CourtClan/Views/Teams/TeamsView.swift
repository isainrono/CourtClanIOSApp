//
//  TeamsView.swift
//  CourtClan
//
//  Created by Isain Rodriguez Noreña on 21/5/25.
//

import SwiftUI

struct TeamsView: View {
    // Instancia del ViewModel que observaremos
    @StateObject var viewModel = TeamsViewModel()
    @FocusState private var isSearchBarFocused: Bool

    var body: some View {
        NavigationStack {
            Group {
                if viewModel.isLoading {
                    ProgressView("Cargando equipos...")
                } else if let errorMessage = viewModel.errorMessage {
                    VStack {
                        Text(errorMessage)
                            .foregroundColor(.red)
                            .multilineTextAlignment(.center)
                            .padding()
                        Button("Reintentar") {
                            Task { await viewModel.fetchAllTeams() }
                        }
                    }
                } else if viewModel.filteredTeams.isEmpty && !viewModel.searchText.isEmpty {
                    ContentUnavailableView("No se encontraron equipos", systemImage: "magnifyingglass")
                        .padding()
                } else if viewModel.filteredTeams.isEmpty {
                    ContentUnavailableView("No hay equipos disponibles", systemImage: "person.3.fill")
                        .padding()
                } else {
                    List {
                        ForEach(viewModel.filteredTeams) { team in
                            TeamRowView(team: team)
                                .swipeActions(edge: .trailing) {
                                    Button(role: .destructive) {
                                        // Podrías añadir un alert de confirmación aquí antes de eliminar
                                        Task { await viewModel.deleteTeam(teamId: team.id) }
                                    } label: {
                                        Label("Eliminar", systemImage: "trash.fill")
                                    }
                                    .tint(.red)

                                    Button {
                                        viewModel.presentEditSheet(team: team)
                                    } label: {
                                        Label("Editar", systemImage: "pencil")
                                    }
                                    .tint(.blue)
                                }
                        }
                    }
                    .refreshable { // Pull-to-refresh
                        await viewModel.fetchAllTeams()
                    }
                }
            }
            .navigationTitle("Equipos")
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button {
                        // Acción para perfil/menú (ej. abrir una sidebar)
                        print("Abrir perfil/menú")
                    } label: {
                        Image(systemName: "person.circle.fill")
                            .imageScale(.large)
                    }
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        viewModel.presentAddSheet() // Abre la hoja para añadir
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
                                viewModel.searchText = "" // Limpia búsqueda al desactivar
                            }
                        }
                     } label: {
                         Image(systemName: isSearchBarFocused ? "xmark.circle.fill" : "magnifyingglass")
                             .imageScale(.large)
                             .padding(.vertical, 8)
                     }
                 }
            }
            .toolbar { // Barra de búsqueda como ToolbarItem
                ToolbarItem(placement: .principal) {
                    if isSearchBarFocused {
                        TextField("Buscar equipo...", text: $viewModel.searchText)
                            .textFieldStyle(.roundedBorder)
                            .autocorrectionDisabled()
                            .textInputAutocapitalization(.never)
                            .focused($isSearchBarFocused)
                            .transition(.opacity)
                            .frame(maxWidth: .infinity)
                    }
                }
            }
            .task { // Carga inicial de datos cuando la vista aparece
                await viewModel.fetchAllTeams()
            }
            .alert("Error", isPresented: Binding(get: { viewModel.errorMessage != nil }, set: { _ in viewModel.errorMessage = nil })) {
                Button("OK") { }
            } message: {
                Text(viewModel.errorMessage ?? "Ha ocurrido un error desconocido.")
            }
            .sheet(isPresented: $viewModel.showingAddEditSheet) {
                AddEditTeamView(viewModel: viewModel)
            }
        }
    }
}

// MARK: - TeamRowView (Vista de una fila de equipo en la lista)
struct TeamRowView: View {
    let team: Team

    var body: some View {
        NavigationLink{}label: {
            HStack {
                if let logoUrl = team.logoUrl, let url = URL(string: logoUrl) {
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
                    Image(systemName: "person.3.fill")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 50, height: 50)
                        .foregroundColor(.blue)
                        .clipShape(Circle())
                        .background(Color.gray.opacity(0.2))
                        .padding(.trailing, 5)
                }

                VStack(alignment: .leading) {
                    Text(team.name)
                        .font(.headline)
                    if let description = team.description, !description.isEmpty {
                        Text(description)
                            .font(.subheadline)
                            .foregroundColor(.gray)
                            .lineLimit(1)
                    }
                    Text("Fondos: \(team.teamFunds, specifier: "%.2f") €")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                Spacer()
            }
            .padding(.vertical, 4)
        }
    }
}

// MARK: - AddEditTeamView (Hoja modal para añadir/editar equipos)
struct AddEditTeamView: View {
    @ObservedObject var viewModel: TeamsViewModel
    @Environment(\.dismiss) var dismiss

    @State private var name: String = ""
    @State private var description: String = ""
    @State private var logoUrl: String = ""
    @State private var ownerUserId: String = "" // Debe ser un ID de usuario real
    @State private var captainUserId: String = "" // Debe ser un ID de usuario real
    @State private var teamFunds: String = "0.00"
    @State private var isEditing: Bool = false

    var body: some View {
        NavigationView {
            Form {
                Section("Detalles del Equipo") {
                    TextField("Nombre del Equipo*", text: $name)
                    TextField("Descripción", text: $description)
                    TextField("URL del Logo", text: $logoUrl)
                        .keyboardType(.URL)
                        .autocorrectionDisabled()
                        .textInputAutocapitalization(.never)
                    TextField("Fondos del Equipo", text: $teamFunds)
                        .keyboardType(.decimalPad)
                }

                Section("IDs de Usuario (para pruebas, idealmente seleccionados de usuarios existentes)") {
                     TextField("ID del Propietario*", text: $ownerUserId)
                        .autocorrectionDisabled()
                        .textInputAutocapitalization(.never)
                     TextField("ID del Capitán", text: $captainUserId)
                        .autocorrectionDisabled()
                        .textInputAutocapitalization(.never)
                }
            }
            .navigationTitle(isEditing ? "Editar Equipo" : "Nuevo Equipo")
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
                            let funds = Double(teamFunds) ?? 0.0

                            if isEditing, let team = viewModel.selectedTeam {
                                await viewModel.updateTeam(
                                    id: team.id, // Usamos team.id del modelo
                                    name: name.isEmpty ? nil : name,
                                    description: description.isEmpty ? nil : description,
                                    logoUrl: logoUrl.isEmpty ? nil : logoUrl,
                                    ownerUserId: ownerUserId.isEmpty ? nil : ownerUserId,
                                    captainUserId: captainUserId.isEmpty ? nil : captainUserId,
                                    teamFunds: funds
                                )
                            } else {
                                await viewModel.createTeam(
                                    name: name,
                                    description: description.isEmpty ? nil : description,
                                    logoUrl: logoUrl.isEmpty ? nil : logoUrl,
                                    ownerUserId: ownerUserId, // Requiere un valor
                                    captainUserId: captainUserId.isEmpty ? nil : captainUserId,
                                    teamFunds: funds
                                )
                            }
                        }
                    }
                    .disabled(name.isEmpty || ownerUserId.isEmpty) // Deshabilita si campos requeridos vacíos
                }
            }
            .onAppear {
                if let team = viewModel.selectedTeam {
                    isEditing = true
                    name = team.name
                    description = team.description ?? ""
                    logoUrl = team.logoUrl ?? ""
                    ownerUserId = team.ownerUserId
                    captainUserId = team.captainUserId ?? ""
                    teamFunds = String(format: "%.2f", team.teamFunds)
                } else {
                    isEditing = false
                    // Aquí, en una app real, ownerUserId podría ser el ID del usuario logueado.
                    // Para pruebas, puedes generar un UUID o usar un ID fijo si tu backend lo permite.
                    ownerUserId = UUID().uuidString
                }
            }
        }
    }
}

// MARK: - Previews
struct TeamsView_Previews: PreviewProvider {
    static var previews: some View {
        TeamsView()
    }
}
