//
//  LocationService.swift
//  CourtClan
//
//  Created by Isain Rodriguez Noreña on 3/7/25.
//

import Foundation
import CoreLocation // Necesario para CLLocation y CLGeocoder
import MapKit // A menudo útil para ubicaciones, aunque no estrictamente necesario para esta función

// MARK: - LocationService
// Una clase para encapsular la lógica de geocodificación.
class LocationService {

    private let geocoder = CLGeocoder()

    /// Realiza geocodificación inversa para obtener el nombre de la ciudad y el barrio
    /// a partir de una latitud y longitud dadas.
    /// - Parameters:
    ///   - latitude: La latitud de la ubicación.
    ///   - longitude: La longitud de la ubicación.
    /// - Returns: Un String que contiene el nombre de la ciudad y el barrio (ej: "Barcelona, Eixample"),
    ///            o un mensaje de error si no se puede determinar.
    /// - Throws: Un error si la geocodificación falla.
    func getCityAndNeighborhood(latitude: CLLocationDegrees, longitude: CLLocationDegrees) async throws -> String {
        let location = CLLocation(latitude: latitude, longitude: longitude)

        do {
            // Realiza la geocodificación inversa
            let placemarks = try await geocoder.reverseGeocodeLocation(location)

            // Verifica si se encontraron marcadores de lugar
            guard let placemark = placemarks.first else {
                throw LocationError.notFound // No se encontraron resultados
            }

            // Extrae el nombre de la ciudad y el sub-barrio (vecindario)
            let city = placemark.locality // Ciudad (ej: "Barcelona")
            let neighborhood = placemark.subLocality // Barrio/Sub-localidad (ej: "Eixample")

            var locationString = ""
            if let city = city {
                locationString += city
            }
            if let neighborhood = neighborhood {
                if !locationString.isEmpty {
                    locationString += ", "
                }
                locationString += neighborhood
            }

            // Si no se pudo obtener ni la ciudad ni el barrio, lanza un error
            if locationString.isEmpty {
                throw LocationError.notFound // No se pudo extraer información relevante
            }

            return locationString

        } catch {
            // Maneja los errores específicos de CLGeocoder
            if let clError = error as? CLError {
                switch clError.code {
                case .network:
                    throw LocationError.networkError // Problema de red
                case .geocodeFoundNoResult:
                    throw LocationError.notFound // No se encontraron resultados para la ubicación
                case .geocodeCanceled:
                    throw LocationError.canceled // Operación cancelada
                default:
                    throw LocationError.geocodingFailed(clError.localizedDescription) // Otro error de geocodificación
                }
            } else {
                throw LocationError.geocodingFailed(error.localizedDescription) // Otros errores
            }
        }
    }

    // MARK: - Custom Error Type
    enum LocationError: Error, LocalizedError {
        case notFound
        case networkError
        case canceled
        case geocodingFailed(String)
        case unknown

        var errorDescription: String? {
            switch self {
            case .notFound:
                return "No se pudo encontrar la ciudad y el barrio para esta ubicación."
            case .networkError:
                return "Error de red al intentar obtener la ubicación. Verifica tu conexión."
            case .canceled:
                return "La operación de geocodificación fue cancelada."
            case .geocodingFailed(let message):
                return "Fallo en la geocodificación: \(message)"
            case .unknown:
                return "Ocurrió un error desconocido al obtener la ubicación."
            }
        }
    }
}
