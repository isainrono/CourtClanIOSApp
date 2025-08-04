//
//  GameService2.swift
//  CourtClan
//
//  Created by Isain Rodriguez Noreña on 21/7/25.
//

import Foundation

class GameService2 {
    static let shared = GameService2()
    private let baseURL = "https://courtclan.com/api/games"

    private init() {}

    func fetchAllGames(completion: @escaping (Result<[Game2], Error>) -> Void) {
        let url = URL(string: baseURL)!
        URLSession.shared.dataTask(with: url) { data, _, error in
            if let error = error {
                DispatchQueue.main.async { completion(.failure(error)) }
                return
            }
            guard let data = data else {
                DispatchQueue.main.async {
                    completion(.failure(NSError(domain: "NoData", code: 0)))
                }
                return
            }
            do {
                let paginated = try JSONDecoder.courtClanLaravelDecoder.decode(PaginatedResponse<Game2>.self, from: data)
                DispatchQueue.main.async {
                    completion(.success(paginated.data))
                }
            } catch {
                print("Decoding error: \(error)")
                if let jsonString = String(data: data, encoding: .utf8) {
                    print("JSON recibido:\n\(jsonString)")
                }
                DispatchQueue.main.async { completion(.failure(error)) }
            }
        }.resume()
    }
    
    
    

    func fetchGamesByType(_ type: GameType, completion: @escaping (Result<[Game2], Error>) -> Void) {
        let url = URL(string: "\(baseURL)?game_type=\(type.rawValue)")!
        fetchPaginatedGames(from: url, completion: completion)
    }

    func fetchGamesByStatus(_ status: GameStatus, completion: @escaping (Result<[Game2], Error>) -> Void) {
        let url = URL(string: "\(baseURL)/status/\(status.rawValue)")!
        fetchPaginatedGames(from: url, completion: completion)
    }

    func fetchMyGames(playerId: String, completion: @escaping (Result<[Game2], Error>) -> Void) {
        let url = URL(string: "\(baseURL)/my/\(playerId)")!
        fetchPaginatedGames(from: url, completion: completion)
    }

    func fetchGame(id: String, completion: @escaping (Result<Game2, Error>) -> Void) {
        let url = URL(string: "\(baseURL)/\(id)")!
        fetchSingle(url: url, completion: completion)
    }

    func createGame(_ newGame: [String: Any], completion: @escaping (Result<Game2, Error>) -> Void) {
        sendRequest(urlString: baseURL, method: "POST", body: newGame, completion: completion)
    }

    func updateGame(id: String, data: [String: Any], completion: @escaping (Result<Game2, Error>) -> Void) {
        sendRequest(urlString: "\(baseURL)/\(id)", method: "PUT", body: data, completion: completion)
    }

    func deleteGame(id: String, completion: @escaping (Result<Void, Error>) -> Void) {
        var request = URLRequest(url: URL(string: "\(baseURL)/\(id)")!)
        request.httpMethod = "DELETE"
        URLSession.shared.dataTask(with: request) { _, _, error in
            DispatchQueue.main.async {
                if let error = error {
                    completion(.failure(error))
                } else {
                    completion(.success(()))
                }
            }
        }.resume()
    }

    func finalizeGame(id: String, scores: [String: Any], completion: @escaping (Result<Game2, Error>) -> Void) {
        sendRequest(urlString: "\(baseURL)/\(id)/finalize", method: "POST", body: scores, completion: completion)
    }

    // MARK: - Helpers

    private func fetchPaginatedGames(from url: URL, completion: @escaping (Result<[Game2], Error>) -> Void) {
        URLSession.shared.dataTask(with: url) { data, _, error in
            DispatchQueue.main.async {
                if let data = data {
                    do {
                        let wrapper = try JSONDecoder.courtClanLaravelDecoder.decode(PaginatedResponse<Game2>.self, from: data)
                        completion(.success(wrapper.data))
                    } catch {
                        completion(.failure(error))
                    }
                } else if let error = error {
                    completion(.failure(error))
                }
            }
        }.resume()
    }

    private func fetchSingle(url: URL, completion: @escaping (Result<Game2, Error>) -> Void) {
        URLSession.shared.dataTask(with: url) { data, _, error in
            DispatchQueue.main.async {
                if let data = data {
                    do {
                        let game = try JSONDecoder.courtClanLaravelDecoder.decode(Game2.self, from: data)
                        completion(.success(game))
                    } catch {
                        completion(.failure(error))
                    }
                } else if let error = error {
                    completion(.failure(error))
                }
            }
        }.resume()
    }

    private func sendRequest(urlString: String, method: String, body: [String: Any], completion: @escaping (Result<Game2, Error>) -> Void) {
        guard let url = URL(string: urlString) else { return }

        var request = URLRequest(url: url)
        request.httpMethod = method
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        do {
            request.httpBody = try JSONSerialization.data(withJSONObject: body)
        } catch {
            DispatchQueue.main.async {
                completion(.failure(error))
            }
            return
        }

        URLSession.shared.dataTask(with: request) { data, _, error in
            DispatchQueue.main.async {
                if let data = data {
                    do {
                        let game = try JSONDecoder.courtClanLaravelDecoder.decode(Game2.self, from: data)
                        completion(.success(game))
                    } catch {
                        completion(.failure(error))
                    }
                } else if let error = error {
                    completion(.failure(error))
                }
            }
        }.resume()
    }
}

// Wrapper para paginación
struct PaginatedResponse<T: Codable>: Codable {
    let data: [T]
}

// MARK: - JSONDecoder personalizado para Laravel
extension JSONDecoder {
    static let courtClanLaravelDecoder: JSONDecoder = {
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .custom { decoder in
            let container = try decoder.singleValueContainer()
            let dateString = try container.decode(String.self)

            let formatters: [DateFormatter] = [
                {
                    let formatter = DateFormatter()
                    formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSSSSZ"
                    formatter.locale = Locale(identifier: "en_US_POSIX")
                    formatter.timeZone = TimeZone(secondsFromGMT: 0)
                    return formatter
                }(),
                {
                    let formatter = DateFormatter()
                    formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZ"
                    formatter.locale = Locale(identifier: "en_US_POSIX")
                    formatter.timeZone = TimeZone(secondsFromGMT: 0)
                    return formatter
                }(),
                {
                    let formatter = DateFormatter()
                    formatter.dateFormat = "yyyy-MM-dd"
                    formatter.locale = Locale(identifier: "en_US_POSIX")
                    return formatter
                }()
            ]

            for formatter in formatters {
                if let date = formatter.date(from: dateString) {
                    return date
                }
            }

            throw DecodingError.dataCorruptedError(in: container, debugDescription: "Cannot decode date string \(dateString)")
        }
        return decoder
    }()
}

