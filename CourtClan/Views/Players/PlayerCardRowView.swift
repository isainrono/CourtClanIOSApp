//
//  PlayerCardRowView.swift
//  CourtClan
//
//  Created by Isain Rodriguez Noreña on 22/5/25.
//

import SwiftUI

struct PlayerCardRowView: View {
    let player: Player
    
    
    var body: some View {
        
        NavigationLink{}label: {
            ZStack {
                // Background Color (similar to the image)
                Color(red: 30/255, green: 26/255, blue: 62/255)
                Image("logoTipo")
                    .resizable()
                    .edgesIgnoringSafeArea(.all)
                    .opacity(0.1)
                
                
                HStack(spacing: 0) {
                    // ... dentro de PlayerCardRowView.swift, en el body
                    if let profileUrl = player.profilePictureUrl, let url = URL(string: profileUrl) {
                        AsyncImage(url: url) { phase in
                            switch phase {
                            case .empty: // No image is loaded yet, showing placeholder
                                ProgressView()
                                    .frame(width: 120)
                                    .clipped()
                                    .background(Color.gray.opacity(0.2))
                                    .padding(.trailing, 5)
                            case .success(let image): // Image successfully loaded
                                image
                                    .resizable()
                                    .scaledToFill()
                                    .frame(width: 120)
                                    .clipped()
                                    .padding(.trailing, 5)
                            case .failure(let error): // Image failed to load, show error or fallback
                                // *** Aquí puedes imprimir el error para depurar ***
                                Text("Failed to load image")
                                    .foregroundColor(.red)
                                Image(systemName: "exclamationmark.triangle.fill") // Icono de error
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: 120)
                                    .foregroundColor(.red)
                                    .clipped()
                                    .background(Color.gray.opacity(0.2))
                                    .padding(.trailing, 5)
                                // Imprime el error real en la consola de Xcode
                                
                                // Puedes añadir un .onAppear para imprimir el error en la consola
                                // .onAppear { print("Error loading image from \(url): \(error)") }
                            @unknown default:
                                EmptyView()
                            }
                        }
                    } else {
                        // Fallback if profilePictureUrl is nil or not a valid URL string
                        Image(systemName: "person.fill")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 120)
                            .foregroundColor(.green)
                            .clipped()
                            .background(Color.gray.opacity(0.2))
                            .padding(.trailing, 5)
                    }
                    
                    // Right Side - Player Info
                    VStack(alignment: .leading, spacing: 10) {
                        Text(player.username)
                            .font(.custom("Chalkboard SE", size: 25))
                            .fontWeight(.bold)
                            .foregroundColor(.white)
                        
                        Text(player.team?.name ?? "no name")
                            .font(.subheadline)
                            .foregroundColor(Color(white: 0.7))
                        
                        HStack(spacing: 15) {
                            VStack(alignment: .center) {
                                Text("\(player.gamesWon)")
                                    .font(.title3)
                                    .fontWeight(.bold)
                                    .foregroundColor(.white)
                                Text("GAMES")
                                    .font(.caption)
                                    .foregroundColor(Color(white: 0.7))
                            }
                            
                            Divider()
                                .frame(height: 20)
                                .foregroundColor(Color(white: 0.5))
                            
                            VStack(alignment: .center) {
                                Text(String(format: "%.1f", player.avgPointsPerGame))
                                    .font(.title3)
                                    .fontWeight(.bold)
                                    .foregroundColor(.white)
                                Text("FPPG")
                                    .font(.caption)
                                    .foregroundColor(Color(white: 0.7))
                            }
                            
                            Divider()
                                .frame(height: 20)
                                .foregroundColor(Color(white: 0.5))
                            
                            VStack(alignment: .center) {
                                Text(String(player.marketValue))
                                    .font(.title3)
                                    .fontWeight(.bold)
                                    .foregroundColor(.white)
                                Text("SALARY")
                                    .font(.caption)
                                    .foregroundColor(Color(white: 0.7))
                            }
                        }
                        
                        Spacer() // Push content to the top
                        
                        
                    }
                    .padding()
                    .frame(maxWidth: .infinity) // Occupy remaining width
                    
                }
                
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .cornerRadius(10) // Optional: Add rounded corners to the entire card
            .frame(height: 150) // Set the height of the ZStack to match the content
            .frame(width: .infinity)
        }
        
        
    }
}

struct PlayerCardRowView_Previews: PreviewProvider {
    static var previews: some View {
        // Creamos un jugador de ejemplo para el preview
        let samplePlayer = Player(
            id: UUID().uuidString,
            username: "lebron_j",
            email: "lebron@lakers.com",
            fullName: "LeBron James",
            bio: "King James. Living legend of basketball.",
            profilePictureUrl: "https://isainrodriguez.com/me/images/courtclan/david.png", // Asegúrate de tener una imagen "david" en tus Assets.xcassets
            location: "Los Angeles, CA",
            dateOfBirth: Date().addingTimeInterval(-39 * 365 * 24 * 60 * 60), // Aproximadamente 39 años
            gender: "Male",
            preferredPosition: "Small Forward",
            skillLevelId: UUID().uuidString,
            currentLevel: 99,
            totalXp: 99999,
            gamesPlayed: 1400,
            gamesWon: 900,
            winPercentage: 64.2,
            avgPointsPerGame: 27.2,
            avgAssistsPerGame: 7.3,
            avgReboundsPerGame: 7.5,
            avgBlocksPerGame: 0.8,
            avgStealsPerGame: 1.3,
            isPublic: true,
            isActive: true,
            currentTeamId: "some_team_id_123", // Puedes poner un ID real si usas Team.sampleTeams
            marketValue: 50000000.0, // Un gran valor de mercado
            isFreeAgent: false,
            lastLogin: Date(),
            createdAt: Date(),
            updatedAt: Date(),
            // Puedes adjuntar un equipo de ejemplo si tu Team struct tiene un sampleTeam
            team: Team(
                id: UUID().uuidString,
                name: "Los Angeles Lakers",
                description: "An iconic basketball team.",
                logoUrl: "https://example.com/lakers_logo.png",
                ownerUserId: UUID().uuidString,
                captainUserId: UUID().uuidString,
                teamFunds: 10000000.0,
                createdAt: Date(),
                updatedAt: Date()
            )
        )
        
        // Aquí es donde pasamos el jugador de ejemplo a la vista.
        PlayerCardRowView(player: samplePlayer)
            .previewLayout(.sizeThatFits) // Ajusta el preview para que se ajuste al contenido
            .padding() // Añade un poco de padding alrededor de la vista en el preview
            .background(Color.black) // Un fondo oscuro para que la tarjeta resalte
    }
}
