//
//  EventHeader.swift
//  CourtClan
//
//  Created by Isain Rodriguez Noreña on 7/7/25.
//

import SwiftUI

struct EventHeader: View {
    
    @State private var isProfilePageViewActive:Bool = false
    @State var eventSelected:Event
    @Environment(\.dismiss) var dismiss // Declara la variable dismiss
    
    var body: some View {
        ZStack(alignment: .bottomLeading) {
            LinearGradient(gradient: Gradient(colors: [Color.ccPrimary, Color.black]), startPoint: .topLeading, endPoint: .bottomTrailing)
                .frame(height: 180) // Altura del área de degradado
            
            
            
            HStack(spacing: 1){
                Image("logo2cc") // Asegúrate de que "AppIcon" es el nombre exacto en tus Assets.xcassets
                    .resizable() // Permite redimensionar la imagen
                    .frame(width: 44, height: 44) // Define un tamaño para tu icono
                    .clipShape(Rectangle()) // Opcional: para darle forma circular
                    .shadow(radius: 5) // Opcional: para darle un poco de profundidad
                    .padding(.leading)
                    .padding(.bottom)
                    .padding(.top)
                VStack(alignment: .leading, spacing: 1) {
                    Text("Summer Event")
                        .font(.system(size: 15, weight: .heavy, design: .rounded))
                        .kerning(-1)
                        .textCase(.uppercase)
                        .foregroundColor(.white)
                    
                    Text(eventSelected.name)
                        .font(.system(size: 20, weight: .heavy, design: .rounded))
                        .kerning(-2)
                        .textCase(.uppercase)
                        .foregroundColor(.white)
                }
                .padding(.horizontal,5)
                
            }
            
            
            
            
            
            //StatisticsView(win: player.gamesWon, loss: player.gamesPlayed-player.gamesWon, draw: 0)
        }
        .fullScreenCover(isPresented: $isProfilePageViewActive) {
            
        }
    }
    
    
}

#Preview {
    EventHeader(eventSelected: .sampleEvents[1])
}
