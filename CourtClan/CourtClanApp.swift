//
//  CourtClanApp.swift
//  CourtClan
//
//  Created by Isain Rodriguez Noreña on 20/5/25.
//

import SwiftUI

@main
struct CourtClanApp: App {
    
    @StateObject private var appData = AppData()
    @StateObject private var appUtils = AppUtils()
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(appData)
                .environmentObject(appUtils)
        }
    }
}
