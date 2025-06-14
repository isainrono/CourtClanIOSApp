//
//  CourtProfileView.swift
//  CourtClan
//
//  Created by Isain Rodriguez Noreña on 10/6/25.
//

import SwiftUI

struct MyCourtsView: View {
    
    // Asume que CourtServiceProtocol y MockCourtService están definidos
    @StateObject var courtsViewModel = CourtsViewModel()
    
    var body: some View {
        // Asegúrate de que tu vista esté dentro de un NavigationView o NavigationStack
                         // para que los items de la toolbar funcionen y la vista tenga un contexto de navegación.
            VStack(alignment: .leading, spacing: 20) {
                
                // MARK: - Sección "My Courts"
                VStack(alignment: .leading, spacing: 20) {
                    Text("My Courts")
                        .font(.title2)
                        .fontWeight(.bold)

                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.leading, 0)
                .padding(.trailing, 0)
                
                // MARK: - Contenido Dinámico (Cargando, Error, o Lista de Canchas)
                if courtsViewModel.isLoading {
                    ProgressView("Cargando canchas...")
                        .frame(maxWidth: .infinity, maxHeight: .infinity) // Ocupa espacio para que se vea
                } else if let errorMessage = courtsViewModel.errorMessage {
                    Text("Error: \(errorMessage)")
                        .foregroundColor(.red)
                        .padding()
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                } else if courtsViewModel.courts.isEmpty {
                    Text("No hay canchas disponibles.")
                        .foregroundColor(.gray)
                        .padding()
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                } else {
                    CourtCardRowView(courts: courtsViewModel.courts){ court in
                        // Este código se ejecutará cuando se "simule" que se selecciona una cancha en el preview
                        print("Cancha seleccionada en el preview: \(court.name)")
                        // En un entorno real, aquí podrías actualizar un @State para mostrar un sheet, etc.
                    }
                }
                
            }
            .padding(.horizontal) // Padding horizontal para toda la VStack principal
            .onAppear {
                Task {
                    print("CourtProfileView: onAppear - fetching courts...")
                    await courtsViewModel.fetchAllCourts()
                    print("CourtProfileView: fetchAllCourts completed. Courts count: \(courtsViewModel.courts.count)")
                }
            }
            .toolbar {
                // ... tus ToolbarItems ...
            }
         // Fin de NavigationView
    }
}

#Preview {
    MyCourtsView()
}
