//
//  ChargeView.swift
//  CourtClan
//
//  Created by Isain Rodriguez Noreña on 11/6/25.
//

import SwiftUI

struct ChargeView: View {
    @EnvironmentObject var appData: AppData

        @State private var fetchedPlayer: Player? // Para almacenar el jugador cargado
        @State private var localErrorMessage: String? // Para errores específicos de esta vista
        @State private var isLoadingPlayer: Bool = true // Estado de carga para esta vista específica
        // Ya no necesitamos dismiss aquí si vamos a presentar la TabBarView
        // @Environment(\.dismiss) var dismiss
        @State private var showTabbar: Bool = false // Controla la presentación de TabBarView

        var body: some View {
            // Usamos un Group para que la vista raíz pueda contener la lógica de presentación
            // y para no anidar un NavigationView dentro de otro si ya está en la jerarquía principal (como en SceneDelegate/App.swift)
            Group {
                if showTabbar {
                    TabBarView()
                        .environmentObject(appData) // Asegúrate de pasar appData a TabBarView
                } else {
                    // Contenido de carga o error
                    VStack {
                        Spacer() // Empuja el contenido al centro vertical
                        
                        if isLoadingPlayer {
                            ProgressView("Cargando perfil del jugador...")
                                .font(.headline) // Hace el texto un poco más grande
                                .foregroundColor(.gray) // Un color más sutil
                                .padding() // Pequeño padding alrededor del ProgressView
                        } else if let player = fetchedPlayer {
                            // Si el jugador se cargó con éxito, podemos mostrar un mensaje
                            // o un botón para ir a la TabBarView.
                            // Para tu requerimiento, la idea es pasar automáticamente,
                            // pero si quieres un paso intermedio, este botón podría ser útil.
                            VStack(spacing: 20) {
                                Image(systemName: "checkmark.circle.fill")
                                    .resizable()
                                    .frame(width: 60, height: 60)
                                    .foregroundColor(.green)
                                Text("Perfil de \(player.username) cargado con éxito!")
                                    .font(.title2)
                                    .multilineTextAlignment(.center)
                                
                                Button("Continuar") {
                                    // Al tocar el botón, se muestra la TabBarView
                                    showTabbar = true
                                }
                                .padding()
                                .buttonStyle(.borderedProminent)
                            }
                            .padding() // Padding general para el VStack de éxito
                            
                        } else {
                            // MARK: - Mensaje de Error
                            VStack {
                                Image(systemName: "exclamationmark.triangle.fill")
                                    .resizable()
                                    .frame(width: 50, height: 50)
                                    .foregroundColor(.orange)
                                    .padding(.bottom, 10)
                                Text("No se pudo cargar el perfil del jugador.")
                                    .font(.headline)
                                if let errorMessage = localErrorMessage {
                                    Text(errorMessage)
                                        .font(.subheadline)
                                        .foregroundColor(.red)
                                        .multilineTextAlignment(.center)
                                        .padding(.horizontal)
                                } else if let vmError = appData.playersViewModel!.errorMessage {
                                    Text(vmError)
                                        .font(.subheadline)
                                        .foregroundColor(.red)
                                        .multilineTextAlignment(.center)
                                        .padding(.horizontal)
                                }
                                Button("Reintentar") {
                                    Task {
                                        await loadPlayerFromUserDefaults()
                                        // Si después de reintentar se carga, automáticamente irá a TabBarView
                                        // No necesitas showTabbar = true aquí, loadPlayerFromUserDefaults ya lo hace
                                    }
                                }
                                .padding()
                                .buttonStyle(.borderedProminent)
                            }
                            .padding() // Padding general para el VStack de error
                        }
                        
                        Spacer() // Empuja el contenido al centro vertical
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity) // Asegura que el VStack ocupe toda la pantalla
                    .onAppear {
                        // Se ejecuta cuando la vista aparece por primera vez
                        if fetchedPlayer == nil && isLoadingPlayer { // Solo carga si no se ha cargado antes y está en estado de carga
                            Task {
                                await loadPlayerFromUserDefaults()
                            }
                        }
                    }
                    // Si la TabBarView es la vista principal después de la carga exitosa,
                    // no usarías NavigationView aquí, sino en la vista principal de la aplicación
                    // o en la TabBarView misma si cada pestaña necesita su propia navegación.
                    // Aquí, he eliminado NavigationView y .navigationBarHidden, etc.
                    // porque la idea es que ChargeView sea una pantalla de inicio/carga
                    // que luego se reemplaza por la TabBarView.
                }
            }
        }

        // MARK: - Función para cargar el jugador
        @MainActor
        private func loadPlayerFromUserDefaults() async {
            isLoadingPlayer = true
            localErrorMessage = nil
            appData.playersViewModel!.errorMessage = nil // Limpiar cualquier error del ViewModel (usa . en vez de !)

            if let playerID = UserDefaults.standard.string(forKey: "playerid") {
                print("💾 ID de jugador recuperado de UserDefaults: \(playerID)")
                let player = await appData.playersViewModel!.fetchPlayerByID(id: playerID) // Usa . en vez de !

                appData.playersViewModel!.currentPlayer = player // Asigna el jugador al ViewModel
                fetchedPlayer = player // Asigna el jugador a la variable de estado local

                print("------>\(appData.playersViewModel!.currentPlayer?.username ?? "N/A") vamos!!!")

                if fetchedPlayer == nil {
                    localErrorMessage = "No se encontraron datos para el ID: \(playerID)"
                    isLoadingPlayer = false // Asegúrate de detener la carga en caso de error
                } else {
                    // Si el jugador se cargó con éxito, mostramos la TabBarView
                    isLoadingPlayer = false
                    showTabbar = true // Esto disparará la presentación de TabBarView
                }
            } else {
                localErrorMessage = "No hay ID de jugador guardado en UserDefaults."
                print("⚠️ No hay ID de jugador guardado en UserDefaults.")
                isLoadingPlayer = false // Detiene la carga en caso de no haber ID
            }
        }
}

// MARK: - Preview para ChargeView
#Preview {
    // Para la preview, simula que el playerID ya está en UserDefaults
    UserDefaults.standard.set("testPlayer123", forKey: "playerid")

    return NavigationView {
        ChargeView()
            .environmentObject(AppData(baseURL: "http://mockapi.com")) // Pasa un baseURL para la preview
    }
}
