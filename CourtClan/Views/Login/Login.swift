//
//  Login.swift
//  CourtClan
//
//  Created by Isain Rodriguez Noreña on 20/5/25.
//

import SwiftUI
import Firebase
import FirebaseAuth
import GoogleSignIn
import GoogleSignInSwift


struct Login: View {

    @EnvironmentObject var appData: AppData
    @EnvironmentObject var appUtils: AppUtils

    // ¡CAMBIO CLAVE AQUÍ!
    // En lugar de @StateObject, usa @EnvironmentObject para obtener la instancia ya configurada
    @EnvironmentObject var authenticationVM: AuthenticationView // Renombrado a authenticationVM para mayor claridad

    @State private var emailID: String = ""
    @State private var password: String = ""
    @State private var isEmailValid: Bool = true
    @State private var isPasswordVisible: Bool = false
    let placeholderColor = Color(.gray)
    var onLoginSuccess: () -> Void
    @State private var loginError = ""


    var body: some View {
        NavigationView {
            content
        }
        .navigationViewStyle(StackNavigationViewStyle())
        // Observa los cambios en isSignSuccessed de AuthenticationView (ahora authenticationVM)
        .onChange(of: authenticationVM.isSignSuccessed) { success in // Usa authenticationVM
            if success {
                onLoginSuccess() // Si es exitoso, llama a la acción de éxito
                loginError = "" // Limpia cualquier error de login anterior
            }
        }
        // Observa los cambios en authenticationError de AuthenticationView (ahora authenticationVM)
        .onChange(of: authenticationVM.authenticationError) { errorMessage in // Usa authenticationVM
            if let errorMessage = errorMessage {
                self.loginError = errorMessage // Muestra el error de autenticación de Google/Firebase
            } else {
                self.loginError = "" // Limpia el error si no hay ninguno
            }
        }
    }


    var content: some View {
        VStack {
            Spacer()

            VStack(alignment: .leading, spacing: 20) {

                Text(LocalizedStringResource("app_name", comment: "Login title"))
                    .font(.custom("Chalkboard SE", size: 40))
                    .fontWeight(.heavy)
                    .foregroundColor(.ccSecondary)

                Text(LocalizedStringResource("greeting_message", comment: "Login title"))
                    .font(.callout)
                    .fontWeight(.semibold)
                    .foregroundStyle(.gray)
                    .padding(.top, -5)

                VStack(spacing: 15) {
                    HStack {
                        Image(systemName: "at")
                            .foregroundColor(placeholderColor)
                        TextField("Email", text: $emailID)
                            .foregroundColor(.primary)
                            .accentColor(.primary)
                            .placeholder(when: emailID.isEmpty) {
                                Text("Email").foregroundColor(placeholderColor)
                            }
                    }
                    .padding(.horizontal)
                    .frame(height: 45)
                    .background(Color(.secondarySystemBackground))
                    .cornerRadius(10)
                    .opacity(0.8)
                    .onChange(of: emailID) { _ in
                        isEmailValid = appUtils.isValidEmail(emailID)
                    }
                    if !isEmailValid {
                        Text("Por favor, introduce un email válido.")
                            .font(.caption)
                            .foregroundColor(.red)
                    }

                    HStack {
                        Image(systemName: "lock.fill")
                            .foregroundColor(placeholderColor)
                        Group {
                            if isPasswordVisible {
                                TextField("Contraseña", text: $password)
                            } else {
                                SecureField("Contraseña", text: $password)
                            }
                        }
                        .foregroundColor(.primary)
                        .accentColor(.primary)
                        .placeholder(when: password.isEmpty) {
                            Text("Contraseña").foregroundColor(placeholderColor)
                        }
                        .padding(.leading, 5)

                        Button {
                            isPasswordVisible.toggle()
                        } label: {
                            Image(systemName: isPasswordVisible ? "eye.slash.fill" : "eye.fill")
                                .foregroundColor(.gray)
                        }
                        .padding(.trailing)
                    }
                    .padding(.horizontal)
                    .frame(height: 45)
                    .background(Color(.secondarySystemBackground))
                    .cornerRadius(10)
                    .opacity(0.8)

                    HStack {
                        Spacer()
                        Button {
                            print("Forgot Password Tapped")
                        } label: {
                            Text("¿Olvidaste tu contraseña?")
                                .font(.footnote)
                                .foregroundColor(.ccSecondary)
                        }
                    }
                }

                VStack(spacing: 15) {
                    Button {
                        // Lógica de inicio de sesión aquí (para email/contraseña)
                        print("Iniciar Sesión Tapped")
                        // Si el inicio de sesión es exitoso, llama al completion handler
                        // Esto es para el login tradicional, no para Google.
                         onLoginSuccess()
                    } label: {
                        Text("Iniciar Sesión")
                            .fontWeight(.semibold)
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(.ccSecondary)
                            .cornerRadius(10)
                    }


                    HStack(spacing: 15) {
                        Button {
                            // Llama a signInWithGoogle usando la instancia inyectada
                            authenticationVM.signInWithGoogle() // Usa authenticationVM
                        } label: {
                            HStack {
                                Image("google_logo") // Asegúrate de tener esta imagen en tus assets
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: 20, height: 20)
                                Text("Google")
                                    .fontWeight(.semibold)
                            }
                            .foregroundColor(.black)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color(.systemGray6))
                            .cornerRadius(10)
                        }

                        Button {
                            print("Login with iOS Tapped")
                            // TODO: Implementar Sign In with Apple aquí
                        } label: {
                            HStack {
                                Image(systemName: "apple.logo")
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: 20, height: 20)
                                Text("Apple")
                                    .fontWeight(.semibold)
                            }
                            .foregroundColor(.black)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color(.systemGray6))
                            .cornerRadius(10)
                        }
                    }

                    // Muestra el mensaje de error si existe
                    if !loginError.isEmpty {
                        Text(loginError)
                            .foregroundColor(.red)
                            .font(.footnote)
                            .padding(.top, 5)
                            .multilineTextAlignment(.center)
                    }
                }
            }
            .padding()
            .frame(maxWidth: .infinity)

            Spacer()

            VStack(spacing: 10) {
                HStack(spacing: 10) {
                    Button {
                        print("Privacy Policy Tapped")
                    } label: {
                        Text("Política de privacidad")
                            .font(.footnote)
                            .foregroundColor(.gray)
                    }

                    Text("·")
                        .font(.footnote)
                        .foregroundColor(.gray)

                    Button {
                        print("Términos y condiciones Tapped")
                    } label: {
                        Text("Términos y condiciones")
                            .font(.footnote)
                            .foregroundColor(.gray)
                    }
                }

                HStack {
                    Text("¿No tienes una cuenta?")
                        .font(.footnote)
                        .foregroundColor(.gray)

                    Button {
                        print("Register Tapped")
                    } label: {
                        Text("Regístrate")
                            .font(.footnote)
                            .fontWeight(.semibold)
                            .foregroundColor(.ccSecondary)
                    }
                }
            }
            .padding(.bottom)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
        .background(
            ZStack {
                Image("fondo")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 1250, height: 1250)
                    .opacity(0.4)
                    .background(Color.black)
            }
            .ignoresSafeArea()
        )
        .navigationBarHidden(true)
    }
}

// Helper extension for placeholder functionality in TextField
extension View {
    func placeholder<Content: View>(
        when shouldShow: Bool,
        alignment: Alignment = .leading,
        @ViewBuilder placeholder: () -> Content) -> some View {

            ZStack(alignment: alignment) {
                placeholder().opacity(shouldShow ? 1 : 0)
                self
            }
        }
}

#Preview {
    // Para el preview, también necesitas inyectar los EnvironmentObjects
    Login(onLoginSuccess: {})
        .environmentObject(AppUtils())
        .environmentObject(AppData())
        // ¡Importante para el preview también!
        .environmentObject(AuthenticationView()) // Aquí no tiene PlayersViewModel inyectado
        .environmentObject(PlayersViewModel()) // Tendrías que mockearlo o inicializarlo
}
