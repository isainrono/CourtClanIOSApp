//
//  EventListView.swift
//  CourtClan
//
//  Created by Isain Rodriguez Noreña on 30/6/25.
//

import SwiftUI

// MARK: - EventListView
// Esta vista muestra una lista de eventos.
struct EventListView: View {
    // @StateObject crea y posee una instancia del ViewModel para esta vista.
    // Si esta vista se recrea, el ViewModel persistirá.
    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>
    @StateObject private var viewModel: EventViewModel

    // Inicializador para inyectar la URL base de la API.
    // Esto permite que el ViewModel se inicialice con la configuración correcta.
    init(apiBaseURL: String = "https://courtclan.com/api") {
        _viewModel = StateObject(wrappedValue: EventViewModel(apiBaseURL: apiBaseURL))
    }

    var body: some View {
        NavigationView { // Permite la navegación entre vistas
            List {
                // Mostrar mensaje de error si existe
                if let errorMessage = viewModel.errorMessage {
                    Text("Error: \(errorMessage)")
                        .foregroundColor(.red)
                        .padding()
                }
                // Mostrar indicador de carga
                else if viewModel.isLoading && viewModel.events.isEmpty {
                    ProgressView("Cargando eventos...")
                        .padding()
                }
                // Mostrar mensaje si no hay eventos y no está cargando
                else if viewModel.events.isEmpty {
                    ContentUnavailableView {
                        Label("No hay eventos", systemImage: "calendar.badge.minus")
                    } description: {
                        Text("No se encontraron eventos. Toca para refrescar.")
                    } actions: {
                        Button("Refrescar") {
                            Task {
                                await viewModel.fetchAllEvents()
                            }
                        }
                    }
                }
                // Mostrar la lista de eventos
                else {
                    ForEach(viewModel.events) { event in
                        // NavigationLink para ir a una vista de detalle del evento
                        NavigationLink(destination: EventDetailView(event: event)) {
                            EventRowView(event: event)
                        }
                        
                        
                    }
                }
            }
            .navigationTitle("Eventos") // Título de la barra de navegación
            .toolbar { // Botones en la barra de navegación
                ToolbarItem(placement: .navigationBarLeading) {
                    // Botón para ir a PlayerManagerView
                    Button {
                        // Accede al Environment de presentación para volver a la vista anterior.
                        // Asumimos que EventListView fue presentada desde PlayerManagerView.
                        self.presentationMode.wrappedValue.dismiss()
                    } label: {
                        HStack {
                            Image(systemName: "chevron.left") // Icono de flecha hacia atrás
                            Text("Atrás") // Texto del botón
                        }
                    }
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        viewModel.showCreateEventSheet = true // Abre la hoja para crear un nuevo evento
                    } label: {
                        Label("Crear Evento", systemImage: "plus.circle.fill")
                    }
                }
                
            }
            // Ejecuta fetchAllEvents cuando la vista aparece por primera vez
            .task { // .task es la forma moderna de .onAppear para operaciones asíncronas
                await viewModel.fetchAllEvents()
            }
            // Permite refrescar la lista tirando hacia abajo
            .refreshable {
                await viewModel.fetchAllEvents()
            }
            // Hoja modal para crear un nuevo evento
            .sheet(isPresented: $viewModel.showCreateEventSheet) {
                // Pasa el viewModel al EventCreateView para que pueda crear el evento
                //EventCreateView(viewModel: viewModel)
            }
            
            
        }
    }
}

// MARK: - EventRowView
// Una vista auxiliar para mostrar cada fila de evento en la lista.
struct EventRowView: View {
    let event: Event

    var body: some View {
        VStack(alignment: .leading) {
            Text(event.name)
                .font(.headline)
                .lineLimit(1) // Limita el nombre a una línea
            Text(event.description)
                .font(.subheadline)
                .foregroundColor(.gray)
                .lineLimit(2) // Limita la descripción a dos líneas
            HStack {
                Image(systemName: "clock")
                Text(event.scheduledTime, formatter: DateFormatter.shortDateTime)
                Spacer()
                Image(systemName: "figure.walk.circle.fill")
                Text("\(event.currentParticipantsCount) / \(event.maxParticipants)")
            }
            .font(.caption)
            .foregroundColor(.secondary)
        }
        .padding(.vertical, 4)
    }
}


/*
// MARK: - EventCreateView (Placeholder)
// Esta es una vista placeholder para el formulario de creación de eventos.
// Deberías crear un formulario completo aquí para que el usuario ingrese los datos del nuevo evento.
struct EventCreateView: View {
    @Environment(\.dismiss) var dismiss // Para cerrar la hoja modal
    @ObservedObject var viewModel: EventViewModel // Recibe el ViewModel para crear el evento

    // Propiedades @State para los campos del nuevo evento
    @State private var name: String = ""
    @State private var description: String = ""
    @State private var eventType: EventType = .friendly
    @State private var scheduledTime: Date = Date()
    @State private var durationMinutes: String = "60" // Usar String para entrada de texto
    @State private var courtId: String = "" // Asumimos que el usuario podría introducir un UUID o seleccionar de una lista
    @State private var creatorUserId: String = "" // Asumimos que el usuario podría introducir un UUID o se obtiene de la sesión
    @State private var maxParticipants: String = "4"
    @State private var status: EventStatus = .scheduled
    @State private var isPublic: Bool = true

    var body: some View {
        NavigationView {
            Form {
                Section("Detalles del Evento") {
                    TextField("Nombre del Evento", text: $name)
                    TextField("Descripción", text: $description)
                    Picker("Tipo de Evento", selection: $eventType) {
                        ForEach(EventType.allCases, id: \.self) { type in
                            Text(type.rawValue.capitalized).tag(type)
                        }
                    }
                    DatePicker("Hora Programada", selection: $scheduledTime)
                    TextField("Duración (minutos)", text: $durationMinutes)
                        .keyboardType(.numberPad)
                    TextField("ID de la Cancha (UUID)", text: $courtId) // En una app real, sería un Picker
                    TextField("ID del Creador (UUID)", text: $creatorUserId) // En una app real, se obtendría del usuario logueado
                    TextField("Máx. Participantes", text: $maxParticipants)
                        .keyboardType(.numberPad)
                    Picker("Estado", selection: $status) {
                        ForEach(EventStatus.allCases, id: \.self) { stat in
                            Text(stat.rawValue.capitalized).tag(stat)
                        }
                    }
                    Toggle("Es Público", isOn: $isPublic)
                }

                Button("Crear Evento") {
                    Task {
                        // Validar y convertir los campos a los tipos correctos
                        guard let duration = Int(durationMinutes),
                              let maxParts = Int(maxParticipants),
                              let courtUUID = UUID(uuidString: courtId), // Asegúrate de que sea un UUID válido
                              let creatorUUID = UUID(uuidString: creatorUserId) // Asegúrate de que sea un UUID válido
                        else {
                            // Aquí podrías mostrar un error al usuario si la validación falla
                            print("Error de validación de entrada.")
                            return
                        }

                        let newEvent = Event(
                            name: name,
                            description: description,
                            eventType: eventType,
                            scheduledTime: scheduledTime,
                            durationMinutes: duration,
                            courtId: courtUUID,
                            creatorUserId: creatorUUID,
                            status: status,
                            isPublic: isPublic,
                            maxParticipants: maxParts
                        )
                        await viewModel.createEvent(newEvent)
                        // El viewModel ya maneja el cierre de la hoja si la creación es exitosa
                    }
                }
                .disabled(viewModel.isLoading) // Deshabilita el botón mientras se carga
            }
            .navigationTitle("Nuevo Evento")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancelar") {
                        dismiss() // Cierra la hoja modal
                    }
                }
            }
            // Mostrar error de ViewModel si existe
            .overlay {
                if let errorMessage = viewModel.errorMessage {
                    Text(errorMessage)
                        .foregroundColor(.red)
                        .padding()
                        .background(.white.opacity(0.8))
                        .cornerRadius(8)
                        .shadow(radius: 5)
                        .offset(y: -50) // Posiciona el error un poco más arriba
                }
            }
        }
    }
}

// Extensión para EventType y EventStatus para que sean iterables en Picker
extension EventType: CaseIterable {}
extension EventStatus: CaseIterable {} */


// MARK: - Preview Provider
struct EventListView_Previews: PreviewProvider {
    static var previews: some View {
        // Para la previsualización, se inicializa el ViewModel con el MockEventAPIService.
        // Asegúrate de que EventAPIService y MockEventAPIService estén definidos
        // y que tus modelos (Event, Court, Player, etc.) también lo estén.
        EventListView(apiBaseURL: "http://courtclan.com/api") // Usa una URL mock para previsualización
            // Si EventViewModel se inyecta como EnvironmentObject en tu App,
            // entonces el preview también debería inyectarlo así:
            // .environmentObject(EventViewModel(apiBaseURL: "http://mockapi.com"))
    }
}

#Preview {
    EventListView()
}
