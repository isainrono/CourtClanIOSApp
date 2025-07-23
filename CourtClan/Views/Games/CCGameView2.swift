//
//  CCGameView2.swift
//  CourtClan
//
//  Created by Isain Rodriguez Noreña on 21/7/25.
//

import SwiftUI
import CoreLocation

struct CCGameView2: View {

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
    @State var seriesResult: String = "Cargando ubicación..."

    @State private var player1Image: UIImage?
    @State private var player2Image: UIImage?

    let player1ProfilePictureUrl: String?
    let player2ProfilePictureUrl: String?
    let courtLatitude: String?
    let courtLongitude: String?
    let gameType: GameType
    let homeTeamPictureUrl: String?
    let awayTeamPictureUrl: String?

    init(game: Game2) {
        self.homeTeamScore = game.homeScore ?? 0
        self.awayTeamScore = game.awayScore ?? 0
        self.homeTeamName = game.homeTeam?.name ?? game.player1?.username ?? "Local"
        self.awayTeamName = game.awayTeam?.name ?? game.player2?.username ?? "Visitante"
        self.gameTitle = game.court?.name ?? "Cancha"
        self.gameDate = game.formattedDate()
        self.gameTime = game.formattedStartTime()
        self.gameStatus = game.gameStatus.rawValue
        self.gameEvent = game.event?.name ?? "Evento"
        self.courtLatitude = game.court?.latitude
        self.courtLongitude = game.court?.longitude
        self.gameType = game.gameType

        // Asignar URLs según el tipo de juego
        self.player1ProfilePictureUrl = gameType == .oneVsOne ? game.player1?.profilePictureUrl : nil
        self.player2ProfilePictureUrl = gameType == .oneVsOne ? game.player2?.profilePictureUrl : nil
        self.homeTeamPictureUrl = gameType == .teamGame ? game.homeTeam?.logoUrl : nil
        self.awayTeamPictureUrl = gameType == .teamGame ? game.awayTeam?.logoUrl : nil
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
                VStack(alignment: .leading, spacing: 1) {
                    imageView(for: .home)
                    Text(homeTeamName)
                        .font(.system(size: 12))
                        .fontWeight(.medium)
                        .foregroundColor(.black)
                        .frame(width: 70, alignment: .center)
                }
                .frame(maxWidth: .infinity, alignment: .leading)

                HStack(spacing: 0) {
                    Text("\(homeTeamScore)")
                        .font(.system(size: 40, weight: .bold))
                        .frame(width: 60)
                        .padding(.top, 10)

                    Text("VS")
                        .font(.system(size: 15, weight: .bold))
                        .frame(width: 60)
                        .padding(.top, 10)

                    Text("\(awayTeamScore)")
                        .font(.system(size: 40, weight: .bold))
                        .frame(width: 60)
                        .padding(.top, 10)
                }

                VStack(alignment: .trailing, spacing: 1) {
                    imageView(for: .away)
                    Text(awayTeamName)
                        .font(.system(size: 12))
                        .fontWeight(.medium)
                        .foregroundColor(.black)
                        .frame(width: 70, alignment: .center)
                }
                .frame(maxWidth: .infinity, alignment: .center)
            }
            .padding(.horizontal, 20)
            .padding(.top, -40)

            Text(seriesResult)
                .font(.system(size: 13, weight: .bold))
                .padding(.top, -10)

            Rectangle()
                .fill(Color.gray.opacity(0.3))
                .frame(height: 1)
                .padding(.horizontal, 0)

            HStack {
                Image(systemName: "calendar.badge.checkmark")
                    .font(.caption)
                    .symbolRenderingMode(.palette)
                    .foregroundStyle(.green, .red)

                Text(gameEvent)
                    .font(.caption)
                    .fontWeight(.semibold)

                Spacer()

                Text(gameStatus)
                    .font(.system(size: 13, weight: .bold))
                    .foregroundColor(statusColor(for: gameStatus))
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 10)
        }
        .background(Color.white)
        .cornerRadius(15)
        .shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: 2)
        .padding(.horizontal, 10)
        .task {
            await fetchLocation()
        }
    }

    private enum Side { case home, away }

    @ViewBuilder
    private func imageView(for side: Side) -> some View {
        let image = side == .home ? player1Image : player2Image
        let urlString: String? = {
            if gameType == .oneVsOne {
                return side == .home ? player1ProfilePictureUrl : player2ProfilePictureUrl
            } else {
                return side == .home ? homeTeamPictureUrl : awayTeamPictureUrl
            }
        }()

        if let image = image {
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
                    if let url = urlString, !url.isEmpty {
                        if let fetchedImage = await AppUtils.fetchUIImage(from: url) {
                            if side == .home {
                                player1Image = fetchedImage
                            } else {
                                player2Image = fetchedImage
                            }
                        }
                    }
                }
        }
    }

    private func statusColor(for status: String) -> Color {
        switch status {
        case "scheduled": return .green
        case "in_progress": return .orange
        case "finished": return .gray
        case "postponed": return .blue
        case "cancelled": return .red
        default: return .black
        }
    }

    @MainActor
    private func fetchLocation() async {
        guard
            let latStr = courtLatitude, let lonStr = courtLongitude,
            let lat = CLLocationDegrees(latStr),
            let lon = CLLocationDegrees(lonStr),
            !(lat == 0.0 && lon == 0.0)
        else {
            seriesResult = "Ubicación no válida"
            return
        }

        do {
            seriesResult = try await locationService.getCityAndNeighborhood(latitude: lat, longitude: lon)
        } catch {
            print("❌ Error obteniendo ubicación: \(error.localizedDescription)")
            seriesResult = "Ubicación no disponible"
        }
    }
}


