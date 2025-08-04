//
//  ManageGame2View.swift
//  CourtClan
//
//  Created by Isain Rodriguez Noreña on 21/7/25.
//

import SwiftUI
import Combine

struct ManageGame2View: View {
        let game: Game2
    
        @State private var homeScore: Int
        @State private var awayScore: Int
        @State private var homeFouls: Int = 0
        @State private var awayFouls: Int = 0
        @State private var selectedScorerID: String? = nil
        @State private var showingScoreButtons: Bool = false
    
        @State private var homeName: String
        @State private var awayName: String
    
        @State private var player1Image: UIImage?
        @State private var player2Image: UIImage?
    
        @State private var timeRemaining: Int
        @State private var timer: AnyCancellable? = nil
        @State private var isRunning = false
    
        @State private var showDurationPrompt = true
        @State private var customDurationMinutes: String = "7"
    
        let homeScorerID: String
        let awayScorerID: String
    
        init(game: Game2) {
                self.game = game
                _homeScore = State(initialValue: game.homeScore ?? 0)
                _awayScore = State(initialValue: game.awayScore ?? 0)
                _timeRemaining = State(initialValue: 600) // Default 10 min until user sets custom
        
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
                GeometryReader { geometry in
                        ZStack {
                                Color(.systemBackground) // opcional, para mantener el fondo
                                    .edgesIgnoringSafeArea(.all)
                
                                HStack(spacing: 0) {
                                        // Lado Izquierdo: Jugador/Equipo Local
                                        VStack {
                                                PlayerButtonView(
                                                        image: player1Image,
                                                        name: homeName,
                                                        isSelected: selectedScorerID == homeScorerID
                                                    ) {
                                                            selectedScorerID = homeScorerID
                                                            showingScoreButtons = true
                                                        }
                        
                                                Text("\(homeScore)")
                                                    .font(.system(size: 60, weight: .bold))
                                                    .padding(.top)
                        
                                                Text(homeName)
                                                    .font(.headline)
                                               
                                                Text("Faltas: \(homeFouls)")
                                                    .font(.subheadline)
                                                    .foregroundColor(.secondary)
                                            }
                                        .frame(width: geometry.size.width * 0.25)
                                        .padding()
                    
                                        // Centro: Reloj y controles
                                        VStack(spacing: 20) {
                                                Text(timeString(from: timeRemaining))
                                                    .font(.system(size: 100, weight: .bold, design: .monospaced))
                                                    .foregroundColor(.red)
                                                    .padding(.horizontal, 40)
                                                    .padding(.vertical, 20)
                                                    .background(Color.black)
                                                    .cornerRadius(12)
                                                    .overlay(
                                                            RoundedRectangle(cornerRadius: 12)
                                                                .stroke(Color.red, lineWidth: 4)
                                                        )
                                                HStack(spacing: 20) {
                                                        Button(action: { isRunning ? pauseTimer() : startTimer() }) {
                                                                Label(isRunning ? "Pausar" : "Iniciar", systemImage: isRunning ? "pause.fill" : "play.fill")
                                                                    .padding().background(isRunning ? Color.orange : Color.green).foregroundColor(.white).cornerRadius(12)
                                                            }
                                                        Button(action: resetTimer) {
                                                                Label("Reiniciar", systemImage: "arrow.counterclockwise")
                                                                    .padding().background(Color.red).foregroundColor(.white).cornerRadius(12)
                                                            }
                                                    }
                        
                                                if showingScoreButtons {
                                                        VStack {
                                                                HStack(spacing: 10) {
                                                                        ScoreButton(title: "+1", points: 1, action: addPoints, buttonColor: .blue)
                                                                        ScoreButton(title: "+2", points: 2, action: addPoints, buttonColor: .blue)
                                                                        ScoreButton(title: "+3", points: 3, action: addPoints, buttonColor: .blue)
                                                                        ScoreButton(title: "+4", points: 4, action: addPoints, buttonColor: .blue)
                                                                        ScoreButton(title: "-1", points: -1, action: addPoints, buttonColor: .gray)
                                                                    }
                                                                HStack(spacing: 10) {
                                                                        Button(action: addFoul) {
                                                                                Text("Falta")
                                                                                    .padding()
                                                                                    .frame(maxWidth: .infinity)
                                                                                    .background(Color.purple)
                                                                                    .foregroundColor(.white)
                                                                                    .cornerRadius(12)
                                                                            }
                                                                    }
                                                            }
                                                        .padding(.top)
                                                    }
                                            }
                                        .frame(width: geometry.size.width * 0.5)
                                        .padding()
                    
                                        // Lado Derecho: Jugador/Equipo Visitante
                                        VStack {
                                                PlayerButtonView(
                                                        image: player2Image,
                                                        name: awayName,
                                                        isSelected: selectedScorerID == awayScorerID
                                                    ) {
                                                            selectedScorerID = awayScorerID
                                                            showingScoreButtons = true
                                                        }
                        
                                                Text("\(awayScore)")
                                                    .font(.system(size: 60, weight: .bold))
                                                    .padding(.top)
                        
                                                Text(awayName)
                                                    .font(.headline)
                                                
                                                Text("Faltas: \(awayFouls)")
                                                    .font(.subheadline)
                                                    .foregroundColor(.secondary)
                                            }
                                        .frame(width: geometry.size.width * 0.25)
                                        .padding()
                                    }
                                .frame(width: geometry.size.width, alignment: .center)
                            }
                    }
                .onAppear {
                        loadImages()
                    }
                .sheet(isPresented: $showDurationPrompt) {
                        VStack(spacing: 20) {
                                Text("Duración del partido (minutos)")
                                    .font(.headline)
                                TextField("Ej: 10", text: $customDurationMinutes)
                                    .keyboardType(.numberPad)
                                    .padding().background(Color(.systemGray6)).cornerRadius(8)
                                    .frame(width: 150)
                
                                Button("Iniciar") {
                                        let minutes = Int(customDurationMinutes) ?? 10
                                        timeRemaining = minutes * 60
                                        showDurationPrompt = false
                                    }
                                .padding().background(Color.green).foregroundColor(.white).cornerRadius(12)
                            }
                        .padding()
                    }
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
        
        private func addFoul() {
                guard let teamID = selectedScorerID else { return }
                if teamID == homeScorerID {
                        homeFouls += 1
                    } else {
                            awayFouls += 1
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
                let minutes = Int(customDurationMinutes) ?? 10
                timeRemaining = minutes * 60
                homeScore = 0
                awayScore = 0
                homeFouls = 0
                awayFouls = 0
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
