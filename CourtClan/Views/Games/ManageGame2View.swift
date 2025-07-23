//
//  ManageGame2View.swift
//  CourtClan
//
//  Created by Isain Rodriguez Noreña on 21/7/25.
//

//  ManageGame2View.swift
//  CourtClan
//  Adaptado para manejar juego Game2 (1v1 y por equipos)

import SwiftUI
import Combine

struct ManageGame2View: View {
    let game: Game2
    
    @State private var homeScore: Int
    @State private var awayScore: Int
    @State private var selectedScorerID: String? = nil
    @State private var showingScoreButtons: Bool = false

    @State private var homeName: String
    @State private var awayName: String

    @State private var player1Image: UIImage?
    @State private var player2Image: UIImage?

    @State private var timeRemaining: Int
    @State private var timer: AnyCancellable? = nil
    @State private var isRunning = false

    private let initialGameDurationMinutes = 10

    let homeScorerID: String
    let awayScorerID: String

    init(game: Game2) {
        self.game = game
        _homeScore = State(initialValue: game.homeScore ?? 0)
        _awayScore = State(initialValue: game.awayScore ?? 0)
        _timeRemaining = State(initialValue: initialGameDurationMinutes * 60)

        if game.gameType == .oneVsOne {
            _homeName = State(initialValue: game.player1?.username ?? "Jugador 1")
            _awayName = State(initialValue: game.player2?.username ?? "Jugador 2")
            homeScorerID = game.player1?.id ?? "player1"
            awayScorerID = game.player2?.id ?? "player2"
        } else {
            _homeName = State(initialValue: game.homeTeam?.name ?? "Equipo Local")
            _awayName = State(initialValue: game.awayTeam?.name ?? "Equipo Visitante")
            homeScorerID = game.homeTeam?.id ?? "home_team"
            awayScorerID = game.awayTeam?.id ?? "away_team"
        }
    }

    var body: some View {
        VStack {
            Text(game.court?.name ?? "Cancha")
                .font(.title2).bold()
            Text("\(game.formattedDate()) - \(game.formattedStartTime()) (\(game.gameStatus.rawValue))")
                .font(.subheadline).foregroundColor(.gray)

            HStack {
                VStack {
                    Text("\(homeScore)").font(.largeTitle).bold()
                    Text(homeName).font(.headline)
                }
                Spacer()
                VStack {
                    Text("\(awayScore)").font(.largeTitle).bold()
                    Text(awayName).font(.headline)
                }
            }.padding()

            HStack {
                PlayerButtonView(
                    image: player1Image,
                    name: homeName,
                    isSelected: selectedScorerID == homeScorerID
                ) {
                    selectedScorerID = homeScorerID
                    showingScoreButtons = true
                }

                PlayerButtonView(
                    image: player2Image,
                    name: awayName,
                    isSelected: selectedScorerID == awayScorerID
                ) {
                    selectedScorerID = awayScorerID
                    showingScoreButtons = true
                }
            }.padding()

            if showingScoreButtons {
                HStack(spacing: 15) {
                    ScoreButton(title: "+1", points: 1, action: addPoints, buttonColor: .blue)
                    ScoreButton(title: "+2", points: 2, action: addPoints, buttonColor: .blue)
                    ScoreButton(title: "+3", points: 3, action: addPoints, buttonColor: .blue)
                }.padding()
            }

            Text(timeString(from: timeRemaining))
                .font(.system(size: 60, weight: .bold, design: .monospaced))
                .padding()

            HStack(spacing: 20) {
                Button(action: { isRunning ? pauseTimer() : startTimer() }) {
                    Label(isRunning ? "Pausar" : "Iniciar", systemImage: isRunning ? "pause.fill" : "play.fill")
                        .padding().background(isRunning ? Color.orange : Color.green).foregroundColor(.white).cornerRadius(12)
                }
                Button(action: resetTimer) {
                    Label("Reiniciar", systemImage: "arrow.counterclockwise")
                        .padding().background(Color.red).foregroundColor(.white).cornerRadius(12)
                }
            }.padding()
        }
        .onAppear(perform: loadImages)
    }

    private func addPoints(_ points: Int) {
        guard let scorer = selectedScorerID else { return }
        if scorer == homeScorerID {
            homeScore += points
        } else {
            awayScore += points
        }
        selectedScorerID = nil
        showingScoreButtons = false
    }

    private func startTimer() {
        guard !isRunning && timeRemaining > 0 else { return }
        isRunning = true
        timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect().sink { _ in
            if timeRemaining > 0 {
                timeRemaining -= 1
            } else {
                pauseTimer()
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
        homeScore = 0
        awayScore = 0
        selectedScorerID = nil
        showingScoreButtons = false
    }

    private func timeString(from totalSeconds: Int) -> String {
        let minutes = totalSeconds / 60
        let seconds = totalSeconds % 60
        return String(format: "%02d:%02d", minutes, seconds)
    }

    private func loadImages() {
        Task {
            if game.gameType == .oneVsOne {
                if let url = game.player1?.profilePictureUrl, !url.isEmpty {
                    player1Image = await AppUtils.fetchUIImage(from: url)
                }
                if let url = game.player2?.profilePictureUrl, !url.isEmpty {
                    player2Image = await AppUtils.fetchUIImage(from: url)
                }
            } else if game.gameType == .teamGame {
                if let url = game.homeTeam?.logoUrl, !url.isEmpty {
                    player1Image = await AppUtils.fetchUIImage(from: url)
                }
                if let url = game.awayTeam?.logoUrl, !url.isEmpty {
                    player2Image = await AppUtils.fetchUIImage(from: url)
                }
            }
        }
    }
}
