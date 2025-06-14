//
//  ProfilePageView.swift
//  RodMon
//
//  Created by Isain Rodriguez Noreña on 23/4/25.
//

import SwiftUI

struct ProfilePageView: View {
    
    // Elimina playerDataManager si no lo vas a usar para el currentPlayer
    // @EnvironmentObject var playerDataManager: PlayerDataManager

    // Declara appData como EnvironmentObject
    @EnvironmentObject var appData: AppData

    @Binding var isPresented: Bool
    @State var nickname: String
    @State var email: String
    @State var telefono: String
    @State var equipo: String
    @State var cancha: String

    // Tu inicializador puede mantenerse igual, o puedes usar los datos del jugador cargado
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
                            // AHORA ACCEDEMOS A appData.playersViewModel.currentPlayer
                            if let player = appData.playersViewModel!.currentPlayer {
                                Text("Bienvenido, \(player.username)!")
                                Text("Tu email: \(player.email)")
                                // Puedes usar player.profilePictureURL para cargar la imagen real
                                // AsyncImage(url: URL(string: player.profilePictureURL ?? "")) { image in
                                //     image.resizable().scaledToFit()
                                // } placeholder: {
                                //     ProgressView()
                                // }
                                // .frame(width: 90, height: 90)
                                // .clipShape(Circle())
                                // .overlay(Circle().stroke(Color.blue, lineWidth: 2))

                                ProfileView(imageName: "hanny", circleSize: 100, imageSize: 90, shouldAnimateBorder: true) // Usa la imagen por defecto por ahora
                            } else {
                                Text("No hay ningún jugador activo en memoria.")
                                ProfileView(imageName: "hanny", circleSize: 100, imageSize: 90, shouldAnimateBorder: true) // Muestra un placeholder
                            }
                            HStack(spacing: 20) {
                                Button {
                                    print("Abrir cámara")
                                } label: {
                                    ZStack {
                                        Circle()
                                            .fill(Color.gray.opacity(0.5))
                                            .frame(width: 40, height: 40)
                                        Image(systemName: "camera.fill")
                                            .font(.title2)
                                            .foregroundColor(.white)
                                    }
                                }
                                .buttonStyle(PlainButtonStyle())
                                Button {
                                    print("Seleccionar de galería")
                                } label: {
                                    ZStack {
                                        Circle()
                                            .fill(Color.gray.opacity(0.5))
                                            .frame(width: 40, height: 40)
                                        Image(systemName: "photo.fill.on.rectangle.fill")
                                            .font(.title2)
                                            .foregroundColor(.white)
                                    }
                                }
                                .buttonStyle(PlainButtonStyle())
                                Button {
                                    print("Cambiar color")
                                } label: {
                                    ZStack {
                                        Circle()
                                            .fill(Color.gray.opacity(0.5))
                                            .frame(width: 40, height: 40)
                                        Image(systemName: "paintpalette.fill")
                                            .font(.title2)
                                            .foregroundColor(.white)
                                    }
                                }
                                .buttonStyle(PlainButtonStyle())
                            }
                        }
                        Spacer()
                    }
                    .frame(maxWidth: .infinity)
                    .listRowBackground(Color.clear)
                }

                Section(header: Text("Información de Perfil")) {
                    HStack {
                        Text("Nickname")
                        Spacer()
                        // Si quieres que el TextField muestre el nombre del jugador, inicializa el @State con él
                        // Esto se podría hacer en un .onAppear o en el init si pasas el jugador
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
                        .foregroundColor(.blue)
                    }
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Guardar") {
                        // Aquí iría la lógica para guardar los cambios en appData.playersViewModel.currentPlayer
                        // Por ejemplo:
                       /* if var playerToUpdate = appData.playersViewModel!.currentPlayer {
                            playerToUpdate.username = nickname // Actualiza las propiedades del jugador
                            playerToUpdate.email = email
                            // Aquí puedes llamar a un método en tu PlayersViewModel para guardar
                            // await appData.playersViewModel.updatePlayer(playerToUpdate)
                            print("Guardando perfil...")
                        } else {
                            print("No hay jugador para guardar.")
                        }
                        isPresented = false*/
                    }
                    .foregroundColor(.blue)
                }
            }
            // Si quieres que los campos de texto se inicialicen con los datos del jugador cargado
            .onAppear {
                if let player = appData.playersViewModel!.currentPlayer {
                    nickname = player.username
                    email = player.email
                    // Carga los demás campos si existen en tu modelo Player
                    // telefono = player.phone // Si tu Player tiene un campo phone
                    // equipo = player.team?.name ?? "" // Si Player tiene un campo team y este tiene nombre
                    // cancha = player.location ?? "" // Si Player tiene un campo location
                }
            }
        }
    }
}

struct ProfilePageView_Previews: PreviewProvider {
    @State static var isPresented = true
    
    static var previews: some View {
        ProfilePageView(isPresented: $isPresented)
            .environmentObject(PlayerDataManager())
    }
}

#Preview {
    @State var isPresentedPreview = true
    return ProfilePageView(isPresented: $isPresentedPreview)
        .environmentObject(PlayerDataManager())
}
