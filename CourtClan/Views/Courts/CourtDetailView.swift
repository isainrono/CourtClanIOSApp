//
//  CourtDetailView.swift
//  CourtClan
//
//  Created by Isain Rodriguez Noreña on 11/6/25.
//

import SwiftUI
import MapKit // Necesario para el mapa

// MARK: - CourtDetailView
struct CourtDetailView: View {
    let court: Court
    @Environment(\.dismiss) var dismiss // Para cerrar el sheet
    
    // Convertir latitud y longitud a CLLocationCoordinate2D
    private var coordinate: CLLocationCoordinate2D? {
        guard let lat = Double(court.latitude),
              let lon = Double(court.longitude) else {
            return nil
        }
        return CLLocationCoordinate2D(latitude: lat, longitude: lon)
    }

    var body: some View {
        // Usamos un NavigationView para la barra de navegación dentro del sheet
        NavigationView {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    // --- Sección del Mapa ---
                    VStack(alignment: .leading, spacing: 8) {
                        Label("Ubicación", systemImage: "map.fill")
                            .font(.headline)
                            .foregroundColor(.brown)
                        
                        if let coordinate = coordinate {
                            Map(initialPosition: .region(MKCoordinateRegion(center: coordinate, span: MKCoordinateSpan(latitudeDelta: 0.005, longitudeDelta: 0.005)))) {
                                Marker(court.name, coordinate: coordinate)
                            }
                            .frame(height: 250)
                            .cornerRadius(20)
                            .shadow(radius: 5)
                        } else {
                            Text("Ubicación no disponible.")
                                .foregroundColor(.red)
                        }
                    }
                    .padding(.horizontal)

                    Spacer()
                    
                    

                    // --- Información Principal ---
                    VStack(alignment: .leading, spacing: 8) {
                        Text(court.name)
                            .font(.largeTitle)
                            .fontWeight(.heavy)
                            .foregroundColor(.primary)

                        Text(court.address)
                            .font(.title2)
                            .foregroundColor(.secondary)
                        
                        Divider()
                    }
                    .padding(.horizontal)

                    // --- Descripción ---
                    VStack(alignment: .leading, spacing: 8) {
                        Label("Acerca de la cancha", systemImage: "info.circle.fill")
                            .font(.headline)
                            .foregroundColor(.blue)
                        Text(court.description)
                            .font(.body)
                            .lineLimit(nil) // Permite múltiples líneas
                    }
                    .padding(.horizontal)
                    
                    // --- Características (Iconos Divertidos) ---
                    VStack(alignment: .leading, spacing: 8) {
                        Label("Equipamiento", systemImage: "bolt.fill")
                            .font(.headline)
                            .foregroundColor(.orange)
                        
                        HStack(spacing: 15) {
                            FeatureBadge(icon: "basketball.fill", text: "Aro", isActive: court.hasHoop, color: .orange)
                            FeatureBadge(icon: "tennisball.fill", text: "Red", isActive: court.hasNet, color: .green)
                            FeatureBadge(icon: "lightbulb.fill", text: "Luces", isActive: court.hasLights, color: .yellow)
                        }
                    }
                    .padding(.horizontal)

                    // --- Tipo de Cancha / Acceso ---
                    VStack(alignment: .leading, spacing: 8) {
                        Label("Disponibilidad", systemImage: "calendar.badge.clock")
                            .font(.headline)
                            .foregroundColor(.purple)
                        
                        HStack {
                            Text(court.isPublic ? "Pública" : "Privada")
                                .font(.subheadline)
                                .fontWeight(.semibold)
                                .padding(.horizontal, 10)
                                .padding(.vertical, 5)
                                .background(Capsule().fill(court.isPublic ? Color.blue.opacity(0.2) : Color.red.opacity(0.2)))
                                .foregroundColor(court.isPublic ? .blue : .red)
                            Spacer()
                            Text(court.availabilityNotes)
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                        }
                    }
                    .padding(.horizontal)
                    
                    // --- Sección de Imágenes (Carrusel) ---
                    if !court.picturesUrls.isEmpty {
                        TabView {
                            ForEach(court.picturesUrls, id: \.self) { urlString in
                                AsyncImage(url: URL(string: urlString)) { phase in
                                    switch phase {
                                    case .empty:
                                        ProgressView()
                                            .frame(height: 250)
                                            .frame(maxWidth: .infinity)
                                            .background(Color.gray.opacity(0.1))
                                            .cornerRadius(15)
                                    case .success(let image):
                                        image
                                            .resizable()
                                            .scaledToFill()
                                    case .failure:
                                        Image(systemName: "photo.fill")
                                            .resizable()
                                            .scaledToFit()
                                            .frame(height: 150)
                                            .foregroundColor(.gray)
                                            .frame(maxWidth: .infinity)
                                            .background(Color.gray.opacity(0.1))
                                            .cornerRadius(15)
                                    @unknown default:
                                        EmptyView()
                                    }
                                }
                                .clipped()
                            }
                        }
                        .tabViewStyle(.page(indexDisplayMode: .always))
                        .frame(height: 250)
                        .cornerRadius(20)
                        .shadow(radius: 5)
                        .padding(.horizontal)
                    } else {
                        // Placeholder si no hay imágenes
                        Image(systemName: "sportscourt.fill")
                            .resizable()
                            .scaledToFit()
                            .frame(height: 150)
                            .foregroundColor(.gray.opacity(0.6))
                            .frame(maxWidth: .infinity)
                            .background(Color.gray.opacity(0.1))
                            .cornerRadius(20)
                            .padding(.horizontal)
                    }
                    
                    
                }
                .padding(.vertical)
            }
            .navigationTitle("Detalles de la Cancha")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        dismiss() // Cierra el sheet
                    } label: {
                        Image(systemName: "xmark.circle.fill")
                            .font(.title2)
                            .foregroundColor(.gray)
                    }
                }
                // Si tienes un `ownerId` y quieres un botón para contactar al dueño
                // ToolbarItem(placement: .navigationBarLeading) {
                //     if court.ownerId != nil {
                //         Button("Contactar") {
                //             // Acción para contactar al dueño
                //             print("Contactando al dueño de \(court.name)")
                //         }
                //     }
                // }
            }
        }
    }
}

// MARK: - Sub-Vista para los Badges de Características (Ayuda a la legibilidad y reusabilidad)
struct FeatureBadge: View {
    let icon: String
    let text: String
    let isActive: Bool
    let color: Color
    
    var body: some View {
        HStack {
            Image(systemName: icon)
                .foregroundColor(isActive ? color : .gray)
            Text(text)
                .foregroundColor(isActive ? .primary : .gray)
        }
        .font(.callout)
        .padding(.horizontal, 10)
        .padding(.vertical, 5)
        .background(Capsule().fill(isActive ? color.opacity(0.15) : Color.gray.opacity(0.1)))
        .overlay(
            Capsule()
                .stroke(isActive ? color : .gray.opacity(0.3), lineWidth: 1)
        )
    }
}

// MARK: - Preview para CourtDetailView
#Preview {
    CourtDetailView(court: .previewCourt) // Usa tu `previewCourt` para la previsualización
}
