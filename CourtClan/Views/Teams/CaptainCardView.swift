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
    @State private var showDetail = false
    @State private var imageHeight: CGFloat = 100
    @State private var imageWith: CGFloat = 100

    @EnvironmentObject var playerViewModel: PlayersViewModel

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Capitán")
                .font(.title2)
                .fontWeight(.bold)
                .padding(.horizontal)

            if isLoading {
                ProgressView("Cargando capitán...")
                    .padding(.horizontal)
            } else if let error = errorMessage {
                Text("Error: \(error)")
                    .foregroundColor(.red)
                    .padding(.horizontal)
            } else if let captain = captain {
                Button {
                    showDetail.toggle()
                } label: {
                    VStack(spacing: 8) {
                        if let urlString = captain.profilePictureUrl,
                           let url = URL(string: urlString) {
                            AsyncImage(url: url) { phase in
                                switch phase {
                                case .empty:
                                    ZStack {
                                        Circle()
                                            .fill(Color.gray.opacity(0.2))
                                            .frame(width: imageWith, height: imageHeight)
                                        ProgressView()
                                    }
                                case .success(let image):
                                    image
                                        .resizable()
                                        .scaledToFill()
                                        .frame(width: imageWith, height: imageHeight)
                                        .clipShape(Circle())
                                        .shadow(radius: 4)
                                case .failure:
                                    Image(systemName: "person.crop.circle.fill")
                                        .resizable()
                                        .scaledToFit()
                                        .frame(width: imageWith, height: imageHeight)
                                        .foregroundColor(.gray.opacity(0.6))
                                        .background(Color.gray.opacity(0.2))
                                        .clipShape(Circle())
                                @unknown default:
                                    EmptyView()
                                }
                            }
                        } else {
                            Image(systemName: "person.crop.circle.fill")
                                .resizable()
                                .scaledToFit()
                                .frame(width: imageWith, height: imageHeight)
                                .foregroundColor(.gray.opacity(0.6))
                                .background(Color.gray.opacity(0.2))
                                .clipShape(Circle())
                        }

                        Text(captain.username)
                            .font(.headline)
                            .foregroundColor(.primary)
                            .lineLimit(1)
                            .truncationMode(.tail)
                            .frame(width: 100)

                    }
                    //.frame(width: 140)
                    .padding()
                    .background(
                        RoundedRectangle(cornerRadius: 16)
                            .fill(Color.white)
                            .shadow(color: .black.opacity(0.1), radius: 6, x: 0, y: 4)
                    )
                }
                .buttonStyle(PlainButtonStyle())
            }
        }
        .onAppear {
            Task { await loadCaptain() }
        }
        .sheet(isPresented: $showDetail) {
            if let captain = captain {
                PlayerDetailView(player: captain) // Asegúrate de tener esta vista
                    .presentationDetents([.fraction(0.99)])
                    //.presentationDragIndicator(.visible)
                    .presentationBackground(.clear)
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

