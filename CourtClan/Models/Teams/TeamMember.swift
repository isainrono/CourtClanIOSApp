//
//  TeamMember.swift
//  CourtClan
//
//  Created by Isain Rodriguez Noreña on 21/7/25.
//

import Foundation

struct TeamMember: Codable {
    let teamId: String
    let userId: String
    let role: String?
    let isActive: Bool?
    let joinedAt: String?
    let leftAt: String?
    let player: Player?
    
    enum CodingKeys: String, CodingKey {
        case teamId = "team_id"
        case userId = "user_id"
        case role, isActive = "is_active"
        case joinedAt = "joined_at"
        case leftAt = "left_at"
        case player
    }
}




