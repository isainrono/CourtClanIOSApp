//
//  CCGameView.swift
//  CourtClan
//
//  Created by Isain Rodriguez Noreña on 25/6/25.
//

import SwiftUI
import CoreLocation

struct CCGameView: View {

    @EnvironmentObject var appUtils: AppUtils
    private let locationService = LocationService()
    
    @State var homeTeamScore: Int
    @State var awayTeamScore: Int
    @State var homeTeamName: String
    @State var homeTeamSeed: Int
    @State var awayTeamName: String
    @State var awayTeamSeed: Int = 1
    @State var seriesResult: String = "Cargando ubicación..."
    @State var gameTitle: String
    @State var gameDate: String
    @State var gameTime: String
    @State var gameStatus: String
    @State var gameEvent: String

    // --- CAMBIO CLAVE: DOS ESTADOS PARA LAS IMÁGENES ---
    @State private var player1Image: UIImage?
    @State private var player2Image: UIImage?

    // Las URLs iniciales de los jugadores
    let player1ProfilePictureUrl: String?
    let player2ProfilePictureUrl: String?
    
    let courtLatitude: String?
    let courtLongitude: String?

    init(game: Game) {
        self.homeTeamScore = game.homeScore ?? 0
        self.awayTeamScore = game.awayScore ?? 0
        // Es más lógico que homeTeamName y awayTeamName sean los nombres de los equipos,
        // no los nombres de los jugadores si es un partido entre equipos.
        // Si es 1vs1, entonces sí, puedes usar los nombres de los jugadores.
        self.homeTeamName = game.homeTeam?.name ?? game.player1?.username ?? ""
        self.homeTeamSeed = 2
        self.awayTeamName = game.awayTeam?.name ?? game.player2?.username ?? ""
        self.awayTeamSeed = 4
        
        
        self.seriesResult = "seriesResult"
        self.gameTitle = game.court?.name ?? "Cancha"
        self.gameDate = game.displayDate ?? "Fecha Partido"
        self.gameTime = game.displayStartTime ?? "Hora Partido"
        self.gameStatus = game.gameStatus.rawValue
        self.gameEvent = game.event?.name ?? "Evento"
        self.player1ProfilePictureUrl = game.player1?.profilePictureUrl
        self.player2ProfilePictureUrl = game.player2?.profilePictureUrl
        
        self.courtLatitude = game.court?.latitude
        self.courtLongitude = game.court?.longitude
    }

    var body: some View {
        VStack(spacing: 0) {
            Text(gameTitle)
                .font(.system(size: 16, weight: .bold))
                .foregroundColor(.gray)
                .padding(.top, 10)
            
            Text("\(gameDate) - \(gameTime)")
                .font(.system(size: 13, weight: .bold))
                .foregroundColor(.gray)
                .padding(.top, 1)
                .padding(.bottom, -20)

            HStack(spacing: 0) {
                // MARK: - Equipo Local
                VStack(alignment: .leading, spacing: 1) {
                    // --- USA player1Image AQUÍ ---
                    if let image = player1Image {
                        Image(uiImage: image)
                            .resizable()
                            .scaledToFit()
                            .frame(width: 70, height: 120)
                            .padding(.top, 40)
                    } else {
                        ProgressView()
                            .frame(width: 70, height: 120)
                            .background(Color.gray.opacity(0.2))
                            .padding(.top, 40)
                            .task {
                                if let urlString = player1ProfilePictureUrl, !urlString.isEmpty {
                                    player1Image = await AppUtils.fetchUIImage(from: urlString) // ASIGNA A player1Image
                                } else {
                                    print("❌ URL del jugador 1 es nil o vacía. No se intentará descargar.")
                                }
                            }
                    }

                    Text("\(homeTeamName)")
                        .font(.system(size: 12))
                        .fontWeight(.medium)
                        .foregroundColor(.black)
                        .frame(width: 70, alignment: .center)
                }
                .frame(maxWidth: .infinity, alignment: .leading)

                // MARK: - Marcador Central (No necesita cambios)
                HStack(spacing: 0) {
                    Text("\(homeTeamScore)")
                        .font(.system(size: 40, weight: .bold))
                        .foregroundColor(.black)
                        .frame(width: 60)
                        .padding(.top, 10)
                        .padding(.horizontal, 5)

                    VStack(spacing: 1) {
                        Text("VS")
                            .font(.system(size: 15))
                            .fontWeight(.bold)
                            .foregroundColor(.black)
                            .frame(width: 60)
                    }
                    .padding(.horizontal, 1)
                    .padding(.top, 10)

                    Text("\(awayTeamScore)")
                        .font(.system(size: 40, weight: .bold))
                        .foregroundColor(.black)
                        .frame(width: 60)
                        .padding(.top, 10)
                        .padding(.horizontal, 5)
                }
                .frame(maxWidth: .infinity, alignment: .trailing)

                // MARK: - Equipo Visitante
                VStack(alignment: .trailing, spacing: 1) {
                    // --- USA player2Image AQUÍ ---
                    if let image = player2Image {
                        Image(uiImage: image)
                            .resizable()
                            .scaledToFit()
                            .frame(width: 70, height: 120)
                            .padding(.top, 40)
                    } else {
                        ProgressView()
                            .frame(width: 70, height: 120)
                            .background(Color.gray.opacity(0.2))
                            .padding(.top, 40)
                            .task {
                                if let urlString = player2ProfilePictureUrl, !urlString.isEmpty {
                                    player2Image = await AppUtils.fetchUIImage(from: urlString) // ASIGNA A player2Image
                                } else {
                                    print("❌ URL del jugador 2 es nil o vacía. No se intentará descargar.")
                                }
                            }
                    }

                    Text("\(awayTeamName)")
                        .font(.system(size: 12))
                        .fontWeight(.medium)
                        .foregroundColor(.black)
                        .frame(width: 70, alignment: .center)
                }
                .frame(maxWidth: .infinity, alignment: .center) // Considera cambiar a .trailing para el equipo visitante.
            }
            .padding(.horizontal, 20)
            .padding(.top, -40)
            
            
            // MARK: - Resultado de la serie (Asegúrate de que `seriesResult` contenga el valor correcto)
            Text(seriesResult) // Esto debería ser el resultado, no una URL
                .font(.system(size: 13, weight: .bold))
                .fontWeight(.bold)
                .foregroundColor(.black)
                .padding(.bottom, 5)
                .padding(.top, -10)

            // MARK: - Línea divisoria (No necesita cambios)
            Rectangle()
                .fill(Color.gray.opacity(0.3))
                .frame(height: 1)
                .padding(.horizontal, 0)

            // MARK: - Sección de "League Pass" (No necesita cambios)
            HStack {
                Image(systemName: "calendar.badge.checkmark")
                    .font(.caption)
                    .symbolRenderingMode(.palette) // This is key for multi-color symbols
                    .foregroundStyle(.green, .red) // The first color is for the calendar, the second for the badge
                
                Text("\(gameEvent)")
                    .font(.caption)
                    .fontWeight(.semibold)
                    .foregroundColor(.black)
                Spacer()
                Text("\(gameStatus)")
                    .font(.system(size: 13, weight: .bold))
                    .foregroundColor({
                        switch gameStatus {
                        case "scheduled":
                            return .green
                        case "in_progress":
                            return .orange
                        case "finished":
                            return .gray
                        case "postponed":
                            return .blue
                        case "cancelled":
                            return .red
                        default:
                            return .black // Fallback color
                        }
                    }()) // Immediately invoke the closure
                    
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 10)
            .background(Color.white)
        }
        .background(Color.white)
        .cornerRadius(15)
        .shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: 2)
        .padding(.horizontal, 10)
        .task {
                    await fetchLocationForCourt()
                }
    }
    
    // MARK: - Función para obtener la ciudad y el barrio de la cancha
        @MainActor
        private func fetchLocationForCourt() async {
            // Solo intenta geocodificar si tenemos coordenadas válidas
            guard let latString = courtLatitude,
                  let lonString = courtLongitude,
                  let lat = CLLocationDegrees(latString),
                  let lon = CLLocationDegrees(lonString) else {
                seriesResult = "Coordenadas no válidas"
                print("Error: Latitud o Longitud de la cancha son nil o no son números válidos.")
                return
            }

            // Evita geocodificar (0,0) si no es una ubicación real
            if lat == 0.0 && lon == 0.0 {
                seriesResult = "Ubicación no especificada"
                return
            }

            do {
                let locationString = try await locationService.getCityAndNeighborhood(latitude: lat, longitude: lon)
                self.seriesResult = locationString
            } catch {
                print("Error geocodificando ubicación de la cancha: \(error.localizedDescription)")
                self.seriesResult = "Ubicación no disponible"
            }
        }
    
}

struct CCGameView_Previews: PreviewProvider {
    static var previews: some View {
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
        CCGameView(game: game)
            .previewLayout(.sizeThatFits) // Para que la preview se ajuste al contenido
            .padding()
    }
}

