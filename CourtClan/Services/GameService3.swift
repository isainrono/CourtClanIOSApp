//
//  GameService3.swift
//  CourtClan
//
//  Created by Isain Rodriguez Noreña on 4/8/25.
//

import Foundation

// MARK: - GameService3

class GameService3 {
    static let shared = GameService3()
    private let baseURL = "https://courtclan.com/api/games"
    private init() {}

    func fetchGames(page: Int = 1, completion: @escaping (Result<PaginatedResponse3<Game2>, Error>) -> Void) {
        guard let url = URL(string: "\(baseURL)?page=\(page)") else {
            completion(.failure(NSError(domain: "InvalidURL", code: 0)))
            return
        }

        URLSession.shared.dataTask(with: url) { data, _, error in
            DispatchQueue.main.async {
                if let error = error {
                    completion(.failure(error))
                    return
                }

                guard let data = data else {
                    completion(.failure(NSError(domain: "NoData", code: 0)))
                    return
                }

                do {
                    let response = try JSONDecoder.courtClanLaravelDecoder3.decode(PaginatedResponse3<Game2>.self, from: data)
                    completion(.success(response))
                } catch {
                    print("Decoding error: \(error)")
                    if let jsonString = String(data: data, encoding: .utf8) {
                        print("Received JSON:\n\(jsonString)")
                    }
                    completion(.failure(error))
                }
            }
        }.resume()
    }
}

// MARK: - Paginated Response 3

struct PaginatedResponse3<T: Codable>: Codable {
    let current_page: Int
    let last_page: Int
    let data: [T]
}

// MARK: - JSONDecoder personalizado para Laravel (versión 3)

extension JSONDecoder {
    static let courtClanLaravelDecoder3: JSONDecoder = {
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .custom { decoder in
            let container = try decoder.singleValueContainer()
            let dateString = try container.decode(String.self)

            let formatters: [DateFormatter] = [
                {
                    let f = DateFormatter()
                    f.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSSSSZ"
                    f.locale = Locale(identifier: "en_US_POSIX")
                    f.timeZone = TimeZone(secondsFromGMT: 0)
                    return f
                }(),
                {
                    let f = DateFormatter()
                    f.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZ"
                    f.locale = Locale(identifier: "en_US_POSIX")
                    f.timeZone = TimeZone(secondsFromGMT: 0)
                    return f
                }(),
                {
                    let f = DateFormatter()
                    f.dateFormat = "yyyy-MM-dd"
                    f.locale = Locale(identifier: "en_US_POSIX")
                    return f
                }()
            ]

            for formatter in formatters {
                if let date = formatter.date(from: dateString) {
                    return date
                }
            }

            throw DecodingError.dataCorruptedError(in: container, debugDescription: "Cannot decode date string: \(dateString)")
        }
        return decoder
    }()
}

