import SwiftUI

// Estructura para representar un perfil de usuario
struct UserProfile: Identifiable {
    let id = UUID()
    let name: String
    let username: String
    let profileImage: String // Nombre del asset de la imagen
    let bio: String
}

struct UserProfileDetailView: View {
    let user: UserProfile
    
    var body: some View {
        NavigationView {
            VStack(alignment: .leading, spacing: 20) {
                ProfileView(imageName: user.profileImage, circleSize: 120, imageSize: 100, shouldAnimateBorder: false)
                    .padding(.bottom)
                
                Text(user.name)
                    .font(.title)
                    .fontWeight(.bold)
                
                Text("@\(user.username)")
                    .font(.subheadline)
                    .foregroundColor(.gray)
                
                Text("Biografía:")
                    .font(.headline)
                    .padding(.top)
                
                Text(user.bio)
                    .lineLimit(nil) // Permite que la biografía se extienda en varias líneas
                
                Spacer() // Empuja el contenido hacia la parte superior
            }
            .padding()
            .navigationTitle("Perfil de \(user.name)")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}

import SwiftUI

struct UserProfileRow: View {
    let user: UserProfile
    
    var body: some View {
        NavigationLink {
            
        } label: {
            HStack {
                ProfileView(imageName: user.profileImage, circleSize: 60, imageSize: 50, shouldAnimateBorder: true)
                VStack(alignment: .leading) {
                    Text(user.name)
                        .font(.headline)
                    Text("@\(user.username)")
                        .font(.subheadline)
                        .foregroundColor(.gray)
                    Text(user.bio)
                        .font(.caption)
                        .lineLimit(2)
                }
                Spacer() // Empuja el contenido a la izquierda y el nivel a la derecha
                Text("7L") // Muestra el nivel del usuario
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundColor(.orange)
            }
            .padding(.vertical, 8)
            
        }
        .swipeActions(edge: .trailing, allowsFullSwipe: false) {
            Button {
                // Acción para el mensaje
                print("Mensaje a \(user.username)")
            } label: {
                Image(systemName: "message.fill")
            }
            .tint(.blue)
            
            Button {
                // Acción para el favorito
                print("Favorito \(user.username)")
            } label: {
                Image(systemName: "heart.fill")
            }
            .tint(.pink)
        }
    }
    
}
struct SearchBarView: View {
    @Binding var searchText: String
    var placeholder: String = "Buscar perfiles"
    
    var body: some View {
        HStack {
            Image(systemName: "magnifyingglass")
                .foregroundColor(.gray)
            TextField(placeholder, text: $searchText)
        }
        .padding(8)
        .background(Color.white) // Establece el fondo blanco aquí
        .cornerRadius(8)
    }
}

struct SearchPageView: View {
    @Binding var isPresented: Bool
    @Binding var searchText: String
    @EnvironmentObject var appData: AppData
    
    var body: some View {
        NavigationView {
            VStack {
                HStack(spacing:20) {
                    SearchBarView(searchText: $searchText, placeholder: "Buscar jugador")
                        .frame(width: 280)
                    
                    Button("Cancelar") {
                        isPresented = false
                    }
                    .tint(Color.black)
                }
                .padding()
                List {
                    Text("Resultados de búsqueda para: \(searchText)")
                    // Aquí irían los resultados de la búsqueda
                        .listRowBackground(appData.appColor)
                }
                .listStyle(PlainListStyle())
                .background(appData.appColor)
            }
            .background(appData.appColor)
            .navigationBarHidden(true) // Oculta la barra de navegación por defecto de la NavigationView
        }
        
    }
}



struct HomeView: View {
    
    @EnvironmentObject var appData: AppData
    @State private var isSearchActive: Bool = false
    @State private var searchText: String = ""
    @State private var isSearchActiveFullScreen: Bool = false
    @State private var isProfileActiveFullScreen: Bool = false
    // Datos de ejemplo para 20 perfiles de usuario
    @State private var userProfiles: [UserProfile] = [
        UserProfile(name: "Alice Smith", username: "alices", profileImage: "hanny", bio: "Loves coding and coffee."),
        UserProfile(name: "Bob Johnson", username: "bobj", profileImage: "hanny", bio: "Travel enthusiast and photographer."),
        UserProfile(name: "Charlie Brown", username: "charlieb", profileImage: "hanny", bio: "Aspiring musician and artist."),
        UserProfile(name: "Diana Lee", username: "dianal", profileImage: "hanny", bio: "Foodie and adventure seeker."),
        UserProfile(name: "Ethan Davis", username: "ethand", profileImage: "hanny", bio: "Gamer and tech geek."),
        UserProfile(name: "Fiona Green", username: "fionag", profileImage: "hanny", bio: "Bookworm and nature lover."),
        UserProfile(name: "George Harris", username: "georgeh", profileImage: "profile7", bio: "Sports fan and fitness enthusiast."),
        UserProfile(name: "Hannah Clark", username: "hannahc", profileImage: "profile8", bio: "Writer and animal lover."),
        UserProfile(name: "Ian White", username: "ianw", profileImage: "profile9", bio: "Film buff and storyteller."),
        UserProfile(name: "Julia Adams", username: "juliaa", profileImage: "profile10", bio: "Dancer and yoga instructor."),
        UserProfile(name: "Kevin Baker", username: "kevinb", profileImage: "profile11", bio: "Entrepreneur and innovator."),
        UserProfile(name: "Laura Carter", username: "laurac", profileImage: "profile12", bio: "Designer and minimalist."),
        UserProfile(name: "Michael Evans", username: "michaele", profileImage: "profile13", bio: "Engineer and problem solver."),
        UserProfile(name: "Nancy Foster", username: "nancyf", profileImage: "profile14", bio: "Teacher and community volunteer."),
        UserProfile(name: "Oliver Gray", username: "oliverg", profileImage: "profile15", bio: "Developer and open-source contributor."),
        UserProfile(name: "Patricia Hill", username: "patriciah", profileImage: "profile16", bio: "Scientist and researcher."),
        UserProfile(name: "Quentin Irwin", username: "quentini", profileImage: "profile17", bio: "Musician and sound engineer."),
        UserProfile(name: "Rachel Jones", username: "rachelj", profileImage: "profile18", bio: "Artist and gallery owner."),
        UserProfile(name: "Samuel Moore", username: "samuelm", profileImage: "profile19", bio: "Chef and culinary expert."),
        UserProfile(name: "Theresa Nelson", username: "theresan", profileImage: "profile20", bio: "Gardener and environmentalist.")
    ]
    
    var body: some View {
        NavigationView {
            List {
                ForEach(userProfiles) { user in
                    UserProfileRow(user: user)
                    
                }
            }
            .navigationTitle("Perfiles de Usuario")
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading){
                    
                    Button {
                        isProfileActiveFullScreen = true
                    } label: {
                        ProfileView(imageName: "hanny", circleSize: 20, imageSize: 35, shouldAnimateBorder: false)
                    }
                    .buttonStyle(PlainButtonStyle())
                    
                    
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        isSearchActive = true
                        isSearchActiveFullScreen = true
                    } label: {
                        Image(systemName: "magnifyingglass")
                            .foregroundColor(Color(red: 2/255, green: 129/255, blue: 138/255))
                    }
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        // Acción para el icono de favoritos a la izquierda
                        print("Favoritos pulsado")
                    } label: {
                        Image(systemName: "star")
                            .foregroundColor(appData.appColor)
                    }
                }
            }
            .fullScreenCover(isPresented: $isSearchActiveFullScreen) {
                ZStack {
                    // Fondo borroso
                    Color.black.opacity(0.6)
                        .ignoresSafeArea()
                        .blur(radius: 20)
                    
                    // Contenido de la vista de búsqueda a pantalla completa
                    SearchPageView(isPresented: $isSearchActiveFullScreen, searchText: $searchText)
                }
                .transition(.move(edge: .bottom).combined(with: .opacity))
            }
            .fullScreenCover(isPresented: $isProfileActiveFullScreen) {
                ProfilePageView(isPresented: $isProfileActiveFullScreen)
            }
        }
        
    }
}

#Preview {
    TabBarView()
        .environmentObject(AppData())
}
