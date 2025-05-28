//
//  CourtsView.swift
//  CourtClan
//
//  Created by Isain Rodriguez Noreña on 21/5/25.
//

import SwiftUI

struct CourtsView: View {
    @StateObject var viewModel = CourtsViewModel() // Crea e inyecta el ViewModel en la vista
    @State private var isSearchActive: Bool = false
    @State private var searchText: String = ""
    @State private var isSearchActiveFullScreen: Bool = false
    @State private var isProfileActiveFullScreen: Bool = false
    
    var body: some View {
        NavigationStack {
            Group {
                if viewModel.isLoading {
                    ProgressView("Cargando canchas...")
                } else if let errorMessage = viewModel.errorMessage {
                    VStack {
                        Text(errorMessage)
                            .foregroundColor(.red)
                            .multilineTextAlignment(.center)
                            .padding()
                        Button("Reintentar") {
                            Task { await viewModel.fetchAllCourts() }
                        }
                    }
                } else if viewModel.courts.isEmpty {
                    ContentUnavailableView("No hay canchas disponibles", systemImage: "sportscourt")
                } else {
                    List(viewModel.courts) { court in
                        CourtRowView(court: court)
                    }
                    .navigationTitle("Canchas disponibles")
                    .toolbar{
                        ToolbarItem(placement: .navigationBarLeading){
                            
                            Button {
                                isProfileActiveFullScreen = true
                            } label: {
                                ProfileView(imageName: "hanny", circleSize: 35, imageSize: 30, shouldAnimateBorder: false)
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
            .task { // Se ejecuta cuando la vista aparece por primera vez
                await viewModel.fetchAllCourts()
            }
            // Puedes usar .alert para mostrar errores específicos si prefieres un popup
            .alert("Error", isPresented: Binding(get: { viewModel.errorMessage != nil }, set: { _ in viewModel.errorMessage = nil })) {
                Button("OK") { }
            } message: {
                Text(viewModel.errorMessage ?? "Ha ocurrido un error desconocido.")
            }
        }
    }
}

// MARK: - CourtRowView (Elemento de la lista)
struct CourtRowView: View {
    let court: Court
    @State private var currentPage = 0
    
    var body: some View {
        NavigationLink{}label: {
            VStack(alignment: .leading) {
                Text(court.name)
                    .font(.headline)
                Text(court.address)
                    .font(.subheadline)
                    .foregroundColor(.gray)
                Text(court.description)
                    .font(.caption)
                    .foregroundColor(.secondary)
                HStack {
                    // Características de la cancha
                    if court.hasHoop { Text("🏀 Canasta") }
                    if court.hasNet { Text(" नेट Red") }
                    if court.hasLights { Text("💡 Luces") }
                    Spacer()
                    // Es pública / privada
                    Image(systemName: court.isPublic ? "eye.fill" : "lock.fill")
                        .foregroundColor(court.isPublic ? .green : .red)
                    Text(court.isPublic ? "Pública" : "Privada")
                }
                .font(.footnote)
                .padding(.vertical, 2)
                
                Text("Notas de Disponibilidad: \(court.availabilityNotes)")
                    .font(.footnote)
                    .foregroundColor(.secondary)
                
                // Mostrar imágenes usando TabView si hay más de una
                ZStack(alignment: .bottom) { // Usamos un ZStack para superponer los puntos
                    if court.picturesUrls.count > 1 {
                        TabView(selection: $currentPage) {
                            ForEach(court.picturesUrls.indices, id: \.self) { index in
                                let urlString = court.picturesUrls[index]
                                AsyncImage(url: URL(string: urlString)) { image in
                                    image
                                        .resizable()
                                        .scaledToFill() // La imagen llena el contenedor
                                        .frame(maxWidth: .infinity, maxHeight: 200) // El contenedor tiene un máximo
                                        .clipped() // Recorta la parte de la imagen que se desborda
                                        .cornerRadius(8)
                                } placeholder: {
                                    ProgressView()
                                        .frame(maxWidth: .infinity, maxHeight: 200)
                                }
                                .tag(index)
                            }
                        }
                        .tabViewStyle(.page)
                        .frame(height: 250) // Altura del TabView
                        // Mostrar los puntos indicadores centrados
                        Spacer()
                        HStack {
                            ForEach(court.picturesUrls.indices, id: \.self) { index in
                                Circle()
                                    .fill(index == currentPage ? Color.blue : Color.gray)
                                    .frame(width: 8, height: 8)
                            }
                        }
                        .padding(.bottom, 10)
                        .frame(maxWidth: .infinity, alignment: .center) // Centrar los puntos
                    } else if let firstPicture = court.picturesUrls.first {
                        AsyncImage(url: URL(string: firstPicture)) { image in
                            image
                                .resizable()
                                .scaledToFill()
                                .frame(height: 200)
                                .cornerRadius(8)
                                .clipped()
                        } placeholder: {
                            ProgressView()
                                .frame(height: 200)
                        }
                    } else {
                        Image(systemName: "photo")
                            .resizable()
                            .scaledToFill()
                            .frame(height: 200)
                            .cornerRadius(8)
                            .foregroundColor(.gray)
                            .clipped()
                    }
                }
                .frame(height: 250) // Asegura que el ZStack tenga la misma altura que el TabView
            }
            .padding(.vertical, 4)
        }
    }
}

struct CourtsView_Previews: PreviewProvider {
    static var previews: some View {
        CourtsView()
    }
}
