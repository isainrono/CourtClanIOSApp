//
//  EventDetailView.swift
//  CourtClan
//
//  Created by Isain Rodriguez Noreña on 7/7/25.
//

import SwiftUI

struct EventDetailView: View {
    
    let event: Event
    @Environment(\.dismiss) var dismiss // Declara la variable dismiss
    
    var body: some View {
        // La clave es el spacing: 0 en el VStack y el ignoresSafeArea(.all) al VStack
        VStack(spacing: 5) { // <--- Importante: Elimina el espaciado entre los elementos del VStack
            EventHeader(eventSelected: event)
            // .ignoresSafeArea() // Este ya lo tenías, y es correcto para el header
            // Si quieres que el header cubra la zona de la hora, déjalo.
            // Si solo quieres quitar el margen con el scroll, el ignore del VStack principal es más importante.
            
            ScrollView {
                // Contenido principal del evento
                VStack(alignment: .leading, spacing: 20) { // Un VStack para organizar los detalles
                    
                    // Sección de Descripción del Evento
                    EventDescriptionView(description: event.description)
                        .padding(.horizontal) // Añade padding horizontal para el texto
                    
                    Divider().padding(.horizontal) // Separador visual
                    
                    HStack{
                        EventDetailsRowView(icon: "calendar", title: "Fecha y Hora", value: event.scheduledTime.formatted(date: .abbreviated, time: .shortened))
                        EventDetailsRowView(icon: "hourglass", title: "Duración", value: "\(event.durationMinutes) minutos")
                    }
                    
                    HStack{
                        EventDetailsRowView(icon: "person.3.fill", title: "Participantes", value: "\(event.currentParticipantsCount) / \(event.maxParticipants)")
                        EventDetailsRowView(icon: "eye.fill", title: "Visibilidad", value: event.isPublic ? "Público" : "Privado")
                    }
                    
                    HStack{
                        EventDetailsRowView(icon: "tag.fill", title: "Tipo de Evento", value: event.eventType.rawValue.capitalized)
                        EventDetailsRowView(icon: "chart.bar.fill", title: "Estado", value: event.status.rawValue.capitalized)
                    }
                    
                    
                    
                    // Estas son tus vistas existentes, asegúrate de pasarles los datos necesarios
                    EventGames() // Si EventGames necesita 'event' o sub-datos, pásalos aquí: EventGames(games: event.games)
                    EventPlayers() // Si EventPlayers necesita 'event' o sub-datos, pásalos aquí: EventPlayers(players: event.participants)
                    
                    // Asegúrate de que event.court no sea nulo antes de pasarlo a CourtUbicationView
                    if let court = event.court {
                        CourtUbicationView(court: court)
                            .frame(maxWidth: .infinity) // Para que ocupe el ancho completo
                    } else {
                        Text("Información de la cancha no disponible")
                            .foregroundColor(.gray)
                            .padding(.horizontal)
                    }
                    
                    
                    
                }
                .padding(.vertical) // Padding vertical para el contenido del ScrollView
                .frame(maxWidth: .infinity) // Asegura que el VStack ocupa el ancho completo
                .background(Color.white) // Un fondo claro para el contenido principal
                
            }
            .background(Color.gray.opacity(0.1))
        }
        .ignoresSafeArea(.all, edges: .all) // <--- ¡Importante! Hace que todo el VStack ignore las safe areas
        // Esto permite que EventHeader se pegue al borde superior
        // y que el ScrollView se pegue al EventHeader,
        // ya que el VStack padre no está añadiendo márgenes por las safe areas.
        //.navigationBarHidden(true) // Si usas NavigationLink y no quieres la barra de navegación.
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button {
                    dismiss() // Esto sí descartará la vista desde la pila de navegación de HomeView
                } label: {
                    Circle() // La forma del círculo
                        .fill(Color.white.opacity(0.5)) // Color de relleno del círculo (puedes ajustar el color y la opacidad)
                        .frame(width: 25, height: 25) // Establece el tamaño del círculo (zona de toque recomendada por Apple)
                        .overlay( // Coloca la imagen encima del círculo
                            Image(systemName: "xmark")
                                .font(.system(size: 10)) // Tamaño de la flecha, ajústalo para que encaje bien en el círculo
                                .tint(.primary) // Color de la flecha
                        )
                    
                    
                }
            }
            
        }
        .navigationBarBackButtonHidden(true)
        .toolbarBackground(.hidden, for: .navigationBar)
        
    }
}

// Vista para la descripción del evento
struct EventDescriptionView: View {
    let description: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Descripción del Evento")
                .font(.headline)
                .fontWeight(.bold)
                .foregroundColor(.primary)
            
            Text(description)
                .font(.body)
                .foregroundColor(.secondary)
                .fixedSize(horizontal: false, vertical: true) // Permite que el texto se ajuste a varias líneas
        }
    }
}

// Vista para una fila de detalle genérica
struct EventDetailsRowView: View {
    let icon: String
    let title: String
    let value: String
    
    var body: some View {
        HStack(alignment: .top, spacing: 15) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundColor(.accentColor) // O el color que uses para los iconos
                .frame(width: 30) // Asegura un tamaño consistente para los iconos
            
            VStack(alignment: .leading) {
                Text(title)
                    .font(.subheadline)
                    .fontWeight(.medium)
                    .foregroundColor(.secondary)
                Text(value)
                    .font(.body)
                    .foregroundColor(.primary)
            }
            Spacer() // Empuja el contenido a la izquierda
        }
        .padding(.horizontal) // Padding horizontal para cada fila
        .padding(.vertical, 5) // Padding vertical para cada fila
    }
}

#Preview {
    EventDetailView(event: .sampleEvents[1])
}
