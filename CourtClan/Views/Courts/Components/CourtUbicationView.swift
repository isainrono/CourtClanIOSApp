//
//  CourtUbicationView.swift
//  CourtClan
//
//  Created by Isain Rodriguez Noreña on 7/7/25.
//

import SwiftUI
import MapKit

struct CourtUbicationView: View {
    
    let court: Court
    
    private var coordinate: CLLocationCoordinate2D? {
        guard let lat = Double(court.latitude),
              let lon = Double(court.longitude) else {
            return nil
        }
        return CLLocationCoordinate2D(latitude: lat, longitude: lon)
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Label("Ubicación", systemImage: "map.fill")
                .font(.headline)
            
            if let coordinate = coordinate {
                Map(initialPosition: .region(MKCoordinateRegion(center: coordinate, span: MKCoordinateSpan(latitudeDelta: 0.005, longitudeDelta: 0.005)))) {
                    Marker(court.name, coordinate: coordinate)
                }
                .frame(height: 150)
                .cornerRadius(20)
                .shadow(radius: 5)
            } else {
                Text("Ubicación no disponible.")
                    .foregroundColor(.red)
            }
        }
        .padding(.horizontal)
    }
}

#Preview {
    CourtUbicationView(court: .previewCourt)
}
