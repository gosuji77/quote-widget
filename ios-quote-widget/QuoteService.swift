import Foundation

struct Quote: Codable, Equatable {
    let text: String
    let author: String
    let dateKey: String
}

struct ZenQuote: Decodable {
    let q: String
    let a: String
}

enum DateKey {
    static func today() -> String {
        let formatter = DateFormatter()
        formatter.calendar = Calendar(identifier: .gregorian)
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.timeZone = TimeZone(identifier: "America/Chicago") ?? TimeZone.current
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter.string(from: Date())
    }
}

final class QuoteService {
    private let endpoint = URL(string: "https://zenquotes.io/api/today")!

    func fetchDailyQuote() async throws -> Quote {
        let (data, response) = try await URLSession.shared.data(from: endpoint)
        guard let http = response as? HTTPURLResponse, (200...299).contains(http.statusCode) else {
            throw URLError(.badServerResponse)
        }
        let quotes = try JSONDecoder().decode([ZenQuote].self, from: data)
        guard let first = quotes.first else {
            throw URLError(.cannotParseResponse)
        }
        return Quote(text: first.q, author: first.a, dateKey: DateKey.today())
    }
}


