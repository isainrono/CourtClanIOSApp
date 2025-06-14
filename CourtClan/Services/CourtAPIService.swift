//
//  CourtAPIService.swift
//  RodMon
//
//  Created by Isain Rodriguez Noreña on 20/5/25.
//

import Foundation

// MARK: - Errores Personalizados
enum APIError: Error, LocalizedError {
    case invalidURL
    case invalidResponse
    case decodingError(Error)
    case apiError(String, Int) // mensaje de error de la API y código de estado
    case unauthorized // Para código de estado 401
    case notFound // Para código de estado 404 (recurso no encontrado)
    case requestFailed(Int) // Para otros códigos de estado de error genéricos (ej. 400, 500)
    case unknown(Error)

    var errorDescription: String? {
        // ... (your errorDescription implementation) ...
        switch self {
        case .invalidURL:
            return "La URL de la API es inválida. Por favor, verifica la configuración."
        case .invalidResponse:
            return "Respuesta inválida del servidor."
        case .decodingError(let error):
            return "Error al decodificar los datos: \(error.localizedDescription)"
        case .apiError(let message, let statusCode):
            return "Error de la API (\(statusCode)): \(message)"
        case .unauthorized:
            return "No autorizado. Tu sesión ha expirado o no tienes permisos. Por favor, inicia sesión de nuevo."
        case .notFound:
            return "El recurso solicitado no fue encontrado."
        case .requestFailed(let statusCode):
            return "La solicitud al servidor falló con el código de estado: \(statusCode). Por favor, inténtalo de nuevo."
        case .unknown(let error):
            return "Ocurrió un error inesperado: \(error.localizedDescription)"
        }
    }

    // Un initializer para convertir HTTPURLResponse en un APIError
    static func from(httpResponse: HTTPURLResponse, data: Data?) -> APIError? {
        if !(200...299).contains(httpResponse.statusCode) {
            let decoder = JSONDecoder()
            // Intenta decodificar un mensaje de error si está disponible en la respuesta de la API
            if let responseData = data, let apiErrorResponse = try? decoder.decode(APIErrorMessage.self, from: responseData) {
                return .apiError(apiErrorResponse.message, httpResponse.statusCode)
            } else {
                // Si no hay un mensaje de error específico de la API, usa los casos genéricos
                switch httpResponse.statusCode {
                case 401: return .unauthorized
                case 404: return .notFound
                default: return .requestFailed(httpResponse.statusCode)
                }
            }
        }
        return nil
    }
}

// Define APIErrorMessage at the top level of the file, or at least outside of `PlayerAPIService`
// but in the same file where APIError is defined.
// Using 'fileprivate' makes it accessible within this file but not outside it.
fileprivate struct APIErrorMessage: Decodable {
    let message: String
}
// MARK: - Contratos para el Servicio
protocol CourtService {
    func fetchAllCourts() async throws -> [Court]
    func fetchCourt(id: String) async throws -> Court
    func createCourt(court: Court) async throws -> Court
    func updateCourt(id: String, court: Court) async throws -> Court
    func deleteCourt(id: String) async throws
}

// MARK: - Implementación del Servicio de API
class CourtAPIService: CourtService {
    private let baseURL: String
    private let session: URLSession

    // Un formateador de fechas para el formato "H:i"
    private lazy var timeFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "H:i"
        formatter.timeZone = TimeZone.current // O un TimeZone específico si tu API lo requiere
        formatter.locale = Locale(identifier: "es_ES") // Asegura la localización correcta
        return formatter
    }()

    init(baseURL: String, session: URLSession = .shared) {
        self.baseURL = baseURL
        self.session = session
    }

    private func performRequest<T: Decodable>(url: URL, method: String, body: Data? = nil) async throws -> T {
        var request = URLRequest(url: url)
        request.httpMethod = method
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        if let body = body {
            request.httpBody = body
        }

        let (data, response) = try await session.data(for: request)

        guard let httpResponse = response as? HTTPURLResponse else {
            throw APIError.invalidResponse
        }

        // Manejo de errores de la API (códigos de estado HTTP)
        if !(200...299).contains(httpResponse.statusCode) {
            // Intenta decodificar un mensaje de error de la API
            if let apiErrorResponse = try? JSONDecoder().decode([String: [String]].self, from: data),
               let errors = apiErrorResponse["error"], !errors.isEmpty {
                let errorMessage = errors.joined(separator: ", ")
                throw APIError.apiError(errorMessage, httpResponse.statusCode)
            } else if let apiErrorMessage = try? JSONDecoder().decode([String: String].self, from: data),
                      let message = apiErrorMessage["message"] {
                throw APIError.apiError(message, httpResponse.statusCode)
            } else {
                throw APIError.apiError("Error desconocido del servidor", httpResponse.statusCode)
            }
        }

        do {
            let decoder = JSONDecoder()
            // Configura el decodificador para el formato de fechas "H:i" si es necesario a nivel general
            // (aunque en Court ya lo manejamos con Decodable, esto es un buen lugar para otras fechas)
            // decoder.dateDecodingStrategy = .formatted(timeFormatter) // Ejemplo si usaras fechas completas aquí

            return try decoder.decode(T.self, from: data)
        } catch {
            print("Decoding Error: \(error)")
            throw APIError.decodingError(error)
        }
    }

    // MARK: - CRUD Operations

    func fetchAllCourts() async throws -> [Court] {
        guard let url = URL(string: "\(baseURL)/courts") else {
            throw APIError.invalidURL
        }
        let response: [String: [Court]] = try await performRequest(url: url, method: "GET")
        // La API devuelve un diccionario con la clave 'courts'
        guard let courts = response["courts"] else {
            throw APIError.decodingError(NSError(domain: "", code: 0, userInfo: [NSLocalizedDescriptionKey: "Missing 'courts' key in response"]))
        }
        return courts
    }

    func fetchCourt(id: String) async throws -> Court {
        guard let url = URL(string: "\(baseURL)/courts/\(id)") else {
            throw APIError.invalidURL
        }
        let response: [String: Court] = try await performRequest(url: url, method: "GET")
        // La API devuelve un diccionario con la clave 'court'
        guard let court = response["court"] else {
            throw APIError.decodingError(NSError(domain: "", code: 0, userInfo: [NSLocalizedDescriptionKey: "Missing 'court' key in response"]))
        }
        return court
    }

    func createCourt(court: Court) async throws -> Court {
        guard let url = URL(string: "\(baseURL)/courts") else {
            throw APIError.invalidURL
        }
        let encoder = JSONEncoder()
        // Asegúrate de que Court.encode(to:) maneje el formato H:i
        let body = try encoder.encode(court) // Court ya implementa Codable y el custom encode para H:i
        
        let response: [String: Court] = try await performRequest(url: url, method: "POST", body: body)
        guard let createdCourt = response["court"] else {
            throw APIError.decodingError(NSError(domain: "", code: 0, userInfo: [NSLocalizedDescriptionKey: "Missing 'court' key in create response"]))
        }
        return createdCourt
    }

    func updateCourt(id: String, court: Court) async throws -> Court {
        guard let url = URL(string: "\(baseURL)/courts/\(id)") else {
            throw APIError.invalidURL
        }
        let encoder = JSONEncoder()
        let body = try encoder.encode(court) // Usa el mismo Court para codificar
        
        let response: [String: Court] = try await performRequest(url: url, method: "PUT", body: body)
        guard let updatedCourt = response["court"] else {
            throw APIError.decodingError(NSError(domain: "", code: 0, userInfo: [NSLocalizedDescriptionKey: "Missing 'court' key in update response"]))
        }
        return updatedCourt
    }

    func deleteCourt(id: String) async throws {
        guard let url = URL(string: "\(baseURL)/courts/\(id)") else {
            throw APIError.invalidURL
        }
        // No se espera una respuesta con un cuerpo JSON específico para DELETE exitoso
        _ = try await performRequest(url: url, method: "DELETE") as [String: String] // Espera un mensaje simple
    }
}
