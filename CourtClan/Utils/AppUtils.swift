//
//  AppUtils.swift
//  RodMon
//
//  Created by Isain Rodriguez Noreña on 16/4/25.
//

import Foundation
import UIKit

class AppUtils: ObservableObject {
    
    func isValidEmail(_ email: String) -> Bool {
        guard !email.isEmpty else { return false }
        let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
        let emailPred = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
        return emailPred.evaluate(with: email)
    }
    
    static func getDeviceLanguage() -> String {
        let currentLocale = Locale.current
        let languageCode = currentLocale.language.languageCode?.identifier ?? "Desconocido"
        return languageCode
    }
    
}

