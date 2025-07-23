//
//  MyGamesView.swift
//  CourtClan
//
//  Created by Isain Rodriguez Noreña on 14/6/25.
//

import SwiftUI

struct MyGamesView: View {
    @State var showAddGameView: Bool = false
    
    var body: some View {
        VStack(alignment: .center, spacing: 20) {
            
            // MARK: - Sección "My Courts"
            VStack(alignment: .leading, spacing: 20) {
                Text("Mis Partidos")
                    .font(.title2)
                    .fontWeight(.bold)
                
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.leading, 0)
            .padding(.trailing, 0)
            
            Button {
                showAddGameView = true
            } label: {
                AddGameButton()
            }
            
            
        }
        .padding(.horizontal)
        .sheet(isPresented: $showAddGameView) {
            if #available(iOS 16.0, *) {
                /*AddGameView(isShowingSheet: $showAddGameView)
                    .presentationDetents([.large])
                    .presentationDragIndicator(.visible)*/
                GamesPlayerView(viewModel: GamesViewModel())
            } else {
                //AddGameView(isShowingSheet: $showAddGameView)
                GamesPlayerView(viewModel: GamesViewModel())
            }
        }
    }
}

struct AddGameButton: View {
    var body: some View {
        CustomButtons(text: "Añade un nuevo partido", backgroundColor: .white, textColor: .black, imageName: "plus")
    }
}



#Preview {
    MyGamesView()
}
