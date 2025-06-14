//
//  PlayerManagerView.swift
//  CourtClan
//
//  Created by Isain Rodriguez Noreña on 5/6/25.
//

import SwiftUI


struct PlayerManagerView: View {
    @EnvironmentObject var playersViewModel: PlayersViewModel
    // Necesitas el AppData también si el PlayersViewModel lo requiere en su inicializador
    @EnvironmentObject var appData: AppData
    
    @State private var fetchedPlayer: Player? // Para almacenar el jugador cargado
    @State private var localErrorMessage: String? // Para errores específicos de esta vista
    @State private var isLoadingPlayer: Bool = true // Estado de carga para esta vista específica
    @Environment(\.dismiss) var dismiss // Declara la variable dismiss
    
    
    var body: some View {
        NavigationView { // Para la barra de navegación y el título
            ScrollView(.vertical, showsIndicators: false) {
                VStack(alignment: .leading, spacing: 20) {
                    
                    if let player = appData.playersViewModel!.currentPlayer {
                        
                        HeaderProfile(player: player)
                        TootleHomeView(player: player)
                        StatisticsView(win: player.gamesWon, loss: player.gamesPlayed-player.gamesWon, draw: 0)
                        MyEventsView()
                        MyTeamsView(team: player.team ?? Team())
                        MyCourtsView()
                        MyMerchans()
                        
                        //ProfileView(imageName: "hanny", circleSize: 100, imageSize: 90, shouldAnimateBorder: true)
                    } else {
                        // Si no hay jugador cargado (lo cual no debería pasar si llegamos aquí después de ChargeView exitosa)
                        VStack {
                            Image(systemName: "person.fill.questionmark")
                                .resizable()
                                .frame(width: 80, height: 80)
                                .foregroundColor(.red)
                                .padding(.bottom)
                            Text("No se pudo cargar el perfil del jugador.")
                                .font(.headline)
                            Text("Por favor, inténtalo de nuevo o revisa tu conexión.")
                                .font(.subheadline)
                                .foregroundColor(.gray)
                            Button("Volver a Home") {
                                dismiss()
                            }
                            
                            .padding()
                            .buttonStyle(.borderedProminent)
                            .padding(.top)
                            Button("Reintentar") {
                                Task {
                                    await loadPlayerFromUserDefaults()
                                }
                            }
                            .padding()
                            .buttonStyle(.borderedProminent)
                        }
                        .padding()
                        ProfileView(imageName: "hanny", circleSize: 100, imageSize: 90, shouldAnimateBorder: true) // Muestra un placeholder
                    }
                    
                    
                    
                }
            }
            // Oculta la barra de navegación por defecto de SwiftUI para crear la personalizada
            .navigationBarHidden(false)
            .navigationBarTitleDisplayMode(.inline) // Solo si no ocultas la barra
            .edgesIgnoringSafeArea(.top) // Extiende el contenido hasta la parte superior de la pantalla
            .navigationBarBackButtonHidden(false)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button {
                        dismiss() // Esto sí descartará la vista desde la pila de navegación de HomeView
                    } label: {
                        Circle() // La forma del círculo
                            .fill(Color.white.opacity(0.5)) // Color de relleno del círculo (puedes ajustar el color y la opacidad)
                            .frame(width: 40, height: 40) // Establece el tamaño del círculo (zona de toque recomendada por Apple)
                            .overlay( // Coloca la imagen encima del círculo
                                Image(systemName: "chevron.left")
                                    .font(.system(size: 15)) // Tamaño de la flecha, ajústalo para que encaje bien en el círculo
                                    .tint(.primary) // Color de la flecha
                            )
                            .symbolEffect(.wiggle)
                        
                    }
                }
                
            }
            .toolbarBackgroundVisibility(.hidden)
            .onAppear {
                // Se ejecuta cuando la vista aparece
                /*Task {
                 await loadPlayerFromUserDefaults()
                 }*/
            }
            
            
        }
        
    }
    
    // MARK: - Función para cargar el jugador
    @MainActor
    private func loadPlayerFromUserDefaults() async {
        isLoadingPlayer = true
        localErrorMessage = nil
        playersViewModel.errorMessage = nil // Limpiar cualquier error del ViewModel
        
        if let playerID = UserDefaults.standard.string(forKey: "playerid") {
            print("💾 ID de jugador recuperado de UserDefaults: \(playerID)")
            fetchedPlayer = await playersViewModel.fetchPlayerByID(id: playerID)
            if fetchedPlayer == nil {
                localErrorMessage = "No se encontraron datos para el ID: \(playerID)"
            }
        } else {
            localErrorMessage = "No hay ID de jugador guardado en UserDefaults."
            print("⚠️ No hay ID de jugador guardado en UserDefaults.")
        }
        isLoadingPlayer = false
    }
}



// MARK: - Previews (para que puedas ver tu vista en el lienzo de Xcode)

#Preview {
    // Es crucial proporcionar los EnvironmentObjects que tu vista espera.
    // Para previsualización, puedes usar instancias dummy o mock.
    // Asegúrate de que Player y AppData sean públicos o accesibles.
    PlayerManagerView()
        .environmentObject(PlayersViewModel(
            playerService: MockPlayerService(), // Usa un mock para previsualización
            
        ))
        .environmentObject(AppData()) // También inyecta AppData si es un @EnvironmentObject en otros lugares
}

// Ejemplo de un MockPlayerService para previsualización o testing
class MockPlayerService: PlayerServiceProtocol {
    func fetchAllPlayers() async throws -> [Player] {
        return [] // No necesitamos implementarlo para esta vista
    }
    
    func fetchPlayer(id: String) async throws -> Player {
        // Devuelve un jugador de ejemplo para la previsualización
        if id == "samplePlayerID" {
            return Player(
                id: "samplePlayerID",
                username: "juan.perez",
                email: "juan@example.com",
                fullName: "Juan Pérez",
                bio: "Jugador apasionado del baloncesto y desarrollador iOS. Siempre buscando mejorar.",
                profilePictureUrl: "https://via.placeholder.com/150", // URL de imagen de ejemplo
                location: "Barcelona, España",
                dateOfBirth: Date().addingTimeInterval(-30 * 365 * 24 * 60 * 60), // Hace 30 años
                gender: "Masculino",
                preferredPosition: "Base",
                skillLevelId: "principiante",
                currentLevel: 10,
                totalXp: 1500,
                gamesPlayed: 50,
                gamesWon: 30,
                winPercentage: 60.0,
                avgPointsPerGame: 15.5,
                avgAssistsPerGame: 7.2,
                avgReboundsPerGame: 4.8,
                avgBlocksPerGame: 1.1,
                avgStealsPerGame: 2.3,
                isPublic: true,
                isActive: true,
                currentTeamId: nil,
                marketValue: 1000.0,
                isFreeAgent: true,
                lastLogin: Date(),
                createdAt: Date(),
                updatedAt: Date(),
                team: Team(
                    id: UUID().uuidString,
                    name: "Boston Celtics",
                    description: "Historic NBA franchise.",
                    logoUrl: nil,
                    ownerUserId: UUID().uuidString,
                    captainUserId: UUID().uuidString,
                    teamFunds: 8000000.0,
                    createdAt: Date(),
                    updatedAt: Date()
                )
            )
        } else {
            throw APIError.requestFailed(404) // Simula un error "no encontrado"
        }
    }
    
    func createPlayer(player: PlayerCreateRequest) async throws -> Player { fatalError() }
    func updatePlayer(id: String, player: PlayerUpdateRequest) async throws -> Player { fatalError() }
    func deletePlayer(id: String) async throws { fatalError() }
}

