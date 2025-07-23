//
//  ManageGameView.swift
//  CourtClan
//
//  Created by Isain Rodriguez Noreña on 7/7/25.
//

import SwiftUI
import Combine

struct ManageGameView: View {
    
    @EnvironmentObject var appUtils: AppUtils
    private let locationService = LocationService()
    
    @State var homeTeamScore: Int
    @State var awayTeamScore: Int
    @State var homeTeamName: String
    @State var awayTeamName: String
    @State var gameTitle: String
    @State var gameDate: String
    @State var gameTime: String
    @State var gameStatus: String
    @State var gameEvent: String
    
    @State private var player1Image: UIImage?
    @State private var player2Image: UIImage?
    
    let player1ProfilePictureUrl: String?
    let player2ProfilePictureUrl: String?
    
    let courtLatitude: String?
    let courtLongitude: String?
    
    // --- Variables para el cronómetro ---
    @State private var timeRemaining: Int // Tiempo restante en segundos
    @State private var timer: AnyCancellable? = nil // Para gestionar la suscripción del temporizador
    @State private var isRunning: Bool = false // Indica si el cronómetro está corriendo
    
    let initialGameDurationMinutes: Int = 10
    
    // --- NUEVAS PROPIEDADES PARA SELECCIÓN DE PUNTUACIÓN ---
    @State private var selectedScorerID: String? = nil // ID del jugador/equipo que ha marcado
    @State private var showingScoreButtons: Bool = false // Controla la visibilidad de los botones de puntos
    
    // Los IDs de los jugadores/equipos para poder seleccionarlos
    let homeScorerID: String // Puede ser player1Id o homeTeamId
    let awayScorerID: String // Puede ser player2Id o awayTeamId
    
    init(game: Game) {
        print("ManageGameView: INIT called for game ID: \(game.id), Time Remaining: \(10 * 60)")
        _homeTeamScore = State(initialValue: game.homeScore ?? 0)
        _awayTeamScore = State(initialValue: game.awayScore ?? 0)
        
        // Determinar nombres y IDs de los "anotadores" (jugador o equipo)
        // Usar los IDs de los jugadores para 1v1 y los IDs de los equipos para Team vs Team
        if game.gameType == .oneVsOne {
            _homeTeamName = State(initialValue: game.player1?.username ?? "Jugador 1")
            _awayTeamName = State(initialValue: game.player2?.username ?? "Jugador 2")
            homeScorerID = game.player1Id ?? UUID().uuidString // Genera un ID si es nulo
            awayScorerID = game.player2Id ?? UUID().uuidString
        } else { // Asumimos teamVsTeam
            _homeTeamName = State(initialValue: game.homeTeam?.name ?? "Equipo Local")
            _awayTeamName = State(initialValue: game.awayTeam?.name ?? "Equipo Visitante")
            homeScorerID = game.homeTeamId ?? UUID().uuidString
            awayScorerID = game.awayTeamId ?? UUID().uuidString
        }
        
        _gameTitle = State(initialValue: game.court?.name ?? "Cancha")
        _gameDate = State(initialValue: game.displayDate)
        _gameTime = State(initialValue: game.displayStartTime)
        _gameStatus = State(initialValue: game.gameStatus.rawValue)
        _gameEvent = State(initialValue: game.event?.name ?? "Evento")
        
        player1ProfilePictureUrl = game.player1?.profilePictureUrl
        player2ProfilePictureUrl = game.player2?.profilePictureUrl
        
        courtLatitude = game.court?.latitude
        courtLongitude = game.court?.longitude
        
        _timeRemaining = State(initialValue: initialGameDurationMinutes * 60)
    }
    
    var body: some View {
        VStack(spacing: 0) {
            // Sección de encabezado (información del juego y marcador global)
            VStack(spacing: 10) {
                Text(gameTitle)
                    .font(.title2)
                    .fontWeight(.bold)
                Text("\(gameDate) - \(gameTime) (\(gameStatus))")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                
                // ************ CAMBIO CLAVE AQUÍ ************
                // Agrupamos el score y el nombre en VStacks individuales
                HStack {
                    Spacer() // Empuja el contenido al centro desde la izquierda
                    
                    // Columna del Equipo Local / Jugador 1
                    VStack(spacing: 5) { // Espacio entre el score y el nombre
                        Text("\(homeTeamScore)")
                            .font(.largeTitle)
                            .fontWeight(.heavy)
                            .monospacedDigit()
                            .padding(.horizontal, 10)
                            .background(Color.white.opacity(0.8))
                            .cornerRadius(10)
                        
                        Text(homeTeamName)
                            .font(.headline)
                            .fontWeight(.semibold)
                            .lineLimit(1)
                            .minimumScaleFactor(0.7)
                        // Alineamos el texto dentro de su propio VStack
                            .multilineTextAlignment(.center)
                        // Removemos los padding(.trailing/.leading) aquí para que el Spacer haga su trabajo
                        Divider()
                            .frame(width: 100, height: 2)
                            .background(Color.gray)
                        HStack(){
                            VStack(alignment: .center){
                                Text("Falta")
                                    .tint(Color.red)
                                Text("0")
                            }
                            
                            Divider()
                                .frame(width: 2,height: 20)
                            VStack(alignment: .center){
                                Text("Tiro Perdido")
                                    .tint(Color.green)
                                Text("0")
                            }
                            
                        }
                    }
                    .frame(maxWidth: .infinity) // Permitimos que el VStack tome el ancho necesario
                    // y lo centramos dentro de su propio espacio
                    
                    Divider()
                        .frame(width: 5, height: 100)
                        .background(Color.gray)
                    
                    // Columna del Equipo Visitante / Jugador 2
                    VStack(spacing: 5) { // Espacio entre el score y el nombre
                        Text("\(awayTeamScore)")
                            .font(.largeTitle)
                            .fontWeight(.heavy)
                            .monospacedDigit()
                            .padding(.horizontal, 10)
                            .background(Color.white.opacity(0.8))
                            .cornerRadius(10)
                        
                        Text(awayTeamName)
                            .font(.headline)
                            .fontWeight(.semibold)
                            .lineLimit(1)
                            .minimumScaleFactor(0.7)
                        // Alineamos el texto dentro de su propio VStack
                            .multilineTextAlignment(.center)
                        // Removemos los padding(.trailing/.leading) aquí para que el Spacer haga su trabajo
                        Divider()
                            .frame(width: 100, height: 2)
                            .background(Color.gray)
                        HStack(){
                            VStack(alignment: .center){
                                Text("Falta")
                                    .tint(Color.red)
                                Text("0")
                            }
                            
                            Divider()
                                .frame(width: 2,height: 20)
                            VStack(alignment: .center){
                                Text("Tiro Perdido")
                                    .tint(Color.green)
                                Text("0")
                            }
                            
                        }
                    }
                    .frame(maxWidth: .infinity) // Permitimos que el VStack tome el ancho necesario
                    // y lo centramos dentro de su propio espacio
                    
                    Spacer() // Empuja el contenido al centro desde la derecha
                }
                .padding(.horizontal) // Padding exterior para todo el HStack
            }
            .padding(.top, 20)
            .padding(.bottom, 10)
            .background(Color.gray.opacity(0.05))
            
            Divider()
            
            // Contenido principal de la gestión del juego (fotos, botones de puntos, cronómetro)
            ScrollView { // Envuelve el contenido principal en un ScrollView
                VStack(spacing: 20) {
                    
                    // --- SECCIÓN DE JUGADORES/EQUIPOS Y SELECCIÓN ---
                    HStack(alignment: .top, spacing: 20) {
                        // Equipo Local / Jugador 1
                        VStack {
                            PlayerButtonView(
                                image: player1Image,
                                name: homeTeamName,
                                isSelected: selectedScorerID == homeScorerID,
                                onTap: {
                                    selectedScorerID = homeScorerID
                                    showingScoreButtons = true
                                }
                            )
                        }
                        .frame(maxWidth: .infinity)
                        
                        // Separador visual o espacio
                        Spacer()
                            .frame(width: 1) // O un Divider() si lo prefieres
                        
                        // Equipo Visitante / Jugador 2
                        VStack {
                            PlayerButtonView(
                                image: player2Image,
                                name: awayTeamName,
                                isSelected: selectedScorerID == awayScorerID,
                                onTap: {
                                    selectedScorerID = awayScorerID
                                    showingScoreButtons = true
                                }
                            )
                        }
                        .frame(maxWidth: .infinity)
                    }
                    .padding(.horizontal)
                    .padding(.top, 20)
                    
                    // --- BOTONES DE SUMAR PUNTOS (condicionales) ---
                    if showingScoreButtons {
                        HStack(spacing: 15) {
                            ScoreButton(title: "+1", points: 1, action: addPoints, buttonColor: .blue)
                            ScoreButton(title: "+2", points: 2, action: addPoints, buttonColor: .blue)
                            ScoreButton(title: "+3", points: 3, action: addPoints, buttonColor: .blue)
                        }
                        .padding(.horizontal)
                        .padding(.bottom, 5)
                        
                        HStack(spacing: 15) {
                            ScoreButton(title: "+1", points: 1, action: addPoints, buttonColor: .red)
                        }
                        .padding(.horizontal)
                        .padding(.bottom, 5)
                        .tint(.red)
                        
                        HStack(spacing: 15) {
                            ScoreButton(title: "+1", points: 1, action: addPoints, buttonColor: .green)
                        }
                        .padding(.horizontal)
                        .padding(.bottom, 5)
                        .tint(.green)
                    }
                    
                    // Marcador del tiempo
                    Text(timeString(from: timeRemaining))
                        .font(.system(size: 80, weight: .bold, design: .monospaced))
                        .foregroundColor(.primary)
                        .padding()
                        .background(Color.black.opacity(0.1))
                        .cornerRadius(20)
                        .monospacedDigit()
                        .padding(.vertical, 20)
                    
                    // Controles del cronómetro
                    HStack(spacing: 30) {
                        Button {
                            if isRunning { pauseTimer() } else { startTimer() }
                        } label: {
                            Label(isRunning ? "Pausar" : "Iniciar", systemImage: isRunning ? "pause.fill" : "play.fill")
                                .font(.title2)
                                .padding(.vertical, 15)
                                .padding(.horizontal, 30)
                                .background(isRunning ? Color.orange : Color.green)
                                .foregroundColor(.white)
                                .cornerRadius(15)
                        }
                        
                        Button {
                            resetTimer()
                        } label: {
                            Label("Reiniciar", systemImage: "arrow.counterclockwise")
                                .font(.title2)
                                .padding(.vertical, 15)
                                .padding(.horizontal, 30)
                                .background(Color.red)
                                .foregroundColor(.white)
                                .cornerRadius(15)
                        }
                    }
                    .padding(.bottom, 30)
                    
                } // Fin del VStack principal del ScrollView
            } // Fin del ScrollView
            
        } // Fin del VStack principal
        .onAppear {
            print("ManageGameView: onAppear called for game ID: \(homeScorerID) - Current timeRemaining: \(timeRemaining)")
            loadPlayerImages()
            // Iniciar la carga de la ubicación
            /*locationService.fetchLocationName(latitude: courtLatitude, longitude: courtLongitude) { name in
             seriesResult = name
             }*/
            // Asegura que el estado del cronómetro se inicialice correctamente al aparecer
            resetViewStateForCurrentGame()
        }
        .onChange(of: homeTeamScore) {oldVal, newVal in
            print("ManageGameView: homeTeamScore changed from \(oldVal) to \(newVal)")
            // Puedes añadir lógica aquí si necesitas hacer algo cuando el score cambia
        }
        .onChange(of: awayTeamScore) { oldVal, newVal in
            print("ManageGameView: awayTeamScore changed from \(oldVal) to \(newVal)")
            // Puedes añadir lógica aquí si necesitas hacer algo cuando el score cambia
        }
        .onDisappear {
            print("ManageGameView: onDisappear called. Timer cancelled.")
            timer?.cancel()
        }
        .background(Color.white.edgesIgnoringSafeArea(.all)) // Fondo de toda la vista
    }
    
    // --- Funciones del cronómetro ---
    private func startTimer() {
        guard !isRunning && timeRemaining > 0 else { return }
        isRunning = true
        timer = Timer.publish(every: 1, on: .main, in: .common)
            .autoconnect()
            .sink { _ in
                if timeRemaining > 0 {
                    timeRemaining -= 1
                } else {
                    pauseTimer()
                    // Aquí podrías añadir una acción cuando el tiempo se agota
                }
            }
    }
    
    private func pauseTimer() {
        isRunning = false
        timer?.cancel()
        timer = nil
    }
    
    private func resetTimer() {
        pauseTimer()
        timeRemaining = initialGameDurationMinutes * 60
        homeTeamScore = 0
        awayTeamScore = 0
        // Deseleccionar al jugador/equipo al reiniciar el juego
        selectedScorerID = nil
        showingScoreButtons = false
    }
    
    // Función para formatear el tiempo a MM:SS
    private func timeString(from totalSeconds: Int) -> String {
        let minutes = totalSeconds / 60
        let seconds = totalSeconds % 60
        return String(format: "%02d:%02d", minutes, seconds)
    }
    
    // Función para sumar puntos
    private func addPoints(_ points: Int) {
        guard let scorerID = selectedScorerID else { return }
        
        if scorerID == homeScorerID {
            homeTeamScore += points
        } else if scorerID == awayScorerID {
            awayTeamScore += points
        }
        
        // Ocultar los botones después de sumar puntos
        selectedScorerID = nil
        showingScoreButtons = false
    }
    
    // Función para cargar las imágenes de los jugadores
    private func loadPlayerImages() {
        Task {
            if let urlString = player1ProfilePictureUrl, !urlString.isEmpty {
                player1Image = await AppUtils.fetchUIImage(from: urlString)
            }
            if let urlString = player2ProfilePictureUrl, !urlString.isEmpty {
                player2Image = await AppUtils.fetchUIImage(from: urlString)
            }
        }
    }
    
    // Función para reiniciar el estado de la vista para el juego actual
    private func resetViewStateForCurrentGame() {
        pauseTimer()
        timeRemaining = initialGameDurationMinutes * 60
        // No reseteamos los scores aquí si queremos que reflejen el estado actual del juego
        // Opcionalmente, podrías pasarlos de 'game.homeScore' y 'game.awayScore' si los guardas
        
        selectedScorerID = nil
        showingScoreButtons = false
    }
}

// MARK: - Vistas Auxiliares para un diseño más limpio

// Vista para el botón del jugador/equipo (foto + nombre + onTap)
struct PlayerButtonView: View {
    let image: UIImage?
    let name: String
    let isSelected: Bool
    let onTap: () -> Void
    
    var body: some View {
        Button(action: onTap) {
            VStack {
                if let uiImage = image {
                    Image(uiImage: uiImage)
                        .resizable()
                        .scaledToFill()
                        .frame(width: 90, height: 90) // Ajustado para un tamaño redondo
                        .clipShape(Circle())
                        .overlay(
                            Circle()
                                .stroke(isSelected ? Color.blue : Color.gray.opacity(0.4), lineWidth: isSelected ? 4 : 2)
                        )
                        .shadow(radius: isSelected ? 8 : 3)
                } else {
                    Circle()
                        .fill(Color.gray.opacity(0.2))
                        .frame(width: 90, height: 90)
                        .overlay(ProgressView())
                        .overlay(
                            Circle()
                                .stroke(isSelected ? Color.blue : Color.gray.opacity(0.4), lineWidth: isSelected ? 4 : 2)
                        )
                }
                
                Text(name)
                    .font(.caption)
                    .fontWeight(.bold)
                    .foregroundColor(.primary)
                    .lineLimit(1)
                    .minimumScaleFactor(0.7)
            }
            .padding(10)
            .background(isSelected ? Color.blue.opacity(0.1) : Color.clear)
            .cornerRadius(15)
            .scaleEffect(isSelected ? 1.05 : 1.0)
            .animation(.spring(response: 0.3, dampingFraction: 0.5), value: isSelected)
        }
        .buttonStyle(PlainButtonStyle()) // Para quitar el estilo predeterminado del botón
    }
}

// Vista para los botones de puntuación (+1, +2, +3)
struct ScoreButton: View {
    let title: String
    let points: Int
    let action: (Int) -> Void
    var buttonColor:UIColor
    
    var body: some View {
        Button(action: { action(points) }) {
            Text(title)
                .font(.title2)
                .fontWeight(.bold)
                .frame(minWidth: 70, minHeight: 45) // Tamaño fijo para todos los botones
                .background(Color(buttonColor)) // Color de acento para uniformidad
                .foregroundColor(.white)
                .cornerRadius(12)
        }
        
    }
}

/*#Preview {
    let tomorrow = Date().addingTimeInterval(3600 * 24) // Mañana
    let startTimeTomorrow = tomorrow.addingTimeInterval(3600 * 10) // 10 AM mañana
    let endTimeTomorrow = startTimeTomorrow.addingTimeInterval(3600)
    let game:Game = Game(
        id: UUID().uuidString,
        date: tomorrow,
        startTime: startTimeTomorrow,
        endTime: endTimeTomorrow,
        courtId: "",
        eventId: nil, // Opcional, podría no tener evento
        gameType: .oneVsOne,
        player1Id: "",
        player2Id: UUID().uuidString, // Otro jugador de ejemplo
        homeTeamId: nil,
        awayTeamId: nil,
        homeScore: nil,
        awayScore: nil,
        winnerId: nil,
        gameStatus: .scheduled,
        createdAt: Date(),
        updatedAt: Date(),
        court: Court(),
        player1: Player.samplePlayers[1],
        player2: Player.samplePlayers[2],
        homeTeam: nil,
        awayTeam: nil,
        event: nil
    )
    ManageGameView(game: game)
}*/
