//
//  EventPlayers.swift
//  CourtClan
//
//  Created by Isain Rodriguez Noreña on 7/7/25.
//

import SwiftUI

struct EventPlayers: View {
    
    @State private var showPlayersView: Bool = false
    @EnvironmentObject var appData: AppData
    
    var body: some View {
        VStack(alignment: .center, spacing: 20) {
            
            // MARK: - Sección "My Courts"
            VStack(alignment: .leading, spacing: 20) {
                Text("Jugadores")
                    .font(.title2)
                    .fontWeight(.bold)
                
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.leading, 0)
            .padding(.trailing, 0)
            
            Button {
                showPlayersView = true
            } label: {
                AddGameButton()
            }
            
            
        }
        .padding(.horizontal)
        .sheet(isPresented: $showPlayersView) {
            if #available(iOS 16.0, *) {
                PlayersView()
                    .environmentObject(appData)
            } else {
                PlayersView()
                    .environmentObject(appData)
            }
        }
    }
}

#Preview {
    EventPlayers()
}
