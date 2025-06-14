//
//  MyEventsView.swift
//  CourtClan
//
//  Created by Isain Rodriguez Noreña on 11/6/25.
//

import SwiftUI

struct MyEventsView: View {
    var body: some View {
        
        VStack(alignment: .leading, spacing: 20) {
            
            // MARK: - Sección "My Courts"
            VStack(alignment: .leading, spacing: 20) {
                Text("My Events")
                    .font(.title2)
                    .fontWeight(.bold)
                
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.leading, 0)
            .padding(.trailing, 0)
            
            VStack(alignment: .leading){
                Text("Añade un nuevo evento")
            }
            .padding()
            .background(Color.white)
            .cornerRadius(12)
            .shadow(radius: 3, x: 2, y: 2)
            // Nota: `List` ya añade un padding horizontal. Podrías quitarlo aquí
            // si quieres que las tarjetas ocupen todo el ancho dentro de la celda de la lista.
            .padding(.horizontal)
            .padding(.vertical, 4) // Espaciado entre las "tarjetas" dentro de la List
            
        }
        .padding(.horizontal)
    }
}

#Preview {
    MyEventsView()
}
