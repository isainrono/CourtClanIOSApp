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
    @Published var apiBaseURL: String = "https://courtclan.com/api"
    @Published var appColor: Color = Color(red: 2/255, green: 129/255, blue: 138/255)
    
    // App text information
    @Published var loginText: String = "Valida tus datos para continuar!"
}
