//
//  CustomButton.swift
//  CourtClan
//
//  Created by Isain Rodriguez Noreña on 14/6/25.
//

import SwiftUI

struct CustomButtons: View {
    let text: String
    let backgroundColor: Color
    let textColor: Color
    let imageName: String
    
    var body: some View {
        HStack(){
            Image(systemName: imageName)
            Text(text)
        }
        .padding()
        .background(backgroundColor)
        .cornerRadius(12)
        .shadow(radius: 3, x: 2, y: 2)
        .padding(.horizontal)
        .padding(.vertical, 4)
    }
}

#Preview {
    CustomButtons(text: "Añade un nuevo partido", backgroundColor: .white, textColor: .black, imageName: "plus")
}
