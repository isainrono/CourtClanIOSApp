//
//  CourtsViewModel.swift
//  RodMon
//
//  Created by Isain Rodriguez Noreña on 20/5/25.
//

import Foundation
import Combine
import CoreLocation

// MARK: - Courts ViewModel
class CourtsViewModel: ObservableObject {
    @Published var courts: [Court] = []
    @Published var isLoading: Bool = false
    @Published var errorMessage: String? = nil

    private let courtService: CourtService // Dependencia inyectada
    private let locationService: LocationService // Nueva dependencia para geocodificación

    init(courtService: CourtService = CourtAPIService(baseURL: "https://courtclan.com/api"),locationService: LocationService = LocationService()) {
        self.courtService = courtService
        self.locationService = locationService
    }

    @MainActor
        func fetchAllCourts() async {
            isLoading = true
            errorMessage = nil
            do {
                var fetchedCourts = try await courtService.fetchAllCourts()
                print("corts fetched: \(fetchedCourts.count)")

                // MARK: - Geocodificación de cada cancha
                // Itera sobre las canchas y geocodifica sus ubicaciones
                for i in 0..<fetchedCourts.count {
                    let court = fetchedCourts[i]
                    
                    // Intenta convertir latitude y longitude de String a CLLocationDegrees (Double)
                    guard let lat = CLLocationDegrees(court.latitude),
                          let lon = CLLocationDegrees(court.longitude) else {
                        fetchedCourts[i].cityAndNeighborhood = "Coordenadas inválidas"
                        print("Error: Coordenadas no válidas (String a Double) para cancha \(court.name)")
                        continue // Pasa a la siguiente cancha
                    }

                    // Solo geocodifica si las coordenadas son válidas y no (0,0)
                    if lat != 0.0 || lon != 0.0 {
                        do {
                            let locationString = try await locationService.getCityAndNeighborhood(
                                latitude: lat,
                                longitude: lon
                            )
                            fetchedCourts[i].cityAndNeighborhood = locationString
                        } catch {
                            print("Error geocodificando cancha \(court.name): \(error.localizedDescription)")
                            fetchedCourts[i].cityAndNeighborhood = "Ubicación desconocida"
                        }
                    } else {
                        fetchedCourts[i].cityAndNeighborhood = "Coordenadas no válidas"
                    }
                }
                self.courts = fetchedCourts // Actualiza la propiedad @Published después de la geocodificación
                print("Courts with geocoded info: \(courts.map { "\($0.name) - \($0.cityAndNeighborhood ?? "N/A")" })")

            } catch {
                self.errorMessage = (error as? APIError)?.localizedDescription ?? error.localizedDescription
                print("Error fetching all courts: \(error)")
            }
            isLoading = false
        }
    // He eliminado los métodos CRUD (create, update, delete) del ViewModel
    // ya que la vista principal que solicitaste solo es para listado.
    // Si planeas reintroducir estas funcionalidades más tarde, deberás restaurarlos.
}
