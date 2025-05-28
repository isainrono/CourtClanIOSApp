//
//  TabModel.swift
//  RodMon
//
//  Created by Isain Rodriguez Noreña on 17/4/25.
//

import Foundation

enum TabModel: String, CaseIterable{
    
    case home = "Players"
    case favorites = "Teams"
    case cart = "Highlights"
    case search = "Courts"
    case settings = "Events"
    
    var systemImageName: String {
        switch self {
        case .home:
            return "figure.basketball"
        case .favorites:
            return "person.3.fill"
        case .cart:
            return "basketball.fill"
        case .search:
            return "sportscourt.fill"
        case .settings:
            return "dpad.right.filled"
        }
    }
}

    
