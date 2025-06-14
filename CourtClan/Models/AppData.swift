//
//  AppData.swift
//  RodMon
//
//  Created by Isain Rodriguez Noreña on 16/4/25.
//

import Foundation
import SwiftUI

class AppData: ObservableObject {
    @Published var appName: String = "COURTCLAN"
    @Published var apiBaseURL: String
    @Published var appColor: Color = Color(red: 2/255, green: 129/255, blue: 138/255)
    
    // AHORA: AppData contiene una instancia de PlayersViewModel
    @Published var playersViewModel: PlayersViewModel?
    
    // App text information
    @Published var loginText: String = "Valida tus datos para continuar!"
    
    init(baseURL: String = "https://courtclan.com/api") {
        self.apiBaseURL = baseURL
        
        // Creamos la instancia de PlayerAPIService
        let playerAPIService = PlayerAPIService(baseURL: self.apiBaseURL)
        
        // Inicializamos PlayersViewModel pasándole el PlayerAPIService
        self.playersViewModel = PlayersViewModel(playerService: playerAPIService)
    }
}
