import Foundation

struct ArticleMatch {
    let article: Article
    let confidence: Double // 0.0 ... 1.0
}

/// Matches a free-text article reference (typically from voice) against the
/// local article catalog (spec section 13). Never invents new articles —
/// only ranks existing ones by similarity, so low-confidence results can be
/// surfaced to the user for disambiguation instead of auto-confirming.
enum ArticleMatcher {
    private static let minimumConfidence = 0.3

    static func match(text: String, in articles: [Article]) -> [ArticleMatch] {
        let normalizedQuery = normalize(text)
        guard !normalizedQuery.isEmpty else { return [] }

        let scored = articles.map { article in
            ArticleMatch(article: article, confidence: similarity(normalizedQuery, normalize(article.name)))
        }

        return scored
            .filter { $0.confidence > minimumConfidence }
            .sorted { $0.confidence > $1.confidence }
    }

    private static func normalize(_ value: String) -> String {
        value.folding(options: .diacriticInsensitive, locale: .current)
            .lowercased()
            .trimmingCharacters(in: .whitespacesAndNewlines)
    }

    private static func similarity(_ a: String, _ b: String) -> Double {
        guard !a.isEmpty, !b.isEmpty else { return 0 }
        if a == b { return 1.0 }

        let maxLen = max(a.count, b.count)
        let distance = levenshtein(a, b)
        let editScore = maxLen > 0 ? 1.0 - Double(distance) / Double(maxLen) : 0

        let tokenScore = tokenOverlap(a, b)

        return editScore * 0.5 + tokenScore * 0.5
    }

    private static func tokenOverlap(_ a: String, _ b: String) -> Double {
        let tokensA = Set(a.split(separator: " ").map(String.init))
        let tokensB = Set(b.split(separator: " ").map(String.init))
        guard !tokensA.isEmpty, !tokensB.isEmpty else { return 0 }

        let intersection = tokensA.intersection(tokensB).count
        let union = tokensA.union(tokensB).count
        return union > 0 ? Double(intersection) / Double(union) : 0
    }

    private static func levenshtein(_ a: String, _ b: String) -> Int {
        let a = Array(a)
        let b = Array(b)
        guard !a.isEmpty else { return b.count }
        guard !b.isEmpty else { return a.count }

        var dist = Array(repeating: Array(repeating: 0, count: b.count + 1), count: a.count + 1)
        for i in 0...a.count { dist[i][0] = i }
        for j in 0...b.count { dist[0][j] = j }

        for i in 1...a.count {
            for j in 1...b.count {
                if a[i - 1] == b[j - 1] {
                    dist[i][j] = dist[i - 1][j - 1]
                } else {
                    dist[i][j] = 1 + min(dist[i - 1][j], dist[i][j - 1], dist[i - 1][j - 1])
                }
            }
        }

        return dist[a.count][b.count]
    }
}
