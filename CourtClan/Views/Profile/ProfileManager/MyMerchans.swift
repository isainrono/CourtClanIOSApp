//
//  MyMerchans.swift
//  CourtClan
//
//  Created by Isain Rodriguez Noreña on 11/6/25.
//

import SwiftUI

struct MyMerchans: View {
    var body: some View {
        VStack(alignment: .center, spacing: 20) {
            
            // MARK: - Sección "My Courts"
            VStack(alignment: .leading, spacing: 20) {
                Text("Mis comercios")
                    .font(.title2)
                    .fontWeight(.bold)
                
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.leading, 0)
            .padding(.trailing, 0)
            
            AddMerchanButton()
            
        }
        .padding(.horizontal)
    }
}

struct AddMerchanButton: View {
    var body: some View {
        CustomButtons(text: "Añade un nuevo comercio", backgroundColor: .white, textColor: .black, imageName: "plus")
    }
}

#Preview {
    MyMerchans()
}
