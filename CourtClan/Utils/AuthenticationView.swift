//
//  AuthenticationView.swift
//  CourtClan
//
//  Created by Isain Rodriguez Noreña on 28/5/25.
//

import SwiftUI
import Firebase
import GoogleSignIn
import FirebaseAuth

class AuthenticationView: ObservableObject {

    @Published var isSignSuccessed: Bool = false
    @Published var authenticationError: String?

    // PlayersViewModel se inicializará desde CourtClanApp y se le asignará aquí.
    // También asegúrate de que tiene su baseURL real en su init.
    var playersVM = PlayersViewModel()

    // PlayerDataManager se inyectará desde CourtClanApp.
    var playerDataManager: PlayerDataManager?

    func signInWithGoogle() {
        // Limpiar estados previos al intentar iniciar sesión
        authenticationError = nil
        isSignSuccessed = false

        guard let clientID = FirebaseApp.app()?.options.clientID else {
            let errorDescription = "Error: clientID de Firebase no encontrado."
            print(errorDescription)
            self.authenticationError = errorDescription
            return
        }

        let config = GIDConfiguration(clientID: clientID)
        // Usando la configuración y método de signIn que proporcionaste, aunque son deprecated
        GIDSignIn.sharedInstance.configuration = config // Esta línea es deprecated

        GIDSignIn.sharedInstance.signIn(withPresenting: Application_utility.rootViewController) { [weak self] googleSignInResult, error in
            guard let self = self else { return }

            if let error = error {
                let errorDescription = "Error al iniciar sesión con Google: \(error.localizedDescription)"
                print(errorDescription)
                self.isSignSuccessed = false
                self.authenticationError = errorDescription
                return
            }

            guard
                let gUser = googleSignInResult?.user,
                let idToken = gUser.idToken
            else {
                let errorDescription = "Error: No se pudo obtener el usuario o el ID Token de Google después del inicio de sesión."
                print(errorDescription)
                self.isSignSuccessed = false
                self.authenticationError = errorDescription
                return
            }

            let accessToken = gUser.accessToken

            // --- Información del Usuario de Google (GIDGoogleUser) ---
            print("\n--- Información Detallada del Usuario de Google (GIDGoogleUser) ---")
            print("Google User ID (sub): \(gUser.userID ?? "N/A")")
            print("Email: \(gUser.profile?.email ?? "N/A")")
            print("Nombre Completo: \(gUser.profile?.name ?? "N/A")")
            print("Nombre de Pila (Given Name): \(gUser.profile?.givenName ?? "N/A")")
            print("Apellido (Family Name): \(gUser.profile?.familyName ?? "N/A")")
            if let imageURL = gUser.profile?.imageURL(withDimension: 200) {
                print("URL de Foto de Perfil (200x200): \(imageURL.absoluteString)")
            } else {
                print("URL de Foto de Perfil: N/A")
            }
            print("ID Token (parcial): \(idToken.tokenString.prefix(30))...")
            print("Access Token (parcial): \(accessToken.tokenString.prefix(30))...")
            print("Scopes Otorgados: \(gUser.grantedScopes?.joined(separator: ", ") ?? "Ninguno")")
            print("---------------------------------------------------\n")
            
            // Por el momento
            let playerId = "aac386f1-26bc-4cc5-9d90-8513581bb546"
            UserDefaults.standard.set(playerId, forKey: "playerid")
            if let savedPlayerId = UserDefaults.standard.string(forKey: "playerid") {
                print("El playerId guardado es: \(savedPlayerId)")
            } else {
                print("No se encontró ningún playerId guardado.")
            }
            // Por el momento
            
            let credential = GoogleAuthProvider.credential(withIDToken: idToken.tokenString, accessToken: accessToken.tokenString)

            Auth.auth().signIn(with: credential) { [weak self] firebaseAuthResult, firebaseError in
                guard let self = self else { return }

                if let firebaseError = firebaseError {
                    let errorDescription = "Error al iniciar sesión en Firebase con credenciales de Google: \(firebaseError.localizedDescription)"
                    print(errorDescription)
                    self.isSignSuccessed = false
                    self.authenticationError = errorDescription
                    return
                }

                guard let firebaseUser = firebaseAuthResult?.user else {
                    let errorDescription = "Error: No se pudo obtener el usuario de Firebase después del inicio de sesión con credenciales de Google."
                    print(errorDescription)
                    self.isSignSuccessed = false
                    self.authenticationError = errorDescription
                    return
                }

                // --- Información del Usuario de Firebase (User) ---
                print("\n--- Información Detallada del Usuario de Firebase (User) ---")
                print("Firebase User ID (UID): \(firebaseUser.uid)")
                print("Email: \(firebaseUser.email ?? "N/A")")
                print("Nombre para mostrar: \(firebaseUser.displayName ?? "N/A")")
                if let photoURL = firebaseUser.photoURL {
                    print("URL de Foto de Perfil (Firebase): \(photoURL.absoluteString)")
                } else {
                    print("URL de Foto de Perfil (Firebase): N/A")
                }
                print("Proveedor de Autenticación (Provider ID): \(firebaseUser.providerID)")
                print("Es anónimo: \(firebaseUser.isAnonymous)")
                print("Email verificado: \(firebaseUser.isEmailVerified)")

                if let providerData = firebaseUser.providerData.first(where: { $0.providerID == GoogleAuthProviderID }) {
                    print("   --- Información Específica del Proveedor (Google en Firebase) ---")
                    print("   Google UID (dentro de Firebase): \(providerData.uid)")
                    print("   Google Display Name: \(providerData.displayName ?? "N/A")")
                    print("   Google Email: \(providerData.email ?? "N/A")")
                    print("   Google Photo URL: \(providerData.photoURL?.absoluteString ?? "N/A")")
                    print("   ----------------------------------------------------")
                }
                print("---------------------------------------------------\n")

                print("Inicio de sesión exitoso en Firebase. Email: \(String(firebaseUser.email?.description ?? "No email"))")
                self.isSignSuccessed = true
                self.authenticationError = nil

                // Llama a la función para crear/obtener el jugador en tu backend
                // Envuelve la llamada asíncrona en un Task y usa do-catch para manejar errores.
                Task {
                    do {
                        // createPlayerProfile ahora devuelve el Player y lanza errores
                        let createdPlayer = try await self.createPlayerProfile(googleUser: gUser, firebaseUser: firebaseUser)

                        // Si llegamos aquí, el jugador se creó/obtuvo con éxito del backend.
                        // Ahora lo guardamos en el PlayerDataManager local.
                        await MainActor.run { // Asegura que esta actualización ocurra en el hilo principal
                            //self.playerDataManager?.setCurrentPlayer(createdPlayer) // <-- ¡CORREGIDO AQUÍ!
                            // Si estás SEGURO de que createdPlayer.id NUNCA es nil
                            let playerID = createdPlayer.id // Esto funcionará si createdPlayer.id es de tipo String (no-opcional)
                            UserDefaults.standard.set(playerID, forKey: "playerid")
                            print("✅ Player ID (de backend) guardado en UserDefaults: \(playerID)")
                            print("✅ Jugador guardado localmente a través de PlayerDataManager: \(createdPlayer.username)")
                            print("✅ Jugador guardado localmente a través de PlayerDataManager id: \(createdPlayer.id)")
                            print("✅ Jugador guardado localmente a través de PlayerDataManager id------>: \(self.playerDataManager?.player?.username)")
                            
                        }
                    } catch {
                        // Maneja cualquier error que venga de createPlayerProfile (que a su vez viene de playersVM)
                        await MainActor.run {
                            self.authenticationError = "Fallo en la gestión del perfil de jugador: \(error.localizedDescription)"
                            print("❌ Error en createPlayerProfile o playersVM: \(error.localizedDescription)")
                            self.isSignSuccessed = false // Si falla la creación del perfil, el login no es "completo"
                        }
                    }
                }
            }
        }
    }

    func signOut() {
        GIDSignIn.sharedInstance.signOut()
        do {
            try Auth.auth().signOut()
            self.isSignSuccessed = false
            self.authenticationError = nil
            // ¡Importante! Cuando el usuario cierra sesión, elimina el jugador guardado localmente
            self.playerDataManager?.clearCurrentPlayer()
            print("Jugador local eliminado tras cerrar sesión.")
        } catch let signOutError as NSError {
            let errorDescription = "Error al cerrar sesión en Firebase: \(signOutError.localizedDescription)"
            print(errorDescription)
            self.authenticationError = errorDescription
        }
    }

    // Esta función ahora devuelve un `Player` y puede lanzar errores.
    @MainActor // Asegura que esta función se ejecute en el hilo principal
    private func createPlayerProfile(googleUser: GIDGoogleUser, firebaseUser: FirebaseAuth.User) async throws -> Player { // <-- ¡Añadido 'throws -> Player'!

        // Mapea los datos del usuario de Google/Firebase a los campos de tu PlayerCreateRequest
        let username = firebaseUser.displayName ?? googleUser.profile?.givenName ?? firebaseUser.email?.split(separator: "@").first?.description ?? "Usuario"
        let email = firebaseUser.email ?? "no-email@example.com"

        // ¡IMPORTANTE sobre passwordHash!
        // Para logins con Google, no obtienes una contraseña. Tu backend debe manejar esto.
        let passwordHash = "SOCIAL_AUTH_VIA_GOOGLE" // Placeholder para tu backend

        let fullName = firebaseUser.displayName ?? googleUser.profile?.name
        let profilePictureUrl = firebaseUser.photoURL?.absoluteString ?? googleUser.profile?.imageURL(withDimension: 400)?.absoluteString

        // Campos que Google/Firebase no proporcionan directamente, asigna nil o valores por defecto
        let bio: String? = nil
        let location: String? = nil
        let dateOfBirth: Date? = nil
        let gender: String? = nil
        let preferredPosition: String? = nil
        let skillLevelId: String? = nil // Puede ser un valor por defecto o pedir al usuario que lo seleccione
        let currentLevel: Int? = 1 // Valor inicial
        let totalXp: Int? = 0 // Valor inicial
        let gamesPlayed: Int? = 0
        let gamesWon: Int? = 0
        let winPercentage: Double? = 0.0
        let avgPointsPerGame: Double? = 0.0
        let avgAssistsPerGame: Double? = 0.0
        let avgReboundsPerGame: Double? = 0.0
        let avgBlocksPerGame: Double? = 0.0
        let avgStealsPerGame: Double? = 0.0
        let isPublic: Bool = true // Asumiendo público por defecto
        let isActive: Bool = true // Asumiendo activo por defecto
        let currentTeamId: String? = nil
        let marketValue: Double? = 0.0
        let isFreeAgent: Bool = true

        print("Intentando crear/actualizar perfil de jugador en el backend para Firebase UID: \(firebaseUser.uid)")

        // Llama al método createPlayer de PlayersViewModel
        // Usa un bloque do-catch para manejar los errores que PlayersViewModel.createPlayer pueda lanzar
        do {
            let player = try await playersVM.createPlayer( // <-- ¡Captura el jugador aquí!
                username: username,
                email: email,
                passwordHash: passwordHash,
                fullName: fullName,
                bio: bio,
                profilePictureUrl: profilePictureUrl,
                location: location,
                dateOfBirth: dateOfBirth,
                gender: gender,
                preferredPosition: preferredPosition,
                skillLevelId: skillLevelId,
                currentLevel: currentLevel,
                totalXp: totalXp,
                gamesPlayed: gamesPlayed,
                gamesWon: gamesWon,
                winPercentage: winPercentage,
                avgPointsPerGame: avgPointsPerGame,
                avgAssistsPerGame: avgAssistsPerGame,
                avgReboundsPerGame: avgReboundsPerGame,
                avgBlocksPerGame: avgBlocksPerGame,
                avgStealsPerGame: avgStealsPerGame,
                isPublic: isPublic,
                isActive: isActive,
                currentTeamId: currentTeamId,
                marketValue: marketValue,
                isFreeAgent: isFreeAgent
            )
            print("Perfil de jugador creado/actualizado exitosamente en el backend para UID: \(firebaseUser.uid)")
            return player // <-- ¡Devuelve el jugador!

        } catch {
            // Manejo del error:
            print("Error al crear el perfil de jugador en PlayersViewModel: \(error.localizedDescription)")

            // Actualiza el errorMessage de AuthenticationView para que la UI pueda mostrarlo
            self.authenticationError = "Fallo al crear el perfil de jugador en el sistema de backend: \(error.localizedDescription)"

            // ¡Vuelve a lanzar el error! Esto es crucial porque la función `createPlayerProfile`
            // también está marcada con `throws`. Si no lo relanzas, el `Task` en `signInWithGoogle`
            // no sabrá que hubo un problema.
            throw error // <-- ¡RELANZA EL ERROR!
        }
    }
}
