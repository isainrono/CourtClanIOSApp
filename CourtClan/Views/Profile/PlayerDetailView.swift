import SwiftUI

struct PlayerDetailView: View {
    let player: Player
    // Propiedades de ejemplo, si no las obtienes de `player`
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
    
    // --- NUEVO: Estado para la animación de rotación ---
    @State private var rotationAngle: Angle = .degrees(90)
    
    var body: some View {
        VStack {
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
                    
                    // --- AÑADE ESTE CÓDIGO PARA EL DEGRADADO ---
                    Rectangle() // Un rectángulo para aplicar el degradado
                        .fill(LinearGradient(gradient: Gradient(colors: [.clear,.clear, Color(red: 103/255, green: 65/255, blue: 153/255)]),
                                             startPoint: .top,
                                             endPoint: .bottom)) // Ajusta endPoint a .center o .top según necesites
                        .frame(maxWidth: .infinity, maxHeight: 220) // Mismo tamaño que la imagen
                        .clipped() // Asegura que el degradado también se corte al mismo tamaño
                    // --- FIN DEL CÓDIGO DEL DEGRADADO ---
                    
                    HStack(alignment: .center) {
                        Spacer()
                        Image(systemName: "xmark.circle.fill")
                            .font(.title2)
                            .foregroundColor(.white.opacity(0.5))
                    }
                    .padding(.horizontal)
                    
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
                .padding(.top, 20)
                
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
                .background(Color(red: 103/255, green: 65/255, blue: 153/255))
                
                VStack(spacing: 20) {
                    Button {
                        print("Botón '1 VS 1' presionado")
                    } label: {
                        HStack(spacing: 16) {
                            Text("1")
                                .font(.largeTitle)
                                .fontWeight(.bold)
                                .foregroundColor(Color.white.opacity(0.7))
                            Text("VS")
                                .font(.headline)
                                .fontWeight(.semibold)
                                .foregroundColor(Color.white.opacity(0.7))
                            Text("1")
                                .font(.largeTitle)
                                .fontWeight(.bold)
                                .foregroundColor(Color.white.opacity(0.7))
                        }
                        .padding(.vertical, 8)
                        .frame(maxWidth: .infinity,maxHeight: 40)
                        .background(Color(red: 118/255, green: 215/255, blue: 194/255))
                        .cornerRadius(10)
                        .shadow(color: Color.black.opacity(0.2), radius: 5, x: 0, y: 2)
                    }
                    .buttonStyle(PlainButtonStyle())
                }
                .padding(.horizontal)
                .background(Color(red: 103/255, green: 65/255, blue: 153/255))
                
                HStack{
                    Text("Datos")
                        .font(.system(size: 20))
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                    Spacer()
                }
                .padding()
                .frame(maxWidth: .infinity)
                .background(Color(red: 103/255, green: 65/255, blue: 153/255))
                
                HStack (spacing: 8){
                    ZStack {
                        Circle()
                            .fill(Color.gray.opacity(0.2))
                            .frame(maxWidth: 120, maxHeight: 120)
                        
                        Circle()
                            .trim(from: 0, to: winPercentage)
                            .stroke(Color.green, style: StrokeStyle(lineWidth: 5, dash: [1,0]))
                            .frame(maxWidth: 120, maxHeight: 120)
                            .rotationEffect(.degrees(-90))
                        
                        Circle()
                            .trim(from: winPercentage, to: winPercentage + lossPercentage)
                            .stroke(Color.orange, style: StrokeStyle(lineWidth: 5, dash: [1,0]))
                            .frame(maxWidth: 120, maxHeight: 120)
                            .rotationEffect(.degrees(-90))
                        
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
                    Spacer()
                    VStack(alignment: .leading) {
                        HStack {
                            Circle()
                                .fill(Color.green)
                                .frame(width: 10, height: 10)
                            Text("Ganados")
                                .font(.system(size: 20))
                                .fontWeight(.bold)
                                .foregroundColor(.gray)
                            Spacer()
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
                            Spacer()
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
                            Spacer()
                            Text(draws.description)
                                .font(.system(size: 20))
                                .fontWeight(.bold)
                                .foregroundColor(.white)
                        }
                    }
                }
                .padding()
                .frame(maxWidth: .infinity)
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
        }
        // Aplica el fondo a la vista PlayerDetailView
        // Esto hará que toda la vista tenga este fondo.
        .background(Color(red: 103/255, green: 65/255, blue: 153/255).ignoresSafeArea()) // Fondo semi-transparente para toda la vista
        .cornerRadius(20) // Aplica el corner radius a toda la vista
        .padding(.horizontal, 20) // Mantiene el padding horizontal
        .padding(.top, 50)
        .padding(.bottom, 80) // Mantiene el padding inferior
        .rotation3DEffect(
            rotationAngle, // Usa la variable de estado
            axis: (x: 0.0, y: 1.0, z: 0.0), // Gira alrededor del eje Y (de lado a lado)
            anchor: .center, // Punto central de rotación
            perspective: 1.0 // Perspectiva para un efecto 3D
        )
        // --- NUEVO: Anima la rotación cuando la vista aparece ---
        .onAppear {
            // Anima el cambio de rotationAngle de 90 a 0 grados
            withAnimation(.spring(response: 0.7, dampingFraction: 0.7, blendDuration: 0)) {
                rotationAngle = .degrees(0) // Llega a su posición final sin rotación
            }
        }
        // Opcional: Animar la rotación inversa al desaparecer (para el descarte)
        .onDisappear {
            withAnimation(.spring(response: 0.7, dampingFraction: 0.7, blendDuration: 0)) {
                rotationAngle = .degrees(90) // Gira de nuevo al irse
            }
        }
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
