//
//  ActivityCard.swift
//  CourtClan
//
//  Created by Isain Rodriguez Noreña on 5/6/25.
//

import SwiftUI



// MARK: - Vista Principal
struct Activity2: Identifiable {
    let id = UUID()
    let name: String
    let imageName: String // Nombre de la imagen del sistema o asset
    let color: Color // Color de fondo de la tarjeta
    var description: String
}

struct ActivityCard2: View {
    let activity2: Activity2
    var player: Player?
    var imageSizeWith: CGFloat = 60
    var imageSizeHeight: CGFloat = 60
    
    
    
    
    var body: some View {
        VStack(alignment: .center, spacing: 3) {
            
            HStack{
                
                
                if activity2.name == "Equipo" {
                    
                    if activity2.description == "FREE" {
                        
                        Text("cdscsd")
                        Text(activity2.description)
                            .font(.system(size: 35, weight: .bold))
                            .foregroundColor(.gray)
                    } else {
                        if let profilePictureUrlString = player?.team?.logoUrl,
                           let url = URL(string: profilePictureUrlString) {
                            
                            AsyncImage(url: url) { phase in
                                switch phase {
                                case .empty:
                                    // Muestra un ProgressView mientras carga
                                    ProgressView()
                                        .frame(width: imageSizeWith, height: imageSizeHeight) // Mismo tamaño que la imagen final
                                        .background(Color.gray.opacity(0.3)) // Un fondo para el placeholder
                                        .clipShape(Circle())
                                case .success(let image):
                                    // Muestra la imagen cargada
                                    image
                                        .resizable()
                                        .aspectRatio(contentMode: .fill)
                                        .frame(width: imageSizeWith, height: imageSizeHeight)
                                        .clipShape(Circle())
                                        .overlay(Circle().stroke(Color.ccPrimary, lineWidth: 0)) // No necesitas stroke si lineWidth es 0
                                        .shadow(radius: 10)
                                case .failure:
                                    // Muestra una imagen de sistema si falla la carga
                                    Image(systemName: "exclamationmark.triangle.fill")
                                        .resizable()
                                        .aspectRatio(contentMode: .fit)
                                        .frame(width: imageSizeWith, height:imageSizeHeight)
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
                                .frame(width: 50, height: 50)
                                .foregroundColor(.gray)
                        }
                    }
                    
                } else {
                    Text(activity2.description)
                        .font(.system(size: 35, weight: .bold))
                        .foregroundColor(.gray)
                    Image(activity2.imageName)
                    
                }
                
                
               
                
                
            }
            .padding(.top, 10)
            
           
            Text(activity2.name)
                .font(.headline)
                .foregroundColor(.primary)
                .padding(.bottom, 15)
            
            
            
        }
        .padding()
        .frame(maxWidth: .infinity, maxHeight: 100) // Ajusta el tamaño de la tarjeta
        .background(activity2.color.opacity(0.4)) // Fondo ligero con el color
        .cornerRadius(15)
        .shadow(color: Color.black.opacity(0.05), radius: 5, x: 0, y: 3)
    }
}

struct TootleHomeView: View {
    // Datos de ejemplo para las actividades
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
    var activities: [Activity2] = [
        Activity2(name: "Posición", imageName: "figure.walk", color: .green, description: ""),
        Activity2(name: "Level", imageName: "figure.bike", color: .blue, description: ""),
        Activity2(name: "Puntos", imageName: "car.fill", color: .orange, description: ""),
        Activity2(name: "Equipo", imageName: "train.fill", color: .purple, description: ""),

    ]
    
    init(player: Player) {
        self.player = player // Asigna el player recibido
        
        // Luego puedes modificar el primer elemento de activities
        self.activities[0].description = self.player.preferredPosition!
        self.activities[1].description = String(self.player.currentLevel)
        self.activities[2].description = String(self.player.totalXp)
        self.activities[3].description = self.player.team?.name ?? "FREE"
    }
    
    var body: some View {
            ScrollView(.vertical, showsIndicators: false) {
                VStack(alignment: .leading, spacing: 20) {
                    
                    
                    // MARK: - Contenido Principal
                    
                    Text("Information")
                        .font(.title2)
                        .fontWeight(.bold)
                        .padding(.horizontal)
                    
                    // Cuadrícula de actividades
                    LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 15) {
                        ForEach(activities) { activity2 in
                            ActivityCard2(activity2: activity2,player: player)
                        }
                    }
                    .padding(.horizontal)
                   // .padding(.bottom, 20) // Espacio al final de la cuadrícula*/
                    
                    
                }
            }
            // Oculta la barra de navegación por defecto de SwiftUI para crear la personalizada
            .navigationBarHidden(true)
            .navigationBarTitleDisplayMode(.inline) // Solo si no ocultas la barra
            .edgesIgnoringSafeArea(.top) // Extiende el contenido hasta la parte superior de la pantalla
        
    }
}

// MARK: - Previews

struct TootleHomeView_Previews: PreviewProvider {
    static var previews: some View {
        let nPlayer =  Player(
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
        TootleHomeView(player: nPlayer)
    }
}
