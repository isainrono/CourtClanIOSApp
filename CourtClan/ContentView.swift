//
//  ContentView.swift
//  CourtClan
//
//  Created by Isain Rodriguez Noreña on 20/5/25.
//

import SwiftUI


struct ContentView: View {
    
    @State private var isSplashScreenVisible = true
    @State private var isKeyboarShowing:Bool = false
    @State private var isLoggedIn = false
    
    var body: some View {
        Group {
            if isSplashScreenVisible {
                // Contenido de tu "splash screen" personalizado
                // Puede ser similar a lo que tenías en LaunchScreen
                VStack (spacing: 4){
                    Image("logoTipo") // Reemplaza con tu logo
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 400, height: 400)
                    
                }
                .onAppear {
                    // Simula un retraso de 2 segundos
                    DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                        withAnimation {
                            isSplashScreenVisible = false
                        }
                    }
                }
            } else {
                if isLoggedIn {
                    //TabBarView()
                    ChargeView()
                } else {
                    
                    Login(onLoginSuccess: {
                        isLoggedIn = true
                    })
                    
                    
                }
                
            }
        }
        
        
    }
}



#Preview {
    ContentView()
}
