//
//  ProfilePageView.swift
//  RodMon
//
//  Created by Isain Rodriguez Noreña on 23/4/25.
//

import SwiftUI

struct ProfilePageView: View {
    @Binding var isPresented: Bool
    @State var nickname: String
    @State var email: String
    @State var telefono: String
    @State var equipo: String
    @State var cancha: String
    
    init(isPresented: Binding<Bool>, nickname: String = "HannyCR", email: String = "hanny@example.com", telefono: String = "123-456-7890", equipo: String = "Los Leones", cancha: String = "Camp Nou") {
        _isPresented = isPresented
        _nickname = State(initialValue: nickname)
        _email = State(initialValue: email)
        _telefono = State(initialValue: telefono)
        _equipo = State(initialValue: equipo)
        _cancha = State(initialValue: cancha)
    }
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Avatar")) {
                    HStack(alignment: .center) {
                        Spacer()
                        VStack(alignment: .center) {
                            ProfileView(imageName: "hanny", circleSize: 100, imageSize: 90, shouldAnimateBorder: true)
                            HStack(spacing: 20) {
                                Button {
                                    print("Abrir cámara")
                                    // Acción para abrir la cámara
                                } label: {
                                    ZStack {
                                        Circle()
                                            .fill(Color.gray.opacity(0.5)) // Transparent background for the circle
                                            .frame(width: 40, height: 40)
                                        Image(systemName: "camera.fill")
                                            .font(.title2)
                                            .foregroundColor(.white)
                                    }
                                }
                                .buttonStyle(PlainButtonStyle()) // Make only the button tappable
                                Button {
                                    print("Seleccionar de galería")
                                    // Acción para seleccionar de la galería
                                } label: {
                                    ZStack {
                                        Circle()
                                            .fill(Color.gray.opacity(0.5)) // Transparent background for the circle
                                            .frame(width: 40, height: 40)
                                        Image(systemName: "photo.fill.on.rectangle.fill")
                                            .font(.title2)
                                            .foregroundColor(.white)
                                    }
                                }
                                .buttonStyle(PlainButtonStyle()) // Make only the button tappable
                                Button {
                                    print("Cambiar color")
                                    // Acción para cambiar el color (puedes mostrar un ColorPicker aquí)
                                } label: {
                                    ZStack {
                                        Circle()
                                            .fill(Color.gray.opacity(0.5)) // Transparent background for the circle
                                            .frame(width: 40, height: 40)
                                        Image(systemName: "paintpalette.fill")
                                            .font(.title2)
                                            .foregroundColor(.white)
                                    }
                                }
                                .buttonStyle(PlainButtonStyle()) // Make only the button tappable
                            }
                        }
                        Spacer()
                    }
                    .frame(maxWidth: .infinity)
                    .listRowBackground(Color.clear) // Make the section row background transparent
                }
                
                Section(header: Text("Información de Perfil")) {
                    HStack {
                        Text("Nickname")
                        Spacer()
                        TextField("Nickname", text: $nickname)
                            .multilineTextAlignment(.trailing)
                    }
                    HStack {
                        Text("Email")
                        Spacer()
                        TextField("Email", text: $email)
                            .keyboardType(.emailAddress)
                            .autocapitalization(.none)
                            .multilineTextAlignment(.trailing)
                    }
                    HStack {
                        Text("Teléfono")
                        Spacer()
                        TextField("Teléfono", text: $telefono)
                            .keyboardType(.phonePad)
                            .multilineTextAlignment(.trailing)
                    }
                }
                
                Section(header: Text("Información Adicional")) {
                    HStack {
                        Text("Equipo")
                        Spacer()
                        TextField("Equipo", text: $equipo)
                            .multilineTextAlignment(.trailing)
                    }
                    HStack {
                        Text("Cancha")
                        Spacer()
                        TextField("Cancha", text: $cancha)
                            .multilineTextAlignment(.trailing)
                    }
                }
            }
            .navigationTitle("Perfil")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button {
                        isPresented = false
                    } label: {
                        HStack {
                            Image(systemName: "chevron.left")
                            Text("Atrás")
                        }
                        .foregroundColor(.blue) // Changed to a default color
                    }
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Guardar") {
                        // Aquí iría la lógica para guardar los cambios
                        print("Guardando perfil...")
                        print("Nickname: \(nickname)")
                        print("Email: \(email)")
                        print("Teléfono: \(telefono)")
                        print("Equipo: \(equipo)")
                        print("Cancha: \(cancha)")
                        isPresented = false // Opcional: Regresar al guardar
                    }
                    .foregroundColor(.blue) // Changed to a default color
                }
            }
        }
    }
}

struct ProfilePageView_Previews: PreviewProvider {
    @State static var isPresented = true
    
    static var previews: some View {
        ProfilePageView(isPresented: $isPresented)
    }
}

#Preview {
    @State var isPresentedPreview = true
    return ProfilePageView(isPresented: $isPresentedPreview)
}
