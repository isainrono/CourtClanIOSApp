//
//  CaptainCardView.swift
//  CourtClan
//
//  Created by Isain Rodriguez Noreña on 23/7/25.
//

import SwiftUI

struct CaptainCardView: View {
    let captainId: String

    @State private var captain: Player?
    @State private var isLoading = false
    @State private var errorMessage: String?

    @EnvironmentObject var playerViewModel: PlayersViewModel

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Capitán")
                .font(.title2)
                .bold()
                .padding(.bottom, 5)

            if isLoading {
                ProgressView("Cargando capitán...")
            } else if let errorMessage = errorMessage {
                Text("Error: \(errorMessage)")
                    .foregroundColor(.red)
            } else if let captain = captain {
                HStack(spacing: 16) {
                    // Imagen del perfil
                    if let urlString = captain.profilePictureUrl,
                       let url = URL(string: urlString) {
                        AsyncImage(url: url) { image in
                            image
                                .resizable()
                                .scaledToFill()
                                .frame(width: 80, height: 80)
                                .clipShape(Circle())
                                .shadow(radius: 4)
                        } placeholder: {
                            ProgressView()
                                .frame(width: 80, height: 80)
                                .background(Color.gray.opacity(0.3))
                                .clipShape(Circle())
                        }
                    } else {
                        Image(systemName: "person.fill")
                            .resizable()
                            .scaledToFill()
                            .frame(width: 80, height: 80)
                            .foregroundColor(.gray)
                            .clipShape(Circle())
                    }

                    // Nombre y más info
                    VStack(alignment: .leading) {
                        Text(captain.username)
                            .font(.headline)
                        if let fullName = captain.fullName {
                            Text(fullName)
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                        }
                    }
                }
            }
        }
        .padding()
        .onAppear {
            Task {
                await loadCaptain()
            }
        }
    }

    @MainActor
    private func loadCaptain() async {
        isLoading = true
        errorMessage = nil

        guard !captainId.isEmpty else {
            errorMessage = "ID del capitán inválido"
            isLoading = false
            return
        }

        if let fetchedCaptain = await playerViewModel.fetchPlayerByID(id: captainId) {
            self.captain = fetchedCaptain
        } else {
            self.errorMessage = "No se pudo cargar al capitán."
        }

        isLoading = false
    }
}

