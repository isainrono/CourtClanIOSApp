//
//  AddGameView.swift
//  CourtClan
//
//  Created by Isain Rodriguez Noreña on 14/6/25.
//

import SwiftUI

struct AddGameView: View {
    
    @Binding var isShowingSheet: Bool
    
    var body: some View {
        VStack {
            Text("Configuración")
                .font(.title)
                .padding(.bottom, 20)
            
            Text("Aquí puedes ajustar tus preferencias. Esta vista se abre parcialmente sobre la anterior.")
                .font(.body)
                .multilineTextAlignment(.center)
                .padding(.horizontal)
            
            Spacer()
            
            
            Button("Cerrar") {
                // 4. Cambiar la propiedad @Binding a false para cerrar la hoja
                isShowingSheet = false
            }
            .font(.title2)
            .padding()
            .background(Color.red)
            .foregroundColor(.white)
            .cornerRadius(10)
            .shadow(radius: 5)
            .padding(.bottom, 20) // Espacio al final
        }
        .padding()
        .frame(maxWidth: .infinity, maxHeight: .infinity) // Asegura que la vista ocupe todo el espacio disponible en la hoja
        .background(Color.white) // Fondo blanco para la hoja
    }
}

struct AddGameView_Previews: PreviewProvider { // Cambia #Preview por struct AddGameView_Previews: PreviewProvider
    static var previews: some View {
        // --- SOLUCIÓN: Usar .constant() ---
        AddGameView(isShowingSheet: .constant(true))
            .previewLayout(.sizeThatFits) // Para que la preview se ajuste al contenido
            .padding()
    }
}
