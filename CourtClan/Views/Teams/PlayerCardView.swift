//
//  PlayerCardView.swift
//  CourtClan
//
//  Created by Isain Rodriguez Noreña on 23/7/25.
//

import SwiftUICore
import SwiftUI

struct PlayerCardView: View {
    var player: Player
    var isSelected: Bool
    var animation: Namespace.ID

    var body: some View {
        VStack(spacing: 8) {
            if let urlString = player.profilePictureUrl,
               let url = URL(string: urlString) {
                AsyncImage(url: url) { phase in
                    switch phase {
                    case .empty:
                        ProgressView()
                            .frame(width: 100, height: 100)
                    case .success(let image):
                        image
                            .resizable()
                            .scaledToFill()
                            .frame(width: 100, height: 100)
                            .clipShape(Circle())
                            .shadow(radius: 6)
                            .matchedGeometryEffect(id: player.id, in: animation)
                    case .failure:
                        Image(systemName: "person.fill")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 100, height: 100)
                    @unknown default:
                        EmptyView()
                    }
                }
            } else {
                Image(systemName: "person.fill")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 100, height: 100)
                    .clipShape(Circle())
            }

            Text(player.username)
                .font(.subheadline)
                .fontWeight(.medium)
                .foregroundColor(.primary)
                .lineLimit(1)
                .truncationMode(.tail)
                .frame(width: 100)
        }
        .frame(width: 120, height: 180)
        .padding(8)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color.white)
                .shadow(color: .black.opacity(0.1), radius: 6, x: 0, y: 4)
        )
        .cornerRadius(16)
        .shadow(color: .gray.opacity(0.3), radius: 5, x: 0, y: 3)
        .scaleEffect(isSelected ? 1.05 : 1.0)
    }
}

