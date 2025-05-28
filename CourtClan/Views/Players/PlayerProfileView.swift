//
//  PlayerProfileView.swift
//  CourtClan
//
//  Created by Isain Rodriguez Noreña on 22/5/25.
//

import SwiftUI

struct PlayerProfileView: View {
    
    let playerName: String
    let position: String
    let team: String
    let place: Int
    let minutes: Int
    let points: Int
    let fgPercentage: Double
    let rebounds: Int
    let assists: Double
    let steals: Double
    let image: Image // You'll need to provide the Image
    let wins: Int = 49
    let losses: Int = 5
    let draws: Int = 10
    var totalGames: Int {
        wins + losses + draws
    }
    var winPercentage: Double {
        Double(wins) / Double(totalGames)
    }
    var lossPercentage: Double {
        Double(losses) / Double(totalGames)
    }
    var drawPercentage: Double {
        Double(draws) / Double(totalGames)
    }
    
   
    
    var body: some View {
        
        ScrollView {
            VStack(spacing: 0) { // Added VStack to stack the elements vertically
                ZStack(alignment: .topLeading) {
                    image
                        .resizable()
                        .scaledToFill()
                        .frame(maxWidth: .infinity, maxHeight: 280)
                        .clipped()
                    
                    HStack(alignment: .center) {
                        Text("RODMON PLAYER")
                            .font(.caption2)
                            .fontWeight(.bold)
                            .foregroundColor(.white)
                            .padding(8)
                            .background(Color.red.opacity(0.8))
                            .cornerRadius(5)
                    }
                    .padding(.horizontal)
                    .padding(.top)
                }
                
                HStack {
                    VStack(alignment: .center) {
                        Text("\(place)")
                            .font(.largeTitle)
                            .fontWeight(.bold)
                            .foregroundColor(.white)
                        Text("PLACE")
                            .font(.caption)
                            .foregroundColor(.gray)
                    }
                    .frame(width: 80)
                    Divider()
                        .frame(height: 30)
                        .background(Color.gray)
                    VStack(alignment: .leading) {
                        Text(playerName.uppercased())
                            .font(.headline)
                            .fontWeight(.bold)
                            .foregroundColor(.white)
                        Text("\(position.uppercased()) | \(team.uppercased())")
                            .font(.caption)
                            .foregroundColor(.gray)
                    }
                    Spacer()
                    Image(systemName: "plus.circle.fill")
                        .font(.largeTitle)
                        .foregroundColor(Color(red: 118/255, green: 215/255, blue: 194/255))
                        .padding(.trailing)
                }
                .padding()
                //.background(Color(white: 0, opacity: 0.2))
                .background(Color(red: 103/255, green: 65/255, blue: 153/255))
                
                VStack(spacing: 20) { // Añadimos un espaciado entre el botón y los Spacers
                    // Empuja el botón hacia el centro verticalmente
                    
                    Button {
                        // Acción del botón
                        print("Botón '1 VS 1' presionado")
                    } label: {
                        HStack(spacing: 16) { // Espaciado entre los elementos del texto
                            Text("1")
                                .font(.largeTitle)
                                .fontWeight(.bold)
                                .foregroundColor(Color.white.opacity(0.7))
                            Text("VS")
                                .font(.headline)
                                .fontWeight(.semibold)
                                .foregroundColor(Color.white.opacity(0.7)) // Color secundario
                            Text("1")
                                .font(.largeTitle)
                                .fontWeight(.bold)
                                .foregroundColor(Color.white.opacity(0.7))
                        }
                        //.padding(.horizontal, 50) // Añade padding horizontal
                        .padding(.vertical, 8)   // Añade padding vertical
                        .frame(maxWidth: .infinity) // Expande horizontalmente dentro del botón
                        .background(LinearGradient(gradient: Gradient(colors: [
                            Color(red: 103/255, green: 65/255, blue: 153/255), // Color principal más oscuro
                            Color(red: 118/255, green: 215/255, blue: 194/255)  // Color de acento más claro
                        ]), startPoint: .leading, endPoint: .trailing))
                        .cornerRadius(10) // Bordes más redondeados
                        .shadow(color: Color.black.opacity(0.2), radius: 5, x: 0, y: 2) // Ligera sombra
                    }
                    .buttonStyle(PlainButtonStyle()) // Elimina el estilo de botón predeterminado para personalizarlo completamente
                    
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                //.background(Color(white: 0.1)) // Fondo oscuro para contrastar
                
                //.background(Color(white: 0, opacity: 0.2))
                .background(Color(red: 103/255, green: 65/255, blue: 153/255))
                HStack{
                    
                    Text("Datos")
                        .font(.system(size: 20))
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                    Spacer()
                    
                }
                .padding()
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .background(Color(white: 0, opacity: 0.2))
                .background(Color(red: 103/255, green: 65/255, blue: 153/255))
                
                
                HStack (spacing: 8){
                    ZStack {
                        // Background Circle
                        Circle()
                            .fill(Color.gray.opacity(0.2))
                            .frame(maxWidth: 120, maxHeight: 120)
                        
                        // First color segment (wins)
                        Circle()
                            .trim(from: 0, to: winPercentage)
                            .stroke(Color.green, style: StrokeStyle(lineWidth: 5, dash: [1,0]))
                            .frame(maxWidth: 120, maxHeight: 120)
                            .rotationEffect(.degrees(-90))
                        
                        // Second color segment (losses)
                        Circle()
                            .trim(from: winPercentage, to: winPercentage + lossPercentage)
                            .stroke(Color.orange, style: StrokeStyle(lineWidth: 5, dash: [1,0]))
                            .frame(maxWidth: 120, maxHeight: 120)
                            .rotationEffect(.degrees(-90))
                        
                        // Third color segment (draws)
                        Circle()
                            .trim(from: winPercentage + lossPercentage, to: 1)
                            .stroke(Color.white, style: StrokeStyle(lineWidth: 5, dash: [1,0]))
                            .frame(maxWidth: 120, maxHeight: 120)
                            .rotationEffect(.degrees(-90))
                        
                        VStack {
                            Text("\(totalGames)")
                                .font(.largeTitle)
                                .foregroundColor(.white)
                            Text("GAMES")
                                .font(.callout)
                                .foregroundColor(.gray)
                        }
                    }
                    Spacer() // Pushes the following VStack to the right
                    VStack(alignment: .leading) {
                        HStack {
                            Circle()
                                .fill(Color.green)
                                .frame(width: 10, height: 10)
                            Text("Ganados")
                                .font(.system(size: 20))
                                .fontWeight(.bold)
                                .foregroundColor(.gray)
                            Spacer() // Pushes the next element to the right
                            Text(wins.description)
                                .font(.system(size: 20))
                                .fontWeight(.bold)
                                .foregroundColor(.white)
                        }
                        
                        Divider()
                            .frame(height: 0.2)
                            .background(Color.gray)
                        
                        HStack {
                            Circle()
                                .fill(Color.orange)
                                .frame(width: 10, height: 10)
                            Text("Perdidos")
                                .font(.system(size: 20))
                                .fontWeight(.bold)
                                .foregroundColor(.gray)
                            Spacer() // Pushes the next element to the right
                            Text(losses.description)
                                .font(.system(size: 20))
                                .fontWeight(.bold)
                                .foregroundColor(.white)
                        }
                        
                        Divider()
                            .frame(height: 0.2)
                            .background(Color.gray)
                        
                        HStack {
                            Circle()
                                .fill(Color.white)
                                .frame(width: 10, height: 10)
                            Text("Empatados")
                                .font(.system(size: 20))
                                .fontWeight(.bold)
                                .foregroundColor(.gray)
                            Spacer() // Pushes the next element to the right
                            Text(draws.description)
                                .font(.system(size: 20))
                                .fontWeight(.bold)
                                .foregroundColor(.white)
                        }
                    }
                }
                .padding()
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .background(Color(white: 0, opacity: 0.2))
                .background(Color(red: 103/255, green: 65/255, blue: 153/255))
                
                // Stats Grid
                LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible()), GridItem(.flexible())], spacing: 20) {
                    StatItem(value: "\(minutes)", label: "MINUTES")
                    StatItem(value: "\(points)", label: "POINTS")
                    StatItem(value: String(format: "%.0f", fgPercentage) + "%", label: "FG%")
                    StatItem(value: "\(rebounds)", label: "REBOUNDS")
                    StatItem(value: String(format: "%.1f", assists), label: "ASSISTS")
                    StatItem(value: String(format: "%.1f", steals), label: "STEALS")
                }
                .padding()
                .background(Color(red: 103/255, green: 65/255, blue: 153/255))
                
                Spacer()
                
                
                
                
            }
            .navigationTitle(playerName)
            .navigationBarTitleDisplayMode(.inline)
            .toolbarBackground(Color(red: 103/255, green: 65/255, blue: 153/255), for: .navigationBar)
            //.toolbar(.hidden, for: .scrollContent)
            
            //.navigationBarBackButtonHidden(true)
            
        }
        .background(Color(red: 103/255, green: 65/255, blue: 153/255))
        
        
    }
}




#Preview {
    PlayerProfileView(
        playerName: "David Rodriguez",
        position: "Forward",
        team: "Cali",
        place: 10,
        minutes: 30,
        points: 25,
        fgPercentage: 48.5,
        rebounds: 8,
        assists: 4.2,
        steals: 1.1,
        image: Image("david") // Make sure "david" exists in your assets
    )
}

