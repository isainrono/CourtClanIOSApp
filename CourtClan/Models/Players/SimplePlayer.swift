//
//  SimplePlayer.swift
//  CourtClan
//
//  Created by Isain Rodriguez Noreña on 22/7/25.
//

import Foundation

struct SimplePlayer: Codable, Identifiable {
    
    
    let player_id: String
    let username: String
    
    var id: String { player_id }
}

extension SimplePlayer {
    static let example1 = SimplePlayer(
        player_id: "1a2b3c4d",
        username: "JuanDavid"
    )

    static let example2 = SimplePlayer(
        player_id: "5e6f7g8h",
        username: "Camilo23"
    )

    static let example3 = SimplePlayer(
        player_id: "9i0j1k2l",
        username: "PlayerX"
    )

    static let mockList: [SimplePlayer] = [
        .example1, .example2, .example3
    ]
}

struct TeamPlayersWrapperSimple: Codable {
    let players: [SimplePlayer]
}

