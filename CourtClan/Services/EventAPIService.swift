//
//  EventAPIService.swift
//  CourtClan
//
//  Created by Isain Rodriguez Noreña on 30/6/25.
//

import Foundation

// MARK: - EventAPIService
// Esta clase gestiona todas las interacciones de red con tu API de eventos de Laravel.
class EventAPIService {

    // MARK: - Propiedades estáticas para configuración de JSON

    // Custom DateFormatter para manejar microsegundos (hasta 6 dígitos)
    // Laravel a menudo usa este formato para sus timestamps.
    private static let iso8601WithMicrosecondsFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSSSSZ" // Handles up to 6 fractional seconds
        formatter.locale = Locale(identifier: "en_US_POSIX") // Crucial for fixed format parsing
        formatter.timeZone = TimeZone(secondsFromGMT: 0) // Ensures UTC interpretation for 'Z'
        return formatter
    }()

    // Configuración del decodificador de JSON para manejar fechas
    private static let jsonDecoder: JSONDecoder = {
        let decoder = JSONDecoder()
        // Usa el formato personalizado que soporta microsegundos
        decoder.dateDecodingStrategy = .formatted(iso8601WithMicrosecondsFormatter)
        return decoder
    }()

    // Configuración del codificador de JSON
    private static let jsonEncoder: JSONEncoder = {
        let encoder = JSONEncoder()
        // Usa el mismo formato personalizado para codificar si necesitas enviar fechas así
        encoder.dateEncodingStrategy = .formatted(iso8601WithMicrosecondsFormatter)
        encoder.outputFormatting = .prettyPrinted // Útil para depuración, considera eliminar en producción
        return encoder
    }()

    // MARK: - Propiedades de Instancia
    private let baseURL: String // La URL base de tu API (e.g., "https://your-laravel-api.com/api")

    // MARK: - Inicializador
    init(baseURL: String) {
        self.baseURL = baseURL
    }

    // MARK: - Métodos de la API

    /// Obtiene una lista de todos los eventos desde la API.
    /// Corresponde al método `index()` del controlador de Laravel.
    /// - Returns: Un array de objetos `Event` si tiene éxito.
    /// - Throws: `EventAPIError` si la solicitud falla o la decodificación es incorrecta.
    func fetchAllEvents() async throws -> [Event] {
        let urlString = "\(baseURL)/events"
        return try await performGetRequest(urlString: urlString, responseType: EventsResponse.self).events
    }

    /// Obtiene un solo evento por su ID desde la API.
    /// Corresponde al método `show($id)` del controlador de Laravel.
    /// - Parameter id: El UUID del evento a obtener.
    /// - Returns: El objeto `Event` si tiene éxito.
    /// - Throws: `EventAPIError` si el evento no se encuentra, la solicitud falla o la decodificación es incorrecta.
    func fetchEvent(by id: UUID) async throws -> Event {
        let urlString = "\(baseURL)/events/\(id.uuidString.lowercased())"
        return try await performGetRequest(urlString: urlString, responseType: SingleEventResponse.self).event
    }

    /// Crea un nuevo evento enviando una solicitud POST a la API.
    /// Corresponde al método `store(Request $request)` del controlador de Laravel.
    /// - Parameter event: El objeto `Event` a crear.
    /// - Returns: El objeto `Event` creado (con posibles datos generados por el servidor como ID, timestamps).
    /// - Throws: `EventAPIError` si la solicitud falla o la codificación/decodificación es incorrecta.
    func createEvent(_ event: Event) async throws -> Event {
        let urlString = "\(baseURL)/events"
        return try await performPostRequest(urlString: urlString, requestBody: event, responseType: SingleEventMessageResponse.self).event
    }

    /// Actualiza un evento existente enviando una solicitud PUT a la API.
    /// Corresponde al método `update(Request $request, $id)` del controlador de Laravel.
    /// - Parameters:
    ///   - event: El objeto `Event` con los datos actualizados.
    ///   - id: El UUID del evento a actualizar.
    /// - Returns: El objeto `Event` actualizado.
    /// - Throws: `EventAPIError` si el evento no se encuentra, la solicitud falla o la codificación/decodificación es incorrecta.
    func updateEvent(_ event: Event, id: UUID) async throws -> Event {
        let urlString = "\(baseURL)/events/\(id.uuidString.lowercased())"
        return try await performPutRequest(urlString: urlString, requestBody: event, responseType: SingleEventMessageResponse.self).event
    }

    /// Elimina un evento por su ID enviando una solicitud DELETE a la API.
    /// Corresponde al método `destroy($id)` del controlador de Laravel.
    /// - Parameter id: El UUID del evento a eliminar.
    /// - Throws: `EventAPIError` si el evento no se encuentra o la solicitud falla.
    func deleteEvent(by id: UUID) async throws {
        let urlString = "\(baseURL)/events/\(id.uuidString.lowercased())"
        _ = try await performDeleteRequest(urlString: urlString, responseType: MessageResponse.self)
    }

    /// Une a un usuario a un evento.
    /// Corresponde al método `joinEvent(Request $request, $id)` del controlador de Laravel.
    /// - Parameters:
    ///   - eventId: El UUID del evento al que unirse.
    ///   - userId: El UUID del usuario que se une.
    /// - Throws: `EventAPIError` si la solicitud falla o el usuario ya participa.
    func joinEvent(eventId: UUID, userId: UUID) async throws {
        let urlString = "\(baseURL)/events/\(eventId.uuidString.lowercased())/join"
        let requestBody = ["user_id": userId.uuidString.lowercased()]
        _ = try await performPostRequest(urlString: urlString, requestBody: requestBody, responseType: MessageResponse.self)
    }

    /// Permite a un usuario dejar un evento.
    /// Corresponde al método `leaveEvent(Request $request, $id)` del controlador de Laravel.
    /// - Parameters:
    ///   - eventId: El UUID del evento a dejar.
    ///   - userId: El UUID del usuario que deja el evento.
    /// - Throws: `EventAPIError` si la solicitud falla o el usuario no participa.
    func leaveEvent(eventId: UUID, userId: UUID) async throws {
        let urlString = "\(baseURL)/events/\(eventId.uuidString.lowercased())/leave"
        let requestBody = ["user_id": userId.uuidString.lowercased()]
        _ = try await performPostRequest(urlString: urlString, requestBody: requestBody, responseType: MessageResponse.self)
    }

    /// Busca eventos por un estado dado.
    /// Corresponde al método `searchByStatus(Request $request)` del controlador de Laravel.
    /// - Parameter status: El estado del evento por el que filtrar (e.g., `.scheduled`, `.active`).
    /// - Returns: Un array de objetos `Event` que coinciden con el estado.
    /// - Throws: `EventAPIError` si la solicitud falla o la decodificación es incorrecta.
    func searchEvents(byStatus status: EventStatus) async throws -> [Event] {
        let urlString = "\(baseURL)/events/search-by-status?status=\(status.rawValue)"
        return try await performGetRequest(urlString: urlString, responseType: EventsResponse.self).events
    }

    // MARK: - Métodos Privados de Utilidad para Solicitudes de Red

    /// Realiza una solicitud GET genérica.
    private func performGetRequest<T: Decodable>(urlString: String, responseType: T.Type) async throws -> T {
        guard let url = URL(string: urlString) else {
            throw EventAPIError.invalidURL(urlString)
        }

        let (data, response) = try await URLSession.shared.data(from: url)
        return try handleResponse(data: data, response: response, responseType: responseType)
    }

    /// Realiza una solicitud POST genérica.
    private func performPostRequest<RequestBody: Encodable, ResponseBody: Decodable>(urlString: String, requestBody: RequestBody, responseType: ResponseBody.Type) async throws -> ResponseBody {
        guard let url = URL(string: urlString) else {
            throw EventAPIError.invalidURL(urlString)
        }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = try Self.jsonEncoder.encode(requestBody)

        let (data, response) = try await URLSession.shared.data(for: request)
        return try handleResponse(data: data, response: response, responseType: responseType)
    }

    /// Realiza una solicitud PUT genérica.
    private func performPutRequest<RequestBody: Encodable, ResponseBody: Decodable>(urlString: String, requestBody: RequestBody, responseType: ResponseBody.Type) async throws -> ResponseBody {
        guard let url = URL(string: urlString) else {
            throw EventAPIError.invalidURL(urlString)
        }

        var request = URLRequest(url: url)
        request.httpMethod = "PUT" // O "PATCH" si tu API usa PATCH para actualizaciones parciales
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = try Self.jsonEncoder.encode(requestBody)

        let (data, response) = try await URLSession.shared.data(for: request)
        return try handleResponse(data: data, response: response, responseType: responseType)
    }

    /// Realiza una solicitud DELETE genérica.
    private func performDeleteRequest<ResponseBody: Decodable>(urlString: String, responseType: ResponseBody.Type) async throws -> ResponseBody {
        guard let url = URL(string: urlString) else {
            throw EventAPIError.invalidURL(urlString)
        }

        var request = URLRequest(url: url)
        request.httpMethod = "DELETE"

        let (data, response) = try await URLSession.shared.data(for: request)
        return try handleResponse(data: data, response: response, responseType: responseType)
    }

    /// Maneja la respuesta de la red, verificando el estado HTTP y decodificando los datos.
    private func handleResponse<T: Decodable>(data: Data, response: URLResponse, responseType: T.Type) throws -> T {
        guard let httpResponse = response as? HTTPURLResponse else {
            throw EventAPIError.invalidResponse
        }

        // Imprimir la respuesta para depuración
        #if DEBUG
        if let jsonString = String(data: data, encoding: .utf8) {
            print("Received JSON: \(jsonString)")
        }
        #endif

        switch httpResponse.statusCode {
        case 200...299:
            do {
                return try Self.jsonDecoder.decode(responseType, from: data)
            } catch {
                print("Decoding error: \(error)")
                throw EventAPIError.decodingError(error)
            }
        case 400: // Bad Request (e.g., validation errors)
            if let apiError = try? Self.jsonDecoder.decode(APIErrorResponse.self, from: data) {
                throw EventAPIError.badRequest(apiError.error ?? ["message": ["Validation failed."]])
            } else if let messageResponse = try? Self.jsonDecoder.decode(MessageResponse.self, from: data) {
                throw EventAPIError.badRequest(["message": [messageResponse.message]])
            }
            throw EventAPIError.networkError(statusCode: httpResponse.statusCode, message: "Bad Request")
        case 404: // Not Found
            throw EventAPIError.notFound
        case 500...599: // Server Errors
            if let messageResponse = try? Self.jsonDecoder.decode(MessageResponse.self, from: data) {
                throw EventAPIError.serverError(message: messageResponse.message)
            }
            throw EventAPIError.networkError(statusCode: httpResponse.statusCode, message: "Server Error")
        default:
            throw EventAPIError.networkError(statusCode: httpResponse.statusCode, message: "Unknown network error")
        }
    }

    // MARK: - Tipos de Respuesta de la API (para decodificación)
    // Estas structs ayudan a mapear la estructura JSON que tu API de Laravel devuelve.

    // Respuesta para `index()` y `searchByStatus()`
    struct EventsResponse: Codable {
        let events: [Event]
    }

    // Respuesta para `show()`
    struct SingleEventResponse: Codable {
        let event: Event
    }

    // Respuesta para `store()` y `update()`
    struct SingleEventMessageResponse: Codable {
        let message: String
        let event: Event
    }

    // Respuesta genérica para mensajes (e.g., `destroy()`, `joinEvent()`, `leaveEvent()`)
    struct MessageResponse: Codable {
        let message: String
    }

    // Estructura para errores de validación de Laravel (código 400)
    struct APIErrorResponse: Codable {
        let message: String?
        let error: [String: [String]]? // Para errores de validación detallados
    }

    // MARK: - Custom Error Type
    enum EventAPIError: Error, LocalizedError {
        case invalidURL(String)
        case invalidResponse
        case networkError(statusCode: Int, message: String?)
        case decodingError(Error)
        case encodingError(Error)
        case notFound // Para 404
        case badRequest([String: [String]]) // Para 400 con errores de validación
        case serverError(message: String) // Para 5xx
        case unknown

        var errorDescription: String? {
            switch self {
            case .invalidURL(let url):
                return "La URL proporcionada es inválida: \(url)."
            case .invalidResponse:
                return "Respuesta inválida del servidor."
            case .networkError(let statusCode, let message):
                return "Error de red (\(statusCode)): \(message ?? "Desconocido")."
            case .decodingError(let error):
                return "Fallo al decodificar los datos: \(error.localizedDescription)."
            case .encodingError(let error):
                return "Fallo al codificar los datos: \(error.localizedDescription)."
            case .notFound:
                return "El recurso solicitado no fue encontrado (404)."
            case .badRequest(let errors):
                let errorMessages = errors.flatMap { (key, value) in
                    value.map { "\(key): \($0)" }
                }.joined(separator: "\n")
                return "Solicitud inválida (400):\n\(errorMessages)"
            case .serverError(let message):
                return "Error del servidor: \(message)."
            case .unknown:
                return "Ocurrió un error desconocido."
            }
        }
    }
}

// MARK: - Extension para UUID para facilitar el uso en URLs
extension UUID {
    // Convierte el UUID a su representación de cadena en minúsculas sin guiones
    // si tu API lo prefiere así en las URLs.
    // Aunque `uuidString.lowercased()` ya es suficiente para la mayoría de los casos.
    var urlSafeString: String {
        return self.uuidString.lowercased()
    }
}
