//
//  Login.swift
//  CourtClan
//
//  Created by Isain Rodriguez Noreña on 20/5/25.
//

import SwiftUI


struct Login: View {
    
    @EnvironmentObject var appData: AppData
    @EnvironmentObject var appUtils: AppUtils
    
    @State private var emailID: String = ""
    @State private var password: String = ""
    @State private var isEmailValid: Bool = true
    @State private var isPasswordVisible: Bool = false
    let placeholderColor = Color(.gray) // Define el color del placeholder
    var onLoginSuccess: () -> Void
    
    var body: some View {
        NavigationView {
            // Asegúrate de que Login esté dentro de un NavigationView
            content
        }
        .navigationViewStyle(StackNavigationViewStyle()) // Recomendado para consistencia
    }
    
    var content: some View {
        VStack {
            Spacer() // Pushes content towards the center vertically
            
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
                        .padding(.leading, 5) // Ajusta el espacio después del icono
                        
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
                            // TODO: Implement forgot password functionality
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
                        // Lógica de inicio de sesión aquí
                        print("Iniciar Sesión Tapped")
                        // Si el inicio de sesión es exitoso, llama al completion handler
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
                            // TODO: Implement Google login functionality
                            print("Login with Google Tapped")
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
                            // TODO: Implement iOS login functionality (e.g., Sign in with Apple)
                            print("Login with iOS Tapped")
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
                }
            }
            .padding()
            .frame(maxWidth: .infinity)
            
            Spacer() // Pushes content towards the center vertically
            
            VStack(spacing: 10) {
                HStack(spacing: 10) {
                    Button {
                        // TODO: Implement Privacy Policy navigation
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
                        // TODO: Implement Terms and Conditions navigation
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
                        // TODO: Implement registration navigation
                        print("Register Tapped")
                    } label: {
                        Text("Regístrate")
                            .font(.footnote)
                            .fontWeight(.semibold)
                            .foregroundColor(.ccSecondary)
                    }
                }
            }
            .padding(.bottom) // Adds some padding at the very bottom
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center) // Center the entire content
        .background(
            ZStack {
              /*Circle()
               .fill(Color.mint)
               .scaleEffect(1.5) // Ajusta el tamaño
               .offset(x: 0, y: 0) // Ajusta la posición*/

              Image("fondo") // Reemplaza "nombreDeTuImagen" con el nombre de tu imagen en Assets.xcassets
               .resizable()
               .scaledToFit()
               .frame(width: 1250, height: 1250) // Ajusta el tamaño de la imagen dentro del círculo
               //.clipShape(Circle()) // Recorta la imagen a la forma del círculo
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
    Login(onLoginSuccess: {})
        .environmentObject(AppUtils())
        .environmentObject(AppData())
}
