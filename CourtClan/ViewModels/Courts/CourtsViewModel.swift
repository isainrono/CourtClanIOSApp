//
//  CourtsViewModel.swift
//  RodMon
//
//  Created by Isain Rodriguez Noreña on 20/5/25.
//

import Foundation
import Combine

// MARK: - Courts ViewModel
class CourtsViewModel: ObservableObject {
    @Published var courts: [Court] = []
    @Published var isLoading: Bool = false
    @Published var errorMessage: String? = nil

    private let courtService: CourtService // Dependencia inyectada

    init(courtService: CourtService = CourtAPIService(baseURL: "https://courtclan.com/api")) {
        self.courtService = courtService
    }

    @MainActor
    func fetchAllCourts() async {
        isLoading = true
        errorMessage = nil
        do {
            self.courts = try await courtService.fetchAllCourts()
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
