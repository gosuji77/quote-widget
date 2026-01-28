import Foundation

@MainActor
final class QuoteStore: ObservableObject {
    @Published var quote: Quote?
    @Published var isLoading = false
    @Published var errorMessage: String?

    private let service = QuoteService()
    private let defaults = UserDefaults.standard
    private let quoteKey = "cachedQuote"
    private let authorKey = "cachedAuthor"
    private let dateKey = "cachedDateKey"

    func loadCachedQuote() {
        guard let text = defaults.string(forKey: quoteKey),
              let author = defaults.string(forKey: authorKey),
              let dateKey = defaults.string(forKey: dateKey) else {
            return
        }
        quote = Quote(text: text, author: author, dateKey: dateKey)
    }

    func refreshIfNeeded(force: Bool) async {
        let today = DateKey.today()
        if !force, let cached = quote, cached.dateKey == today {
            return
        }

        isLoading = true
        errorMessage = nil
        do {
            let fresh = try await service.fetchDailyQuote()
            quote = fresh
            defaults.set(fresh.text, forKey: quoteKey)
            defaults.set(fresh.author, forKey: authorKey)
            defaults.set(fresh.dateKey, forKey: dateKey)
        } catch {
            if quote == nil {
                errorMessage = "Failed to load quote. Check your connection and try again."
            }
        }
        isLoading = false
    }
}

