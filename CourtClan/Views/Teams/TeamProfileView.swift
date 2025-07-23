//
//  TeamProfileView.swift
//  CourtClan
//
//  Created by Isain Rodriguez Noreña on 16/7/25.
//

import SwiftUI

struct TeamProfileView: View {
    
    let playerName: String = "isain"
    let position: String = "kjbxjhas"
    let team: String = ""
    let place: Int = 10
    let minutes: Int = 4
    let points: Int = 9
    let fgPercentage: Double = 2.9
    let rebounds: Int = 0
    let assists: Double = 0
    let steals: Double = 0
    let image  = Image("logo2cc")
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
    
    @State var teamSelected:Team2?
    @State var imageHeigth = 100
    @State var imageWidth = 100
    
    @Environment(\.dismiss) var dismiss // Declara la variable dismiss
    @EnvironmentObject var appData: AppData
    
    @State var showGameList:Bool = false
    
    
    var body: some View {
        ScrollView {
            VStack(spacing: 0) { // Added VStack to stack the elements vertically
                ZStack(alignment: .topLeading) {
                    HStack{
                        
                        if let logoUrl = teamSelected?.logoURL, let url = URL(string: logoUrl) {
                            AsyncImage(url: url) { image in
                                image
                                    .resizable()
                                    .scaledToFill()
                                    .frame(width: CGFloat(imageWidth), height: CGFloat(imageHeigth))
                                    .clipShape(Circle())
                            } placeholder: {
                                ProgressView()
                                    .frame(width: CGFloat(imageWidth), height: CGFloat(imageHeigth))
                                    .clipShape(Circle())
                                    .background(Color.gray.opacity(0.2))
                            }
                            .padding(.trailing, 5)
                        } else {
                            Image(systemName: "person.3.fill")
                                .resizable()
                                .scaledToFit()
                                .frame(width: CGFloat(imageWidth), height: CGFloat(imageHeigth))
                                .foregroundColor(.blue)
                                .clipShape(Circle())
                                .background(Color.gray.opacity(0.2))
                                .padding(.trailing, 5)
                        }
                        Spacer()
                    }
                    .padding(.horizontal)
                    
                }
                
                HStack {
                    /*VStack(alignment: .center) {
                        Text("\(place)")
                            .font(.largeTitle)
                            .fontWeight(.bold)
                            .foregroundColor(.white)
                        Text("PLACE")
                            .font(.caption)
                            .foregroundColor(.gray)
                    }
                    .frame(width: 80)*/
                    /*Divider()
                        .frame(height: 30)
                        .background(Color.gray)*/
                    VStack(alignment: .leading) {
                        Text(teamSelected?.name.uppercased() ?? "not name")
                            .font(.headline)
                            .fontWeight(.bold)
                            .foregroundColor(.white)
                        Text("\(teamSelected?.description ?? "not info")")
                            .font(.caption)
                            .foregroundColor(.gray)
                    }
                    Spacer()
                    
                }
                .padding()
                //.background(Color(white: 0, opacity: 0.2))
                .background(Color(red: 103/255, green: 65/255, blue: 153/255))
                
                VStack(spacing: 20) { // Añadimos un espaciado entre el botón y los Spacers
                    // Empuja el botón hacia el centro verticalmente
                    
                    
                    
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                //.background(Color(white: 0.1)) // Fondo oscuro para contrastar
                
                //.background(Color(white: 0, opacity: 0.2))
                .background(Color(red: 103/255, green: 65/255, blue: 153/255))
                
                //PlayersCollection()
                
                HStack() {
                    Text("Listas")
                        .font(.system(size: 20))
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                        .padding(.horizontal)
                    Spacer()
                    
                    
                }
                Button {
                    showGameList = true
                } label: {
                    Text("ir a teamgames")
                        .font(.system(size: 20))
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                        .padding(.horizontal)
                }
                /*HStack{
                    
                    Text("Datos")
                        .font(.system(size: 20))
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                    Spacer()
                    
                }
                .padding()
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .background(Color(white: 0, opacity: 0.2))
                .background(Color(red: 103/255, green: 65/255, blue: 153/255))*/
                
                
                /*HStack (spacing: 8){
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
                .background(Color(red: 103/255, green: 65/255, blue: 153/255))*/
                
                // Stats Grid
                /*
                LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible()), GridItem(.flexible())], spacing: 20) {
                    StatItem(value: "\(minutes)", label: "MINUTES")
                    StatItem(value: "\(points)", label: "POINTS")
                    StatItem(value: String(format: "%.0f", fgPercentage) + "%", label: "FG%")
                    StatItem(value: "\(rebounds)", label: "REBOUNDS")
                    StatItem(value: String(format: "%.1f", assists), label: "ASSISTS")
                    StatItem(value: String(format: "%.1f", steals), label: "STEALS")
                }
                .padding()
                .background(Color(red: 103/255, green: 65/255, blue: 153/255))*/
                
                Spacer()
                
                
                
                
            }
            .navigationTitle("")
            .navigationBarTitleDisplayMode(.inline)
            .toolbarBackground(Color(red: 103/255, green: 65/255, blue: 153/255), for: .navigationBar)
            .navigationBarBackButtonHidden(true)
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
            .fullScreenCover(isPresented: $showGameList){
                TeamGamesView()
            }
            //.toolbar(.hidden, for: .scrollContent)
            
            //.navigationBarBackButtonHidden(true)
            
        }
        .background(Color(red: 103/255, green: 65/255, blue: 153/255))
    }
}

#Preview {
    TeamProfileView()
}
