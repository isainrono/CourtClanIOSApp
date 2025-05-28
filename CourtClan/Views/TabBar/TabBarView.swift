//
//  TabBarView.swift
//  RodMon
//
//  Created by Isain Rodriguez Noreña on 17/4/25.
//

import SwiftUI

struct TabBarView: View {
    
    @State private var tabSelection: Int = 1
    @Namespace private var animation
    @EnvironmentObject var appData: AppData
    
    var body: some View {
        
        TabView (selection: $tabSelection){
            
            HomeView()
                .environmentObject(AppData())
                .tag(1)
            
            TeamsView().tag(2)
            
            HighLightsView().tag(3)
            
            CourtsView().tag(4)
            
            PlayersView().tag(5)
            
            
        }
        .overlay(alignment: .bottom){
            CustomTabBar(tabSelection: $tabSelection, animation: animation)
        }
        .ignoresSafeArea()
        
    }
}

struct FirstTabView: View {
    var body: some View {
        Text("Contenido de la pestaña Inicio")
            .toolbar {
                ToolbarItem(placement: .principal) {
                    Text("Home") // Lo que quieres en el centro
                        .font(.headline) // O el estilo que prefieras
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        // Acción del icono de la derecha
                        print("Icono de la derecha pulsado")
                    } label: {
                        Image(systemName: "gear") // El icono que quieres
                    }
                }
            }
        
    }
    
}

struct SecondTabView: View {
    var body: some View {
        Text("Contenido de la pestaña Buscar")
    }
}

struct ThirdTabView: View {
    var body: some View {
        Text("Contenido de la pestaña Favoritos")
    }
}

struct FourthTabView: View {
    var body: some View {
        Text("Contenido de la pestaña Perfil")
    }
}

#Preview {
    TabBarView()
        .environmentObject(AppData())
}
