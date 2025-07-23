//
//  EventViewModel.swift
//  CourtClan
//
//  Created by Isain Rodriguez Noreña on 30/6/25.
//

import Foundation
import Combine // Para manejar la reactividad y la publicación de cambios
import SwiftUI // Para @Published

// MARK: - EventViewModel
// ObservableObject para que las vistas de SwiftUI puedan reaccionar a sus cambios.
class EventViewModel: ObservableObject {
    // MARK: - Published Properties
    // Estas propiedades notifican a las vistas de SwiftUI cuando cambian.
    @Published var events: [Event] = [] // Lista de eventos a mostrar
    @Published var isLoading: Bool = false // Indica si se está cargando datos
    @Published var errorMessage: String? // Mensaje de error si ocurre un problema
    @Published var selectedEvent: Event? // Para ver detalles de un evento o editarlo
    @Published var showCreateEventSheet: Bool = false // Para controlar la presentación de una hoja de creación
    @Published var showEventDetailSheet: Bool = false // Para controlar la presentación de una hoja de detalles

    // MARK: - Dependencies
    // Ahora usamos EventAPIService
    private let eventAPIService: EventAPIService

    // MARK: - Initializer
    // Se inicializa con la URL base de la API.
    init(apiBaseURL: String = "https://courtclan.com/api") { // Reemplaza con tu URL real
        self.eventAPIService = EventAPIService(baseURL: apiBaseURL)
    }

    // MARK: - Public Methods for UI Interaction

    /// Fetches all events from the API and updates the `events` array.
    /// Corresponds to the `index()` method in Laravel controller.
    @MainActor // Ensures UI updates happen on the main thread
    func fetchAllEvents() async {
        isLoading = true
        errorMessage = nil // Clear previous errors
        do {
            let fetchedEvents = try await eventAPIService.fetchAllEvents()
            self.events = fetchedEvents
        } catch {
            // Cast the error to our custom EventAPIError for better error messages
            self.errorMessage = (error as? EventAPIService.EventAPIError)?.errorDescription ?? error.localizedDescription
            print("Error fetching all events: \(error.localizedDescription)")
        }
        isLoading = false
    }

    /// Fetches a single event by its ID.
    /// Corresponds to the `show($id)` method in Laravel controller.
    /// - Parameter eventId: The UUID of the event to fetch.
    @MainActor
    func fetchEvent(by id: UUID) async {
        isLoading = true
        errorMessage = nil
        do {
            let fetchedEvent = try await eventAPIService.fetchEvent(by: id)
            self.selectedEvent = fetchedEvent // Set the selected event for detail view
        } catch {
            self.errorMessage = (error as? EventAPIService.EventAPIError)?.errorDescription ?? error.localizedDescription
            print("Error fetching event \(id): \(error.localizedDescription)")
        }
        isLoading = false
    }

    /// Creates a new event via the API and adds it to the local list.
    /// Corresponds to the `store(Request $request)` method in Laravel controller.
    /// - Parameter newEvent: The `Event` object to create.
    @MainActor
    func createEvent(_ newEvent: Event) async {
        isLoading = true
        errorMessage = nil
        do {
            let createdEvent = try await eventAPIService.createEvent(newEvent)
            // Add the newly created event to the local list
            self.events.append(createdEvent)
            self.showCreateEventSheet = false // Dismiss the creation sheet
        } catch {
            self.errorMessage = (error as? EventAPIService.EventAPIError)?.errorDescription ?? error.localizedDescription
            print("Error creating event: \(error.localizedDescription)")
        }
        isLoading = false
    }

    /// Updates an existing event via the API and updates it in the local list.
    /// Corresponds to the `update(Request $request, $id)` method in Laravel controller.
    /// - Parameter updatedEvent: The `Event` object with updated data.
    @MainActor
    func updateEvent(_ updatedEvent: Event) async {
        isLoading = true
        errorMessage = nil
        do {
            let updatedEventFromServer = try await eventAPIService.updateEvent(updatedEvent, id: updatedEvent.id)

            if let index = self.events.firstIndex(where: { $0.id == updatedEventFromServer.id }) {
                self.events[index] = updatedEventFromServer
            }
            self.selectedEvent = nil // Clear selected event after update
            self.showEventDetailSheet = false // Dismiss detail sheet if open
        } catch {
            self.errorMessage = (error as? EventAPIService.EventAPIError)?.errorDescription ?? error.localizedDescription
            print("Error updating event: \(error.localizedDescription)")
        }
        isLoading = false
    }

    /// Deletes an event via the API and removes it from the local list.
    /// Corresponds to the `destroy($id)` method in Laravel controller.
    /// - Parameter event: The `Event` object to delete.
    @MainActor
    func deleteEvent(_ event: Event) async {
        isLoading = true
        errorMessage = nil
        do {
            try await eventAPIService.deleteEvent(by: event.id)
            self.events.removeAll(where: { $0.id == event.id })
            self.selectedEvent = nil // Clear selected event after deletion
            self.showEventDetailSheet = false // Dismiss detail sheet if open
        } catch {
            self.errorMessage = (error as? EventAPIService.EventAPIError)?.errorDescription ?? error.localizedDescription
            print("Error deleting event: \(error.localizedDescription)")
        }
        isLoading = false
    }

    /// Joins a user to an event via the API.
    /// Corresponds to the `joinEvent(Request $request, $id)` method in Laravel controller.
    /// - Parameters:
    ///   - eventId: The UUID of the event to join.
    ///   - userId: The UUID of the user joining.
    @MainActor
    func joinEvent(eventId: UUID, userId: UUID) async {
        isLoading = true
        errorMessage = nil
        do {
            try await eventAPIService.joinEvent(eventId: eventId, userId: userId)
            // After successful join, refresh the specific event to show updated participants
            await fetchEvent(by: eventId)
        } catch {
            self.errorMessage = (error as? EventAPIService.EventAPIError)?.errorDescription ?? error.localizedDescription
            print("Error joining event \(eventId) by user \(userId): \(error.localizedDescription)")
        }
        isLoading = false
    }

    /// Allows a user to leave an event via the API.
    /// Corresponds to the `leaveEvent(Request $request, $id)` method in Laravel controller.
    /// - Parameters:
    ///   - eventId: The UUID of the event to leave.
    ///   - userId: The UUID of the user leaving.
    @MainActor
    func leaveEvent(eventId: UUID, userId: UUID) async {
        isLoading = true
        errorMessage = nil
        do {
            try await eventAPIService.leaveEvent(eventId: eventId, userId: userId)
            // After successful leave, refresh the specific event to show updated participants
            await fetchEvent(by: eventId)
        } catch {
            self.errorMessage = (error as? EventAPIService.EventAPIError)?.errorDescription ?? error.localizedDescription
            print("Error leaving event \(eventId) by user \(userId): \(error.localizedDescription)")
        }
        isLoading = false
    }

    /// Searches events by a specific status.
    /// Corresponds to the `searchByStatus(Request $request)` method in Laravel controller.
    /// - Parameter status: The status string to filter by (e.g., "Scheduled", "Active").
    @MainActor
    func searchEvents(byStatus status: EventStatus) async {
        isLoading = true
        errorMessage = nil
        do {
            let fetchedEvents = try await eventAPIService.searchEvents(byStatus: status)
            self.events = fetchedEvents
        } catch {
            self.errorMessage = (error as? EventAPIService.EventAPIError)?.errorDescription ?? error.localizedDescription
            print("Error searching events by status \(status.rawValue): \(error.localizedDescription)")
        }
        isLoading = false
    }

    // MARK: - Helper Methods (for UI flow)
    func selectEvent(_ event: Event) {
        self.selectedEvent = event
        self.showEventDetailSheet = true
    }

    func clearSelectedEvent() {
        self.selectedEvent = nil
        self.showEventDetailSheet = false
    }
}

// MARK: - Extension for DateFormatter (as used in the example EventListView)
extension DateFormatter {
    static let shortDateTime: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .short
        formatter.timeStyle = .short
        return formatter
    }()
}
