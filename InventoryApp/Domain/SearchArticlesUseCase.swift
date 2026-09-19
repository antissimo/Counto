import Foundation

/// Instant, fully local search over the article code list.
/// No network calls — filtering happens on every keystroke.
enum SearchArticlesUseCase {
    static func search(_ query: String, in articles: [Article]) -> [Article] {
        let trimmed = query.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return articles }

        let normalizedQuery = normalize(trimmed)

        return articles.filter { article in
            normalize(article.name).contains(normalizedQuery)
                || normalize(article.code).contains(normalizedQuery)
        }
    }

    private static func normalize(_ value: String) -> String {
        value.folding(options: .diacriticInsensitive, locale: .current).lowercased()
    }
}
