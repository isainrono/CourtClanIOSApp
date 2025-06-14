//
//  CourtClanApp.swift
//  CourtClan
//
//  Created by Isain Rodriguez Noreña on 20/5/25.
//

import SwiftUI
import Firebase
import GoogleSignIn
import FirebaseAuth // Necesario para Auth y GIDConfiguration (aunque sea indirectamente a través de AuthenticationView)

@main
struct CourtClanApp: App {
    
    @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate
    @StateObject private var appData = AppData()
    @StateObject private var appUtils = AppUtils() // Asumo que AppUtils contiene Application_utility.rootViewController

    // 1. Declara e inicializa tus ViewModels que gestionarán estados y servicios
    @StateObject private var playersVM = PlayersViewModel()
    @StateObject private var authenticationVM = AuthenticationView()
    @StateObject private var playerDataManager = PlayerDataManager()
    
    init() {
        // 2. Aquí inyectamos playersVM en authenticationVM
        // Esto asegura que authenticationVM tenga una referencia válida a playersVM
        // antes de que signInWithGoogle sea llamado.
        authenticationVM.playersVM = playersVM
    }
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(appData)
                .environmentObject(appUtils)
                // 3. Haz que los ViewModels estén disponibles en el entorno
                // Esto permite que ContentView y sus vistas hijas los accedan usando @EnvironmentObject
                .environmentObject(authenticationVM)
                .environmentObject(playersVM)
                .environmentObject(playerDataManager)
        }
    }
}

class AppDelegate: NSObject, UIApplicationDelegate {
    func application(_ application: UIApplication,
                     didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
        FirebaseApp.configure() // Aquí se inicializa Firebase
        print("Firebase se ha configurado correctamente.") // Añadir un log para confirmar
        return true
    }

    // Este método es crucial para que GoogleSignIn redirija correctamente después del login
    @available(iOS 9.0, *)
    func application(_ app: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey : Any] = [:]) -> Bool {
        let handled = GIDSignIn.sharedInstance.handle(url) // Verifica si la URL fue manejada por GIDSignIn
        print("URL recibida por AppDelegate: \(url.absoluteString), manejada por GIDSignIn: \(handled)") // Log para depuración
        return handled
    }
}
