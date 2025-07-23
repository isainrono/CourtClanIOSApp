//
//  AppUtils.swift
//  RodMon
//
//  Created by Isain Rodriguez Noreña on 16/4/25.
//

import Foundation
import UIKit
import SwiftUI

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
    
    // Función asíncrona para obtener una UIImage desde una URL
    static func fetchUIImage(from urlString: String) async -> UIImage? {
        guard let url = URL(string: urlString) else {
            print("❌ Error: URL inválida: \(urlString)")
            return nil
        }
        
        do {
            let (data, response) = try await URLSession.shared.data(from: url)
            
            guard let httpResponse = response as? HTTPURLResponse,
                  httpResponse.statusCode == 200 else {
                print("❌ Error de servidor o respuesta no válida: \(response)")
                return nil
            }
            
            guard let uiImage = UIImage(data: data) else {
                print("❌ Error: No se pudo crear UIImage a partir de los datos.")
                return nil
            }
            
            return uiImage
            
        } catch {
            print("❌ Error al descargar la imagen de \(urlString): \(error.localizedDescription)")
            return nil
        }
    }
    
    static func printImageUrl(teamSelected:Team?) {
        if let logoUrl = teamSelected?.logoUrl!, let url = URL(string: logoUrl) {
            AsyncImage(url: url) { image in
                image
                    .resizable()
                    .scaledToFill()
                    .frame(width: 50, height: 50)
                    .clipShape(Circle())
            } placeholder: {
                ProgressView()
                    .frame(width: 50, height: 50)
                    .clipShape(Circle())
                    .background(Color.gray.opacity(0.2))
            }
            .padding(.trailing, 5)
        } else {
            Image(systemName: "person.3.fill")
                .resizable()
                .scaledToFit()
                .frame(width: 50, height: 50)
                .foregroundColor(.blue)
                .clipShape(Circle())
                .background(Color.gray.opacity(0.2))
                .padding(.trailing, 5)
        }
    }
    
}

