//
//  CourtCardRowView.swift
//  CourtClan
//
//  Created by Isain Rodriguez Noreña on 10/6/25.
//

import SwiftUI

struct CourtCardRowView: View {
    let courts: [Court]
    
    // Nueva clausura para la acción de selección de cancha
    var onCourtSelected: (Court) -> Void
    @State private var isCourtDeailActive = false
    @State private var selectedCourt: Court?
    
    var body: some View {
        VStack {
            ForEach(courts) { court in
                // Reemplazamos NavigationLink con un Button o un TapGesture
               
                    Button {
                        // Llama a la clausura cuando la tarjeta es tocada
                        //onCourtSelected(court)
                        selectedCourt = court
                        isCourtDeailActive = true
                        
                    } label: {
                        // Contenido visual de la tarjeta (sin cambios de forma)
                        VStack(alignment: .leading) {
                            Text(court.name)
                                .font(.headline)
                                .foregroundColor(.primary)
                            
                            Text(court.address)
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                            
                            HStack {
                                if court.hasHoop {
                                    Image(systemName: "basketball.fill")
                                        .font(.caption)
                                        .foregroundColor(.orange)
                                }
                                if court.hasNet {
                                    Image(systemName: "sportscourt.fill")
                                        .font(.caption)
                                        .foregroundColor(.green)
                                }
                                if court.hasLights {
                                    Image(systemName: "lightbulb.fill")
                                        .font(.caption)
                                        .foregroundColor(.yellow)
                                }
                                Spacer()
                                if court.isPublic {
                                    Text("Pública")
                                        .font(.caption)
                                        .padding(.horizontal, 6)
                                        .padding(.vertical, 3)
                                        .background(Capsule().fill(Color.blue.opacity(0.2)))
                                        .foregroundColor(.blue)
                                } else {
                                    Text("Privada")
                                        .font(.caption)
                                        .padding(.horizontal, 6)
                                        .padding(.vertical, 3)
                                        .background(Capsule().fill(Color.red.opacity(0.2)))
                                        .foregroundColor(.red)
                                }
                            }
                            .padding(.top, 4)
                            
                            // Si quieres que las imágenes se carguen, descomenta esto
                            // AsyncImage(url: URL(string: court.picturesUrls.first ?? "")) { image in
                            //      image.resizable().scaledToFill()
                            // } placeholder: {
                            //      ProgressView()
                            // }
                            // .frame(height: 150)
                            // .clipped()
                            // .cornerRadius(10)
                        }
                        .padding()
                        .background(Color.white)
                        .cornerRadius(12)
                        .shadow(radius: 3, x: 2, y: 2)
                        .padding(.horizontal)
                        .padding(.vertical, 4)
                    }
                    .buttonStyle(PlainButtonStyle()) // Importante para que no se vea como un botón predeterminado
                
                
            }
        }
        .fullScreenCover(isPresented: $isCourtDeailActive){
            CourtDetailView(court: selectedCourt ?? Court(
                name: "Cancha del Polideportivo",
                address: "Plaza Mayor s/n, Sevilla",
                latitude: "37.3891",
                longitude: "-5.9845",
                description: "Cancha cubierta, ideal para entrenamientos y partidos.",
                isPublic: true,
                hasHoop: true,
                hasNet: true,
                hasLights: true,
                availabilityNotes: "Requiere reserva previa en la recepción."
            ))
        }
        
    }
}

#Preview {
    // Aquí es donde usas la instancia de Court para la preview
    // Puedes usar la propiedad estática 'previewCourt' de la extensión
    let allPreviewCourts: [Court] = [
        .previewCourt,
        .anotherPreviewCourt,
        Court(
            name: "Cancha del Polideportivo",
            address: "Plaza Mayor s/n, Sevilla",
            latitude: "37.3891",
            longitude: "-5.9845",
            description: "Cancha cubierta, ideal para entrenamientos y partidos.",
            isPublic: true,
            hasHoop: true,
            hasNet: true,
            hasLights: true,
            availabilityNotes: "Requiere reserva previa en la recepción."
        )
    ]
    
    CourtCardRowView(courts: allPreviewCourts) { court in
        // Este código se ejecutará cuando se "simule" que se selecciona una cancha en el preview
        print("Cancha seleccionada en el preview: \(court.name)")
        // En un entorno real, aquí podrías actualizar un @State para mostrar un sheet, etc.
    }
    
}
