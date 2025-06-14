//
//  HeaderProfile.swift
//  CourtClan
//
//  Created by Isain Rodriguez Noreña on 7/6/25.
//

import SwiftUI

struct HeaderProfile: View {
    
    @EnvironmentObject var appData: AppData
    var player: Player?
    var imageSizeWith: CGFloat = 80
    var imageSizeHeight: CGFloat = 80
    @State private var isProfilePageViewActive: Bool = false
    
    init(player:Player) {
        self.player = player
    }
    
    var body: some View {
        // MARK: - Contenido del Perfil del Jugador
        // MARK: - Header (Simulado como el degradado superior)
        ZStack(alignment: .bottomLeading) {
            LinearGradient(gradient: Gradient(colors: [Color.ccPrimary, Color.black]), startPoint: .topLeading, endPoint: .bottomTrailing)
                .frame(height: 220) // Altura del área de degradado
                .cornerRadius(20) // Esquinas redondeadas si lo deseas
            
            VStack(alignment: .leading, spacing: 5) {
                Text("Good Morning")
                    .font(.title3)
                    .fontWeight(.light)
                    .foregroundColor(.white)
                
                Text(player!.username)
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
            }
            .padding(.horizontal)
            .padding(.bottom, 20) // Ajusta el padding para que no choque con la parte inferior
            
            // Widget de clima posicionado a la derecha
            HStack {
                Spacer()
                
                Button {
                    print("button pressed!")
                    isProfilePageViewActive = true
                } label: {
                    
                    
                    
                    VStack (alignment: .center, spacing: -20){
                        // Imagen de Perfil (si existe)
                        
                        Group {
                            if let profilePictureUrlString = player?.profilePictureUrl,
                               let url = URL(string: profilePictureUrlString) {
                                
                                AsyncImage(url: url) { phase in
                                    switch phase {
                                    case .empty:
                                        // Muestra un ProgressView mientras carga
                                        ProgressView()
                                            .frame(width: 100, height: 100) // Mismo tamaño que la imagen final
                                            .background(Color.gray.opacity(0.3)) // Un fondo para el placeholder
                                            .clipShape(Circle())
                                    case .success(let image):
                                        // Muestra la imagen cargada
                                        image
                                            .resizable()
                                            .aspectRatio(contentMode: .fill)
                                            .frame(width: 100, height: 100)
                                            .clipShape(Circle())
                                            .overlay(Circle().stroke(Color.ccPrimary, lineWidth: 0)) // No necesitas stroke si lineWidth es 0
                                            .shadow(radius: 10)
                                    case .failure:
                                        // Muestra una imagen de sistema si falla la carga
                                        Image(systemName: "exclamationmark.triangle.fill")
                                            .resizable()
                                            .aspectRatio(contentMode: .fit)
                                            .frame(width: imageSizeWith, height: imageSizeHeight)
                                            .foregroundColor(.red) // O un color que indique error
                                            .clipShape(Circle()) // Para mantener la forma
                                    @unknown default:
                                        // Fallback para futuros casos de fase
                                        EmptyView()
                                    }
                                }
                            } else {
                                // Muestra la imagen de sistema si no hay URL o es inválida
                                
                                Image(systemName: "person.circle.fill")
                                    .resizable()
                                    .aspectRatio(contentMode: .fit)
                                    .frame(width: imageSizeWith, height: imageSizeHeight)
                                    .foregroundColor(.gray)
                            }
                            
                            
                        }
                        .padding()
                        
                        Button {
                            print("button pressed!")
                        } label: {
                            Text("\(String(self.player!.marketValue))-R")
                                .foregroundColor(.green)
                                .padding()
                        }
                        
                        
                        
                    }
                    
                }
                
                
            }
            .padding(.horizontal)
            
            //StatisticsView(win: player.gamesWon, loss: player.gamesPlayed-player.gamesWon, draw: 0)
        }
        .fullScreenCover(isPresented: $isProfilePageViewActive) {
            ProfilePageView(isPresented: $isProfilePageViewActive)
                .environmentObject(appData)
        }
    }
        
}

#Preview {
    var player = Player(
        id: UUID().uuidString,
        username: "jayson_t",
        email: "jayson@celtics.com",
        fullName: "Jayson Tatum",
        bio: "Future MVP.",
        profilePictureUrl: nil, // Example of a player without a profile picture
        location: "Boston, MA",
        dateOfBirth: Date().addingTimeInterval(-26 * 365 * 24 * 60 * 60),
        gender: "Male",
        preferredPosition: "Small Forward",
        skillLevelId: UUID().uuidString,
        currentLevel: 90,
        totalXp: 80000,
        gamesPlayed: 500,
        gamesWon: 300,
        winPercentage: 60.0,
        avgPointsPerGame: 26.0,
        avgAssistsPerGame: 4.0,
        avgReboundsPerGame: 8.0,
        avgBlocksPerGame: 0.7,
        avgStealsPerGame: 1.0,
        isPublic: true,
        isActive: true,
        currentTeamId: UUID().uuidString,
        marketValue: 35000000.0,
        isFreeAgent: false,
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
    HeaderProfile(player: player)
}
