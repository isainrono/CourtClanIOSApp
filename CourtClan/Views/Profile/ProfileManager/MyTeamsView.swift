//
//  MyTeamsView.swift
//  CourtClan
//
//  Created by Isain Rodriguez Noreña on 7/6/25.
//

import SwiftUI

struct MyTeamsView: View {
    
    var team: Team?
    
    init(team: Team) {
        self.team = team
    }
    
    var body: some View {
        HStack{
            Text("Mis Equipos")
                .font(.title2)
                .fontWeight(.bold)
            Spacer()
        }
        .padding(.horizontal)
        
        VStack{
            
            if team?.name == "" {
                AddTeamButton()
            } else {
                TeamRowView(team: team!)
            }
            
            
            
        }
        .padding(.horizontal)
    }
}

struct AddTeamButton:View {
    var body: some View {
        CustomButtons(text: "Añade un nuevo equipo", backgroundColor: .white, textColor: .black, imageName: "plus")
    }
}

#Preview {
    let team = Team(
        id: UUID().uuidString,
        name: "Los Angeles Lakers",
        description: "An iconic basketball team.",
        logoUrl: "https://example.com/lakers_logo.png",
        ownerUserId: UUID().uuidString,
        captainUserId: UUID().uuidString,
        teamFunds: 10000000.0,
        createdAt: Date(),
        updatedAt: Date()
    )
    
    MyTeamsView(team: team)
}
