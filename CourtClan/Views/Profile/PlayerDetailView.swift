import SwiftUI

struct PlayerDetailView: View {
    let player: Player
    let playerName: String = ""
    let position: String = ""
    let team: String = ""
    let place: Int = 5
    let minutes: Int = 5
    let points: Int = 5
    let fgPercentage: Double = 0.5
    let rebounds: Int = 5
    let assists: Double = 0.5
    let steals: Double = 0.5
    let image: Image = Image("hanny")
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
        
        
        /*List {
         Section {
         ZStack(alignment: .topLeading) {
         image
         .resizable()
         .scaledToFill()
         .frame(maxWidth: .infinity, maxHeight: 320)
         .clipped()
         
         HStack (alignment: .center){
         Text("NBA PLAYOFFS")
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
         .background(Color(white: 0, opacity: 0.2))
         }
         .background(Color(red: 103/255, green: 65/255, blue: 153/255))
         .listRowInsets(EdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 0)) // 2 points bottom
         .listSectionSeparator(.hidden)
         
         
         Section(header: Text("Statistics")){
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
         .cornerRadius(10)
         
         }
         .listRowInsets(EdgeInsets(top: 2, leading: 0, bottom: 0, trailing: 0)) // 2 points top
         .listSectionSeparator(.hidden)
         }
         .navigationTitle(playerName)*/
        ScrollView {
            VStack(spacing: 0) { // Added VStack to stack the elements vertically
                ZStack(alignment: .topLeading) {
                    if let profileUrl = player.profilePictureUrl, let url = URL(string: profileUrl) {
                        AsyncImage(url: url) { image in
                            image
                                .resizable()
                                .scaledToFit()
                                .frame(maxWidth: .infinity, maxHeight: 220)
                                .clipped()
                        } placeholder: {
                            ProgressView()
                                .frame(maxWidth: .infinity, maxHeight: 220)
                                .clipShape(Circle())
                                .background(Color.gray.opacity(0.2))
                        }
                        .padding(.trailing, 5)
                    } else {
                        Image(systemName: "person.fill")
                            .resizable()
                            .scaledToFit()
                            .frame(maxWidth: .infinity, maxHeight: 220)
                            .foregroundColor(.black)
                            .clipShape(Circle())
                            .background(Color.gray.opacity(0.2))
                            .padding(.trailing, 5)
                    }
                    
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
                        Text("\(player.currentLevel)")
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
                        Text(player.username.uppercased())
                            .font(.headline)
                            .fontWeight(.bold)
                            .foregroundColor(.white)
                        
                        Text("\(player.preferredPosition?.uppercased() ?? "Agente Libre") | \(player.team?.name.uppercased() ?? "AL")")
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

struct StatItem: View {
    let value: String
    let label: String

    var body: some View {
        VStack {
            Text(value)
                .font(.title2)
                .fontWeight(.bold)
                .foregroundColor(.white)
            Text(label)
                .font(.caption)
                .foregroundColor(.gray)
        }
        .frame(maxWidth: .infinity)
    }
}



#Preview {
    // Create a sample Player object for the preview
    let samplePlayer = Player(
        id: UUID().uuidString,
        username: "johndoe",
        email: "john@example.com",
        fullName: "Juan Pérez",
        bio: "Experienced player looking for competitive games.",
        profilePictureUrl: nil, // Or provide a URL if you use AsyncImage
        location: "Barcelona",
        dateOfBirth: Date(),
        gender: "Male",
        preferredPosition: "Base",
        skillLevelId: UUID().uuidString,
        currentLevel: 10,
        totalXp: 5000,
        gamesPlayed: 100,
        gamesWon: 70,
        winPercentage: 0.70, // 70% win rate
        avgPointsPerGame: 25.5,
        avgAssistsPerGame: 7.2,
        avgReboundsPerGame: 6.8,
        avgBlocksPerGame: 1.5,
        avgStealsPerGame: 2.1,
        isPublic: true,
        isActive: true,
        currentTeamId: nil, // Or a mock team ID if you have a Team object
        marketValue: 150000.0,
        isFreeAgent: true,
        lastLogin: Date(),
        createdAt: Date(),
        updatedAt: Date(),
        team: nil // Or a mock Team object if you have one
    )

    // Pass the sample player to PlayerDetailView
    PlayerDetailView(player: samplePlayer)
}
